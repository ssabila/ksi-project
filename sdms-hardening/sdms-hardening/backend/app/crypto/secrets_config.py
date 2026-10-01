"""Pengelolaan secret dan kunci: validasi konfigurasi + penurunan subkey (HKDF).

Prinsip:
- Secret WAJIB diisi lewat environment. Tidak ada fallback diam-diam.
- Mode demo hanya aktif jika SDMS_ALLOW_INSECURE_DEFAULTS=true (eksplisit).
- Satu master key (DB_AES_KEY) diturunkan menjadi subkey per tujuan (domain separation),
  sehingga kunci nilai tidak dipakai mentah untuk tujuan lain.
"""

import base64
import binascii
import hashlib
import logging
import os
from functools import lru_cache

from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.hkdf import HKDF

logger = logging.getLogger(__name__)

PLACEHOLDER_PREFIX = "ganti_dengan"
DEV_JWT_SECRET = "local-development-secret-change-me"
DEV_MASTER_KEY = hashlib.sha256(b"sdms-local-development-key").digest()
NILAI_KEY_INFO = b"sdms/v1/nilai-column-encryption"
GENERATOR_HINT = "jalankan `python generate_secrets.py` lalu salin hasilnya ke .env"


class ConfigError(RuntimeError):
    """Konfigurasi keamanan belum diisi atau tidak valid."""


def insecure_defaults_allowed():
    return os.getenv("SDMS_ALLOW_INSECURE_DEFAULTS", "false").strip().lower() == "true"


def _is_unset(value):
    return not value or value.startswith(PLACEHOLDER_PREFIX)


def _decode_master_key(raw):
    try:
        decoded = base64.urlsafe_b64decode(raw + "=" * (-len(raw) % 4))
    except (binascii.Error, ValueError) as error:
        raise ConfigError("DB_AES_KEY bukan base64 URL-safe yang valid") from error
    if len(decoded) != 32:
        raise ConfigError(
            f"DB_AES_KEY harus 32 byte setelah decode base64 (didapat {len(decoded)} byte)"
        )
    return decoded


def get_master_key():
    raw = os.getenv("DB_AES_KEY", "").strip()
    if _is_unset(raw):
        if insecure_defaults_allowed():
            return DEV_MASTER_KEY
        raise ConfigError(f"DB_AES_KEY belum diisi; {GENERATOR_HINT}")
    return _decode_master_key(raw)


def get_jwt_secret():
    raw = os.getenv("JWT_SECRET_KEY", "").strip()
    if _is_unset(raw):
        if insecure_defaults_allowed():
            return DEV_JWT_SECRET
        raise ConfigError(f"JWT_SECRET_KEY belum diisi; {GENERATOR_HINT}")
    return raw


@lru_cache(maxsize=16)
def _derive_subkey(master_key, purpose):
    return HKDF(algorithm=hashes.SHA256(), length=32, salt=None, info=purpose).derive(master_key)


def get_subkey(purpose):
    return _derive_subkey(get_master_key(), purpose)


def get_nilai_key():
    return get_subkey(NILAI_KEY_INFO)


def validate_security_config():
    """Dipanggil saat startup. Gagal cepat (fail-fast) jika konfigurasi tidak aman."""
    problems = []
    jwt_secret = None
    try:
        jwt_secret = get_jwt_secret()
        if len(jwt_secret.encode()) < 32:
            problems.append("JWT_SECRET_KEY minimal 32 karakter")
    except ConfigError as error:
        problems.append(str(error))
    try:
        get_master_key()
    except ConfigError as error:
        problems.append(str(error))
    if jwt_secret and os.getenv("DB_AES_KEY", "").strip() == jwt_secret:
        problems.append("DB_AES_KEY dan JWT_SECRET_KEY tidak boleh sama")
    if problems:
        raise ConfigError("Konfigurasi keamanan tidak valid:\n- " + "\n- ".join(problems))
    if insecure_defaults_allowed():
        logger.warning(
            "SDMS_ALLOW_INSECURE_DEFAULTS=true: kunci development boleh dipakai. "
            "JANGAN aktifkan di lingkungan bersama atau produksi."
        )
