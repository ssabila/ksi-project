# SDMS Multi-Layer Security

Student Data Management System untuk proyek akhir Kelompok 2 - 3SI2. Aplikasi ini mendemonstrasikan alur akademik lengkap dengan enam lapisan keamanan: bcrypt, TLS, AES-GCM database, hybrid encryption file, RBAC, dan audit log.

## Fitur

- Login JWT dan registrasi mahasiswa.
- Password disimpan menggunakan bcrypt dengan salt dan cost adaptif.
- Nilai disimpan sebagai ciphertext AES-GCM; plaintext hanya muncul setelah otorisasi di API.
- Upload dokumen memakai envelope encryption: isi file dienkripsi AES-256-GCM dan kunci AES dibungkus RSA-OAEP 2048-bit.
- Role `mahasiswa`, `dosen`, dan `admin`.
- Mahasiswa hanya dapat membaca nilai dan dokumennya sendiri.
- Dosen dapat memasukkan dan melihat nilai mahasiswa.
- Admin dapat melihat audit log 100 aktivitas terakhir.
- Audit aksi login, input nilai, upload/download, akses ditolak, dan pendaftaran.
- SQLite untuk demo lokal; MySQL melalui `DATABASE_URL` untuk deployment kelompok.
- TLS self-signed untuk demo lokal melalui `ssl_context`.

## Struktur proyek

```text
backend/
  app/
    auth.py                 # bcrypt dan JWT
    audit.py                # pencatatan aktivitas
    crypto/
      aes_db.py             # AES-GCM nilai
      hybrid_file.py        # AES-GCM file + RSA-OAEP
      keys.py               # generate/load pasangan RSA
    models.py               # users, nilai, files, audit_log
    rbac.py                 # decorator role
    routes.py               # seluruh API
  certs/                    # sertifikat TLS lokal, tidak di-commit
  keys/                     # private/public RSA, tidak di-commit
  storage/                  # ciphertext file, tidak di-commit
  migrations/               # riwayat perubahan schema Alembic
  schema.sql                # schema MySQL
  dummy_mahasiswa.sql       # SQL daftar mahasiswa demo
  seed_demo.py              # data dummy terenkripsi
  run.py
frontend/
  src/App.jsx               # login dan dashboard multi-role
  src/styles.css
```

## Prasyarat

- Python 3.10+
- Node.js 18+
- Git
- MySQL 8+ atau MariaDB jika tidak ingin menggunakan SQLite
- OpenSSL hanya diperlukan untuk sertifikat TLS manual

## Setup cepat Windows PowerShell

Terminal pertama:

```powershell
cd backend
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
python run.py
```

Database SQLite dibuat otomatis di `backend/instance/sdms.db`. Kunci RSA dibuat otomatis di `backend/keys/` saat upload file pertama. Untuk keamanan sungguhan, ganti semua nilai secret dan password demo di `.env` sebelum dipakai bersama.

Terminal kedua:

```powershell
cd frontend
npm install
npm run dev
```

Buka `http://localhost:5173`. Saat development, frontend memakai proxy `/api` sehingga browser tidak perlu mempercayai sertifikat self-signed backend secara langsung. Ubah `VITE_API_URL` jika frontend perlu mengakses API pada host atau port lain.

Jika TLS lokal aktif, frontend menggunakan `https://localhost:5000/api`. Buka `https://localhost:5000/api/health` sekali di browser dan pilih **Advanced** lalu **Proceed to localhost** agar sertifikat self-signed dipercaya browser. Setelah mengubah file environment frontend, restart `npm run dev`.

## Akun demo

Akun dibuat otomatis saat database pertama kali dibuat jika `SEED_DEMO_USERS=true`:

| Username | Password | Role |
|---|---|---|
| `admin` | `Admin123!` | admin |
| `dosen` | `Dosen123!` | dosen |
| `mahasiswa` | `Mahasiswa123!` | mahasiswa |

Ganti password tersebut di `.env` sebelum demo resmi. Registrasi dari browser selalu menghasilkan role `mahasiswa`; pembuatan role staf hanya boleh dilakukan melalui proses admin/seed yang dikendalikan.

## Konfigurasi `.env`

