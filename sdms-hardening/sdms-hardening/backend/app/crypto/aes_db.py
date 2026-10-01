"""Layer 3: enkripsi kolom nilai dengan AES-256-GCM + AAD.

Format ciphertext (v1):  [versi 1 B][nonce 12 B][ciphertext][tag 16 B]

AAD (Additional Authenticated Data) = "nilai:<mahasiswa_id>:<field>".
AAD tidak dienkripsi, tetapi ikut diautentikasi oleh tag GCM. Akibatnya ciphertext
terikat pada mahasiswa dan kolomnya: memindahkan uts_enc ke baris/kolom lain
akan gagal dengan InvalidTag saat didekripsi.
"""

import os

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

from .secrets_config import get_nilai_key

VERSION = b"\x01"
NONCE_SIZE = 12


def build_aad(mahasiswa_id, field):
    return f"nilai:{int(mahasiswa_id)}:{field}".encode()


def encrypt_value(value, mahasiswa_id, field):
    nonce = os.urandom(NONCE_SIZE)
    ciphertext = AESGCM(get_nilai_key()).encrypt(
        nonce, str(int(value)).encode(), build_aad(mahasiswa_id, field)
    )
    return VERSION + nonce + ciphertext


def decrypt_value(blob, mahasiswa_id, field):
    """Raise cryptography.exceptions.InvalidTag jika data/AAD/kunci tidak cocok,
    atau ValueError jika format tidak dikenali."""
    if not blob:
        return None
    blob = bytes(blob)
    if blob[:1] != VERSION or len(blob) < 1 + NONCE_SIZE + 16:
        raise ValueError("Format ciphertext nilai tidak dikenali")
    nonce = blob[1 : 1 + NONCE_SIZE]
    plaintext = AESGCM(get_nilai_key()).decrypt(
        nonce, blob[1 + NONCE_SIZE :], build_aad(mahasiswa_id, field)
    )
    return int(plaintext.decode())
