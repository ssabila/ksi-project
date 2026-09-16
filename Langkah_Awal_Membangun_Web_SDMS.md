# Langkah Konkret: Dari Nol Sampai Web Dasar Jalan
**Kelompok 2 – 3SI2 | Proyek Akhir SDMS Multi-Layer Security**

Tujuan dokumen ini: di akhir Hari 1, ada web yang bisa diakses di browser — mahasiswa bisa isi form nilai, data tersimpan ke database, dan muncul lagi saat dibuka — **tanpa enkripsi/keamanan sama sekali dulu**. Keamanan (hash password, TLS, AES, RSA, RBAC, audit log) baru ditempel di atas alur ini setelah alur dasarnya terbukti jalan.

Urutan di bawah dikerjakan berurutan oleh 1–2 orang yang paling siap alat (laptop, sudah install Node/Python). Begitu server nyala sampai Langkah 7, anggota lain `git pull` dan langsung mulai kerja di layer masing-masing secara paralel — tidak perlu menunggu giliran.

**Stack yang dipakai:** React (Vite) untuk frontend, Flask (Python) untuk backend, MySQL/PostgreSQL untuk database — sesuai yang sudah ditentukan dan dijustifikasi di proposal Bab II.3.

---

## Langkah 1 — Pastikan tools terpasang

Cek dulu satu per satu di terminal:
```bash
node -v              # butuh v18+
python3 --version    # butuh 3.10+
mysql --version       # atau psql --version kalau pakai PostgreSQL
git --version
```
Kalau ada yang belum ada, install dulu sebelum lanjut (Node dari nodejs.org, Python dari python.org, MySQL Community Server atau XAMPP untuk yang mau GUI).

---

## Langkah 2 — Buat repo & struktur folder

```bash
mkdir sdms-multilayer && cd sdms-multilayer
git init
mkdir backend frontend docs
```

Push ke GitHub (buat repo kosong dulu di web GitHub), lalu:
```bash
git remote add origin <url-repo-kalian>
git add . && git commit -m "init: struktur folder"
git push -u origin main
```

Semua anggota `git clone <url-repo>` di laptop masing-masing.

---

## Langkah 3 — Backend: Flask jalan dulu (target: "Hello World" di browser)

```bash
cd backend
python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate
pip install flask flask-sqlalchemy flask-cors python-dotenv pymysql
pip freeze > requirements.txt
```

Buat file `backend/run.py`:
```python
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  # supaya React (port beda) boleh akses API ini

@app.route("/api/health")
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(debug=True, port=5000)
```

Jalankan:
```bash
python run.py
```

Buka `http://localhost:5000/api/health` di browser — kalau muncul `{"status":"ok"}`, backend dasar sudah hidup.

> **Checkpoint 1 — jangan lanjut sebelum ini berhasil.**

---

## Langkah 4 — Database: buat skema & hubungkan ke Flask

Buat database dulu (contoh MySQL):
```sql
CREATE DATABASE sdms;
```

Jalankan skema tabel berikut di database `sdms` (lewat phpMyAdmin, DBeaver, atau `mysql -u root -p sdms < schema.sql`):
```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),
    role ENUM('mahasiswa','dosen','admin')
);

CREATE TABLE nilai (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_id INT,
    uts_enc VARBINARY(255),
    uas_enc VARBINARY(255),
    tugas_enc VARBINARY(255),
    praktikum_enc VARBINARY(255),
    ips_enc VARBINARY(255),
    ipk_enc VARBINARY(255)
);

CREATE TABLE files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_id INT,
    filepath VARCHAR(255),
    encrypted_aes_key VARBINARY(512)
);

CREATE TABLE audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100),
    object VARCHAR(100),
    status VARCHAR(20),
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

Buat file `backend/.env` (jangan di-commit ke git — tambahkan `.env` ke `.gitignore`):
```
DATABASE_URL=mysql+pymysql://root:password@localhost/sdms
DB_AES_KEY=ganti_dengan_32_byte_random_nanti
```

Buat `backend/app/models.py` (skeleton awal, tanpa enkripsi dulu — kolom nilai masih `Integer` biasa, nanti diganti `LargeBinary` saat Layer 3 dipasang):
```python
from flask_sqlalchemy import SQLAlchemy
db = SQLAlchemy()

