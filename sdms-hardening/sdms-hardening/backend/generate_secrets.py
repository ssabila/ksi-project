"""Membuat secret acak untuk .env. Jalankan: python generate_secrets.py"""

import base64
import secrets

print("JWT_SECRET_KEY=" + secrets.token_urlsafe(48))
print("DB_AES_KEY=" + base64.urlsafe_b64encode(secrets.token_bytes(32)).decode())
