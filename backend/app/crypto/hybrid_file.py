import os
from pathlib import Path

from cryptography.hazmat.primitives.ciphers.aead import AESGCM

from .keys import rsa_oaep_decrypt, rsa_oaep_encrypt


def encrypt_file(data):
    aes_key = os.urandom(32)
    nonce = os.urandom(12)
    encrypted_data = nonce + AESGCM(aes_key).encrypt(nonce, data, None)
    encrypted_aes_key = rsa_oaep_encrypt(aes_key)
    return encrypted_data, encrypted_aes_key


def decrypt_file(path, encrypted_aes_key):
    encrypted_data = Path(path).read_bytes()
    aes_key = rsa_oaep_decrypt(encrypted_aes_key)
    return AESGCM(aes_key).decrypt(encrypted_data[:12], encrypted_data[12:], None)