class User(db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True)
    password_hash = db.Column(db.String(255))
    role = db.Column(db.String(20))

class Nilai(db.Model):
    __tablename__ = "nilai"
    id = db.Column(db.Integer, primary_key=True)
    mahasiswa_id = db.Column(db.Integer)
    uts = db.Column(db.Integer)
    uas = db.Column(db.Integer)
    tugas = db.Column(db.Integer)
    praktikum = db.Column(db.Integer)
```

Update `run.py` untuk load config & buat tabel otomatis:
```python
import os
from dotenv import load_dotenv
load_dotenv()

app.config["SQLALCHEMY_DATABASE_URI"] = os.environ["DATABASE_URL"]
db.init_app(app)
with app.app_context():
    db.create_all()
```

Test dengan endpoint sementara untuk insert dummy data, pastikan barisnya masuk ke tabel `nilai` saat dicek lewat DBMS.

> **Checkpoint 2 — data bisa masuk & terbaca dari database.**

---

## Langkah 5 — Frontend: React (Vite) jalan dulu

```bash
cd ../frontend
npm create vite@latest . -- --template react
npm install
npm install axios react-router-dom
npm run dev
```

Buka URL yang muncul di terminal (biasanya `http://localhost:5173`) — kalau muncul halaman default Vite+React, frontend dasar sudah hidup.

> **Checkpoint 3.**

---

## Langkah 6 — Sambungkan frontend ke backend

Di `frontend/src/App.jsx`, coba fetch endpoint `/api/health` tadi:
```jsx
import { useEffect, useState } from "react";
import axios from "axios";

function App() {
  const [status, setStatus] = useState("loading...");
  useEffect(() => {
    axios.get("http://localhost:5000/api/health")
      .then(res => setStatus(res.data.status))
      .catch(() => setStatus("gagal connect ke backend"));
  }, []);
  return <div>Status backend: {status}</div>;
}
export default App;
```

Kalau muncul tulisan "Status backend: ok" di halaman React, berarti frontend dan backend sudah bisa saling ngomong.

> **Checkpoint 4 — checkpoint terakhir sebelum mulai bikin fitur beneran.**

---

## Langkah 7 — Bangun alur inti tanpa keamanan (form input nilai)

Buat endpoint `POST /api/nilai` di Flask yang terima JSON `{mahasiswa_id, uts, uas, tugas, praktikum}` dan simpan ke tabel `nilai` apa adanya (plain, belum dienkripsi). Buat form sederhana di React yang kirim data ini via `axios.post`, lalu buat endpoint `GET /api/nilai/<id>` + halaman React yang menampilkannya kembali.

Begitu form-submit-simpan-tampil ini jalan, **alur inti sudah selesai** — dari sini, setiap orang tinggal "membungkus" bagian yang jadi tanggung jawabnya:

- **Mario** mengganti kolom `nilai` jadi terenkripsi AES saat disimpan/dibaca (Layer 3).
- **Sabila** menambahkan endpoint upload file yang dienkripsi hybrid (Layer 4).
- **Hafizh** mengganti endpoint dummy login jadi login asli dengan bcrypt (Layer 1).
- **Maulida** menambahkan `ssl_context` di `run.py` (Layer 2).
- **Yudistira** menambah decorator `@require_role(...)` di endpoint-endpoint yang sudah ada (Layer 5).
- **PIC audit log** menambah pemanggilan `audit_log(...)` di titik-titik penting yang sudah ada (Layer 6).

Karena semua bekerja di atas kode yang **sama-sama sudah jalan**, tidak ada yang perlu menunggu — tinggal `git pull` skeleton dari Langkah 1–7 ini, lalu tiap orang kerja di branch masing-masing (`feat/layer1-hash`, `feat/layer2-tls`, dst.).
