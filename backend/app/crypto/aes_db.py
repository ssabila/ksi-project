import base64
import hashlib
import os

from cryptography.hazmat.primitives.ciphers.aead import AESGCM


def get_aes_key():
    configured = os.getenv("DB_AES_KEY", "")
    if not configured or configured.startswith("ganti_dengan"):
        return hashlib.sha256(b"sdms-local-development-key").digest()
    try:
        padded = configured + "=" * (-len(configured) % 4)
        decoded = base64.urlsafe_b64decode(padded.encode())
        if len(decoded) == 32:
            return decoded
    except ValueError:
        pass
    if len(configured.encode()) == 32:
        return configured.encode()
    return hashlib.sha256(configured.encode()).digest()


def encrypt_value(value):
    nonce = os.urandom(12)
    ciphertext = AESGCM(get_aes_key()).encrypt(nonce, str(value).encode(), None)
    return nonce + ciphertext


def decrypt_value(value):
    if not value:
        return None
    plaintext = AESGCM(get_aes_key()).decrypt(value[:12], value[12:], None)
    return int(plaintext.decode())
