# SDMS Hardening — cara pasang

Salin isi folder `backend/` ini ke `backend/` di repo (timpa file yang sama), lalu:

1. `python generate_secrets.py` → salin JWT_SECRET_KEY dan DB_AES_KEY ke `.env`.
2. Data nilai lama: backup DB, set `LEGACY_DB_AES_KEY` (kunci lama), jalankan
   `python migrate_nilai_aad.py --dry-run` lalu tanpa `--dry-run`.
   (Atau hapus data demo lama dan jalankan `python seed_demo.py` lagi.)
3. Tes: `python -m unittest discover -s tests -t . -v`
4. Demo lokal cepat tanpa generate kunci: `SDMS_ALLOW_INSECURE_DEFAULTS=true` di `.env`.

File baru : app/crypto/secrets_config.py, generate_secrets.py, migrate_nilai_aad.py, tests/test_crypto_hardening.py
File diubah: app/__init__.py, app/routes.py, app/crypto/aes_db.py, run.py, seed_demo.py, .env.example