```env
DATABASE_URL=sqlite:///sdms.db
JWT_SECRET_KEY=secret-random-minimal-32-karakter
DB_AES_KEY=base64-url-safe-32-byte-key
UPLOAD_DIR=storage
RSA_PRIVATE_KEY_PATH=keys/private.pem
RSA_PUBLIC_KEY_PATH=keys/public.pem
SEED_DEMO_USERS=true
DEMO_ADMIN_PASSWORD=Admin123!
DEMO_DOSEN_PASSWORD=Dosen123!
DEMO_MAHASISWA_PASSWORD=Mahasiswa123!
```

Buat key AES yang benar-benar acak dengan Python:

```powershell
python -c "import secrets,base64; print(base64.urlsafe_b64encode(secrets.token_bytes(32)).decode())"
```

## Menggunakan MySQL

1. Pastikan service MySQL aktif.
2. Jalankan `backend/schema.sql` lewat MySQL client, phpMyAdmin, atau DBeaver.
3. Ubah `.env`:

```env
DATABASE_URL=mysql+pymysql://root:password@localhost/sdms
```

4. Hapus database SQLite lokal bila sebelumnya pernah dipakai agar tidak tertukar.
5. Jalankan `python run.py` kembali.

`db.create_all()` membuat tabel baru, tetapi bukan tool migrasi. Untuk perubahan schema setelah aplikasi berisi data, gunakan Alembic/Flask-Migrate atau buat migration SQL terpisah.

### Migrasi schema dengan Flask-Migrate

Jalankan dari folder `backend` menggunakan virtual environment:

```powershell
cd backend
.\venv\Scripts\Activate.ps1
flask --app run.py db init
flask --app run.py db migrate -m "initial schema"
flask --app run.py db upgrade
```

`db init` cukup dilakukan satu kali. Setiap kali model di [backend/app/models.py](backend/app/models.py) berubah, buat migration baru lalu terapkan:

```powershell
flask --app run.py db migrate -m "jelaskan perubahan schema"
flask --app run.py db upgrade
```

Periksa file hasil migration sebelum menjalankan `upgrade`, terutama jika database sudah berisi data. Jangan menghapus `instance/sdms.db` kecuali memang ingin mengulang database lokal dari awal.

### Membuat data dummy

Setelah dependency terpasang dan database tersedia, jalankan:

```powershell
python seed_demo.py
```

Script ini aman dijalankan berulang kali. Script membuat dua akun mahasiswa, masing-masing satu nilai yang disimpan terenkripsi AES-GCM, satu file ciphertext hasil hybrid encryption, dan satu audit log. Akun dummy tambahan:

| Username | Password |
|---|---|
| `andi` | `Andi12345!` |
| `sari` | `Sari12345!` |

Data demo utama (`admin`, `dosen`, dan `mahasiswa`) tetap dibuat otomatis oleh aplikasi saat startup.

## TLS lokal

Jika `openssl` sudah terpasang dan tersedia di PATH, buat sertifikat dari folder `backend`:

```powershell
cd backend
New-Item -ItemType Directory -Force certs
openssl req -x509 -newkey rsa:2048 -nodes -keyout certs/key.pem -out certs/cert.pem -days 30 -subj "/CN=localhost"
```

Jika PowerShell menampilkan `openssl is not recognized`, gunakan generator Python yang tidak memerlukan instalasi OpenSSL:

```powershell
cd backend
python generate_tls_cert.py
```

Script tersebut menggunakan package `cryptography` dari `requirements.txt` dan menghasilkan sertifikat berlaku 30 hari di `backend/certs/`.

Tambahkan ke `.env`:

```env
SSL_CERT_FILE=certs/cert.pem
SSL_KEY_FILE=certs/key.pem
```

Jalankan ulang backend dan buka `https://localhost:5000/api/health`. Browser akan memberi peringatan karena sertifikat self-signed; itu normal untuk demo lokal. Jangan gunakan server Flask development dan sertifikat self-signed sebagai deployment produksi.

## API utama

| Method | Endpoint | Akses |
|---|---|---|
| GET | `/api/health` | publik |
| POST | `/api/auth/register` | publik |
| POST | `/api/auth/login` | publik |
| GET | `/api/auth/me` | JWT |
| GET | `/api/mahasiswa` | dosen, admin |
| POST | `/api/nilai` | dosen |
| GET | `/api/nilai/<mahasiswa_id>` | pemilik, dosen |
| POST | `/api/files` | mahasiswa pemilik |
| GET | `/api/files` | JWT |
| GET | `/api/files/<id>/download` | pemilik, dosen |
| GET | `/api/audit` | admin |

