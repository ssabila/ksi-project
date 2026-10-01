"""Jalankan dari folder backend:  python -m unittest discover -s tests -t . -v"""

import base64
import os
import unittest
from unittest.mock import patch

from cryptography.exceptions import InvalidTag

from app.crypto import aes_db
from app.crypto.secrets_config import (
    ConfigError,
    get_nilai_key,
    validate_security_config,
)

KEY = base64.urlsafe_b64encode(bytes(range(32))).decode()
JWT = "j" * 40
GOOD = {"DB_AES_KEY": KEY, "JWT_SECRET_KEY": JWT, "SDMS_ALLOW_INSECURE_DEFAULTS": "false"}


class AesAadTests(unittest.TestCase):
    def setUp(self):
        patcher = patch.dict(os.environ, GOOD)
        patcher.start()
        self.addCleanup(patcher.stop)

    def test_roundtrip(self):
        blob = aes_db.encrypt_value(87, 3, "uts")
        self.assertEqual(aes_db.decrypt_value(blob, 3, "uts"), 87)

    def test_nonce_unik(self):
        self.assertNotEqual(aes_db.encrypt_value(87, 3, "uts"), aes_db.encrypt_value(87, 3, "uts"))

    def test_tukar_mahasiswa_terdeteksi(self):
        blob = aes_db.encrypt_value(87, 3, "uts")
        with self.assertRaises(InvalidTag):
            aes_db.decrypt_value(blob, 4, "uts")

    def test_tukar_kolom_terdeteksi(self):
        blob = aes_db.encrypt_value(87, 3, "uts")
        with self.assertRaises(InvalidTag):
            aes_db.decrypt_value(blob, 3, "uas")

    def test_modifikasi_terdeteksi(self):
        blob = bytearray(aes_db.encrypt_value(87, 3, "uts"))
        blob[-1] ^= 0x01
        with self.assertRaises(InvalidTag):
            aes_db.decrypt_value(bytes(blob), 3, "uts")

    def test_format_lama_ditolak(self):
        with self.assertRaises(ValueError):
            aes_db.decrypt_value(b"\x00" * 40, 3, "uts")

    def test_kunci_lain_gagal(self):
        blob = aes_db.encrypt_value(87, 3, "uts")
        other = base64.urlsafe_b64encode(bytes(range(1, 33))).decode()
        with patch.dict(os.environ, {"DB_AES_KEY": other}):
            with self.assertRaises(InvalidTag):
                aes_db.decrypt_value(blob, 3, "uts")

    def test_subkey_berbeda_dari_master(self):
        self.assertNotEqual(get_nilai_key(), bytes(range(32)))


class ConfigTests(unittest.TestCase):
    def check(self, env):
        with patch.dict(os.environ, env):
            validate_security_config()

    def test_valid(self):
        self.check(GOOD)

    def test_kunci_kosong_ditolak(self):
        with self.assertRaises(ConfigError):
            self.check({**GOOD, "DB_AES_KEY": ""})

    def test_placeholder_ditolak(self):
        with self.assertRaises(ConfigError):
            self.check({**GOOD, "DB_AES_KEY": "ganti_dengan_hasil_generate_secrets"})

    def test_panjang_salah_ditolak(self):
        with self.assertRaises(ConfigError):
            self.check({**GOOD, "DB_AES_KEY": "gFitRfymlaJ6EMs3CvLwroyOIMlmzwXsia5D2z7gPan0="})

    def test_jwt_pendek_ditolak(self):
        with self.assertRaises(ConfigError):
            self.check({**GOOD, "JWT_SECRET_KEY": "pendek"})

    def test_kunci_sama_ditolak(self):
        with self.assertRaises(ConfigError):
            self.check({**GOOD, "JWT_SECRET_KEY": KEY + "x" * 0})

    def test_mode_demo_eksplisit(self):
        self.check({"DB_AES_KEY": "", "JWT_SECRET_KEY": "", "SDMS_ALLOW_INSECURE_DEFAULTS": "true"})


if __name__ == "__main__":
    unittest.main()
