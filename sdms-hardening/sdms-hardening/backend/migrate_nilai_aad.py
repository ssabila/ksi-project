"""Migrasi data nilai lama (AES-GCM tanpa AAD, kunci = DB_AES_KEY lama) ke format v1.

Langkah:
  1. BACKUP database terlebih dahulu.
  2. Isi .env dengan DB_AES_KEY baru (dan JWT_SECRET_KEY baru).
  3. Set LEGACY_DB_AES_KEY = nilai DB_AES_KEY LAMA (kosongkan jika dulu memakai kunci dev bawaan).
  4. python migrate_nilai_aad.py --dry-run   lalu   python migrate_nilai_aad.py
"""

import argparse
import base64
import hashlib
import os
import sys

from cryptography.exceptions import InvalidTag
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

from app import create_app, db
from app.crypto.aes_db import decrypt_value, encrypt_value
from app.models import Nilai

SCORE_FIELDS = ("uts", "uas", "tugas", "praktikum")


def legacy_key(configured):
    """Salinan persis logika get_aes_key() versi lama."""
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


def decrypt_legacy(blob, key):
    blob = bytes(blob)
    return int(AESGCM(key).decrypt(blob[:12], blob[12:], None).decode())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    old_key = legacy_key(os.getenv("LEGACY_DB_AES_KEY", ""))

    app = create_app()
    migrated = skipped = failed = 0
    with app.app_context():
        for record in Nilai.query.all():
            for field in SCORE_FIELDS:
                column = f"{field}_enc"
                blob = getattr(record, column)
                try:
                    decrypt_value(blob, record.mahasiswa_id, field)
                    skipped += 1  # sudah format baru
                    continue
                except (InvalidTag, ValueError):
                    pass
                try:
                    value = decrypt_legacy(blob, old_key)
                except (InvalidTag, ValueError):
                    failed += 1
                    print(f"GAGAL nilai:{record.id}:{field} (kunci lama salah / data rusak)")
                    continue
                setattr(record, column, encrypt_value(value, record.mahasiswa_id, field))
                migrated += 1
        if failed or args.dry_run:
            db.session.rollback()
        else:
            db.session.commit()
    print(f"dimigrasi={migrated} sudah_baru={skipped} gagal={failed} dry_run={args.dry_run}")
    if failed:
        print("Tidak ada perubahan disimpan karena ada kegagalan.")
        sys.exit(1)


if __name__ == "__main__":
    main()