Contoh input nilai:

```json
{
  "mahasiswa_id": 3,
  "uts": 85,
  "uas": 90,
  "tugas": 88,
  "praktikum": 92
}
```

Header untuk endpoint protected:

```text
Authorization: Bearer <access_token>
```

## Skenario pengujian untuk laporan

1. **Hash password:** cek database; `password_hash` harus bcrypt dan tidak sama dengan password asli.
2. **TLS:** bandingkan request HTTP dan HTTPS di Wireshark; jelaskan bahwa self-signed hanya untuk lingkungan demo.
3. **Kebocoran database:** lihat kolom `uts_enc` langsung di DBMS; nilainya harus binary/ciphertext, bukan `85`.
4. **Hybrid file:** upload file, cek file `.enc`, cek `encrypted_aes_key`, lalu download dan cocokkan hash file asli.
5. **RBAC:** login sebagai mahasiswa dan minta `/api/audit` atau nilai mahasiswa lain; response harus `403`.
6. **Audit:** cocokkan login, input nilai, upload, download, dan akses ditolak dengan baris `audit_log`.
7. **End-to-end upload:** login, upload, file tersimpan terenkripsi, download berhasil oleh pemilik.
8. **End-to-end akses:** bandingkan akses mahasiswa, dosen, dan admin pada data yang sama.
9. **Before/after security:** jalankan hanya di database uji, bandingkan endpoint tanpa decorator dengan endpoint protected.
10. **Performa:** ukur AES-GCM nilai dan hybrid file pada ukuran file yang sama; laporkan waktu, ukuran ciphertext, dan overhead RSA key envelope.

Hasil screenshot dan log sebaiknya disimpan di `docs/pengujian/skenario-N/` tanpa menyimpan password, JWT, private key, atau file asli sensitif.

### Halaman frontend

- `/` - ringkasan dashboard
- `/mahasiswa` - daftar mahasiswa untuk dosen/admin
- `/nilai` - input nilai untuk dosen/admin dan riwayat nilai untuk mahasiswa
- `/dokumen` - upload dan download dokumen terenkripsi
- `/audit` - audit log untuk admin

## Catatan desain dan batasan

- AES-GCM dipilih dibanding CBC pada contoh proposal karena memberikan confidentiality sekaligus integrity melalui authentication tag.
- Private key RSA dibuat lokal dan di-ignore Git. Untuk deployment, simpan di secret manager atau volume dengan permission terbatas.
- CORS saat ini terbuka untuk memudahkan demo. Batasi `origins` ke URL frontend saat deployment.
- Audit log level aplikasi sudah tersedia. Trigger MySQL pada `schema.sql` adalah lapisan tambahan dan membutuhkan aplikasi mengisi `@current_user_id` dalam transaksi.
- SQLite dan Flask development server ditujukan untuk demonstrasi; gunakan WSGI server, reverse proxy TLS, migration tool, rate limiting, dan secret manager untuk produksi.

## Permission setiap role

Aturan backend berada di [backend/app/rbac.py](backend/app/rbac.py) dan decorator pada [backend/app/routes.py](backend/app/routes.py). UI hanya mengikuti aturan ini; keamanan tetap ditegakkan oleh API.

| Fitur | Mahasiswa | Dosen | Admin |
|---|---:|---:|---:|
| Melihat nilai sendiri | Ya | Ya | Ya |
| Melihat nilai mahasiswa lain | Tidak | Ya | Tidak |
| Input nilai | Tidak | Ya | Tidak |
| Melihat daftar mahasiswa | Tidak | Ya | Ya |
| Upload dokumen | Ya, milik sendiri | Tidak | Tidak |
| Download dokumen | Milik sendiri | Semua | Tidak |
| Melihat audit log | Tidak | Tidak | Ya |

Untuk mengubah permission input nilai, ubah decorator endpoint `POST /api/nilai`, lalu sesuaikan `canInputScores` di frontend. Jangan hanya menyembunyikan tombol di UI karena request langsung ke API tetap harus ditolak.
