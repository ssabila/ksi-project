# Panduan Implementasi Darurat — SDMS Multi-Layer Security
**Kelompok 2 – 3SI2 | Mata Kuliah Keamanan Sistem Informasi**
**Status: Minggu ke-13, implementasi 0% → butuh mode kompresi penuh**

---

## 0. Ringkasan Situasi

Menurut Bab IV proposal, jadwal aslinya adalah:

| Minggu | Rencana |
|---|---|
| 9 | Studi literatur & analisis kebutuhan |
| 10 | Perancangan sistem/arsitektur |
| 11–12 | Implementasi & pengembangan |
| 12–13 | Pengujian & evaluasi |
| 13–14 | Penyusunan laporan & presentasi |

Realitanya: sudah Minggu 13, implementasi belum ada. Artinya **fase literatur, desain, implementasi, pengujian, dan laporan harus dipadatkan jadi ±10–12 hari kerja paralel**, bukan berurutan seperti rencana awal. Studi literatur dan desain arsitektur sebenarnya sudah "selesai" karena sudah tertuang lengkap di proposal (Bab II & III) — itu modal besar, tinggal dieksekusi jadi kode.

**Prinsip kerja yang wajib dipegang:**
1. **Bangun alur inti (tanpa keamanan) dulu** — form input nilai → simpan → tampil. Baru setelah jalan, tempelkan layer keamanan satu per satu di atasnya.
2. **Semua orang mulai coding di hari yang sama**, tidak menunggu layer lain selesai — gunakan *stub*/mock untuk dependensi antar-layer (lihat §4).
3. **Skenario pengujian dikerjakan sambil jalan**, bukan menunggu semua layer selesai total.
4. **Jangan kejar kesempurnaan** — target: sistem yang *provably works* untuk skenario di Bab III, bukan sistem produksi.

---

## 1. Yang Perlu Diluruskan Dulu (5 menit, sebelum mulai coding)

Ada dua inkonsistensi kecil di proposal yang harus disepakati kelompok supaya tidak ada anggota yang implementasi beda arah:

- **Hash password: bcrypt vs SHA-256.** Bab III (3.2.1) menyebut Layer 1 pakai **bcrypt**, tapi Tabel 2.2 dan ringkasan Bab II menyebut **SHA-256**. → **Pakai bcrypt** (via `passlib` atau `bcrypt` Python package) — ini yang sesuai praktik nyata karena bcrypt punya salt otomatis + adaptive cost, sedangkan SHA-256 murni tidak aman untuk password. Cukup catat di laporan bahwa "SHA-256" di tabel dimaksudkan untuk integritas file/log, bukan password.
- **Penomoran layer di Bab V tidak konsisten dengan Bab III.** Bab III: L1=Hash, L2=TLS, L3=AES DB, L4=Hybrid Encryption (file+RSA), L5=RBAC, L6=Audit Log. Tapi Bab V menulis "Layer 4 & 5" untuk Sabila (isinya = Layer 4 di Bab III) dan "Layer 6" untuk Yudistira (isinya = RBAC = Layer 5 di Bab III). **Audit Logging (Layer 6 asli) tidak punya PIC eksplisit di Bab V** — kemungkinan besar ini tanggung jawab Zakia (koordinator testing) atau perlu dibagi ke salah satu anggota yang selesai duluan. **Putuskan ini di grup chat kelompok sekarang juga**, karena tanpa audit logging, Skenario 6, 7, 8, dan 9 tidak bisa lulus.

---

## 2. Setup Proyek (Hari 1, pagi — dikerjakan bareng-bareng via call)

### 2.1 Struktur repo
```
sdms-multilayer/
├── backend/
│   ├── app/
│   │   ├── __init__.py
│   │   ├── models.py          # SQLAlchemy models
│   │   ├── auth.py            # Layer 1: hash password, login/register
│   │   ├── crypto/
│   │   │   ├── aes_db.py      # Layer 3
│   │   │   ├── hybrid_file.py # Layer 4
│   │   │   └── keys.py        # RSA keygen/load
│   │   ├── rbac.py            # Layer 5
│   │   ├── audit.py           # Layer 6
│   │   └── routes/
│   ├── certs/                 # Layer 2: sertifikat TLS self-signed
│   ├── requirements.txt
│   └── run.py
├── frontend/                  # React (Vite)
│   └── src/
├── docs/
│   ├── pengujian/              # screenshot & log tiap skenario
│   └── laporan/
└── README.md
```

### 2.2 Dependencies backend
```bash
python -m venv venv && source venv/bin/activate
pip install flask flask-sqlalchemy flask-cors flask-jwt-extended \
            cryptography bcrypt pymysql python-dotenv
```

### 2.3 Git workflow (supaya 6 orang tidak saling timpa)
- Branch per layer: `feat/layer1-hash`, `feat/layer2-tls`, `feat/layer3-aes-db`, `feat/layer4-hybrid`, `feat/layer5-rbac`, `feat/layer6-audit`.
- Semua branch base dari `main` yang berisi skeleton Flask + React kosong (buat ini duluan, ±1 jam, siapa saja yang paling cepat siap).
- PR ke `main` begitu modul individual lulus unit test sendiri — jangan tunggu integrasi penuh.
- Merge order yang disarankan: L1 → L2 → L3 → L4 → L5 → L6, tapi **development-nya paralel dari hari 1**, hanya urutan merge yang bertahap.

### 2.4 Skema database minimal
```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255),      -- bcrypt hash
    role ENUM('mahasiswa','dosen','admin')
);

CREATE TABLE nilai (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_id INT,
    uts_enc VARBINARY(255),          -- ciphertext AES
    uas_enc VARBINARY(255),
    tugas_enc VARBINARY(255),
    praktikum_enc VARBINARY(255),
    ips_enc VARBINARY(255),
    ipk_enc VARBINARY(255)
);

CREATE TABLE files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_id INT,
    filepath VARCHAR(255),           -- path ke file .enc
    encrypted_aes_key VARBINARY(512) -- AES key yang sudah di-RSA-kan
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
Trigger audit log otomatis (contoh untuk tabel `nilai`) supaya Skenario 6 (pencatatan otomatis, tidak bisa dimanipulasi user biasa) lulus:
```sql
CREATE TRIGGER trg_nilai_update
AFTER UPDATE ON nilai
FOR EACH ROW
INSERT INTO audit_log (user_id, action, object, status)
VALUES (@current_user_id, 'UPDATE', CONCAT('nilai:', NEW.id), 'SUCCESS');
```
> Catatan: `@current_user_id` perlu di-set di awal transaksi dari aplikasi (`SET @current_user_id = %s`) karena trigger DB murni tidak tahu siapa user aplikasi yang login.

---

## 2.5 Langkah Konkret: Dari Nol Sampai Web Dasar Jalan (Hari 1)

Ini bagian yang paling penting untuk mulai **hari ini juga**. Tujuannya: di akhir hari 1, ada web yang bisa diakses di browser, mahasiswa bisa isi form nilai, data tersimpan ke database, dan muncul lagi saat dibuka — **tanpa enkripsi/keamanan sama sekali dulu**. Keamanan baru ditempel di atas alur ini (lihat §3 dan §4). Urutan di bawah ini dikerjakan berurutan oleh 1-2 orang yang paling siap alat (laptop, sudah install Node/Python), lalu begitu server nyala, 4 orang lainnya `git pull` dan langsung mulai kerja di layer masing-masing secara paralel.

### Langkah 1 — Pastikan tools terpasang
Cek dulu satu-satu (jalankan di terminal):
```bash
node -v      # butuh v18+
python3 --version   # butuh 3.10+
mysql --version      # atau psql --version kalau pakai PostgreSQL
git --version
```
Kalau ada yang belum ada, install dulu sebelum lanjut (Node dari nodejs.org, Python dari python.org, MySQL Community Server atau XAMPP untuk yang mau GUI).

### Langkah 2 — Buat repo & struktur folder
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

### Langkah 3 — Backend: Flask jalan dulu (target: "Hello World" di browser)
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
Buka `http://localhost:5000/api/health` di browser — kalau muncul `{"status":"ok"}`, backend dasar sudah hidup. **Ini checkpoint pertama, jangan lanjut sebelum ini berhasil.**

### Langkah 4 — Database: buat skema & hubungkan ke Flask
Buat database dulu (contoh MySQL):
```sql
CREATE DATABASE sdms;
```
Lalu jalankan skema tabel dari §2.4 di atas (users, nilai, files, audit_log) di database `sdms` tersebut — bisa lewat phpMyAdmin, DBeaver, atau `mysql -u root -p sdms < schema.sql`.

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
Test dengan endpoint sementara untuk insert dummy data, pastikan baris masuk ke tabel `nilai` saat dicek lewat DBMS. **Checkpoint kedua: data bisa masuk & terbaca dari database.**

### Langkah 5 — Frontend: React (Vite) jalan dulu
```bash
cd ../frontend
npm create vite@latest . -- --template react
npm install
npm install axios react-router-dom
npm run dev
```
Buka URL yang muncul di terminal (biasanya `http://localhost:5173`) — kalau muncul halaman default Vite+React, frontend dasar sudah hidup. **Checkpoint ketiga.**

### Langkah 6 — Sambungkan frontend ke backend
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
Kalau muncul tulisan "Status backend: ok" di halaman React, berarti **frontend dan backend sudah bisa saling ngomong**. Ini checkpoint terakhir sebelum mulai bikin fitur beneran.

### Langkah 7 — Bangun alur inti tanpa keamanan (form input nilai)
Buat endpoint `POST /api/nilai` di Flask yang terima JSON `{mahasiswa_id, uts, uas, tugas, praktikum}` dan simpan ke tabel `nilai` apa adanya (plain, belum dienkripsi). Buat form sederhana di React yang kirim data ini via `axios.post`, lalu buat endpoint `GET /api/nilai/<id>` + halaman React yang menampilkannya kembali.

Begitu form-submit-simpan-tampil ini jalan, **alur inti sudah selesai** — dari sini, setiap orang tinggal "membungkus" bagian yang jadi tanggung jawabnya:
- Mario mengganti kolom `nilai` jadi terenkripsi AES saat disimpan/dibaca (Layer 3).
- Sabila menambahkan endpoint upload file yang dienkripsi hybrid (Layer 4).
- Hafizh mengganti endpoint dummy login jadi login asli dengan bcrypt (Layer 1).
- Maulida menambahkan `ssl_context` di `run.py` (Layer 2).
- Yudistira menambah decorator `@require_role(...)` di endpoint-endpoint yang sudah ada (Layer 5).
- PIC audit log menambah pemanggilan `audit_log(...)` di titik-titik penting yang sudah ada (Layer 6).

Karena semua bekerja di atas kode yang **sama-sama sudah jalan**, tidak ada yang perlu menunggu — tinggal `git pull` skeleton dari langkah 1-7 ini, lalu tiap orang kerja di branch masing-masing sesuai §2.3.

---

## 3. Rencana Kerja Terkompresi (asumsi 11 hari kerja tersisa: Minggu 13–14)

Distribusi hari ini **fleksibel**, sesuaikan dengan sisa hari efektif kelompok kalian — intinya polanya: **Hari 1–2 skeleton, Hari 3–7 implementasi paralel + integrasi bertahap, Hari 8–9 testing penuh, Hari 10–11 laporan & presentasi.**

| Hari | Fokus | PIC |
|---|---|---|
| 1 | Setup repo, skeleton Flask+React, skema DB, alur "input nilai tanpa enkripsi" jalan end-to-end | Semua (call bareng) |
| 2–3 | Layer 1 (hash+login) & Layer 2 (TLS) selesai & lulus unit test sendiri | Hafizh, Maulida |
| 2–4 | Layer 3 (AES DB) selesai, terintegrasi ke model `nilai` | Mario |
| 2–5 | Layer 4 (hybrid file encryption + RSA keygen via OpenSSL) selesai | Sabila |
| 3–5 | Layer 5 (RBAC middleware + dashboard per role di frontend) | Yudistira |
| 4–5 | Layer 6 (audit logging + trigger DB) — **pastikan PIC final dari §1** | (hasil kesepakatan) |
| 6–7 | Integrasi semua layer, uji end-to-end manual (Skenario 7 & 8) | Semua |
| 8 | Jalankan Skenario 1–6 (per-layer) + dokumentasi screenshot/log | Zakia koordinir, semua eksekusi bagian masing-masing |
| 9 | Jalankan Skenario 9 (before/after security) & 10 (benchmark performa AES vs Hybrid) | Zakia + Mario/Sabila |
| 10 | Susun Bab IV (Hasil & Pembahasan) dari data pengujian, finalisasi laporan | Semua, dibagi per bab |
| 11 | Review laporan, siapkan slide presentasi, gladi bersih demo | Semua |

**Jika waktu makin mepet**, urutan pemangkasan skenario yang paling aman (dari yang paling boleh disederhanakan ke paling wajib dipertahankan): Skenario 10 (performa) bisa dipersempit ke 1 ukuran file saja daripada 3×30 iterasi penuh → Skenario 9 (before/after) bisa disederhanakan jadi 1 contoh serangan per layer → **Skenario 1–8 (fungsional per layer + end-to-end) jangan dipangkas**, karena itu inti pembuktian sistem bekerja.

---

## 4. Panduan Teknis per Layer

### Layer 1 — Hash Password (Hafizh)
```python
import bcrypt

def hash_password(plain: str) -> bytes:
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt())

def verify_password(plain: str, hashed: bytes) -> bool:
    return bcrypt.checkpw(plain.encode(), hashed)
```
Endpoint `/register` dan `/login` di Flask, gunakan `flask-jwt-extended` untuk sesi login (dibutuhkan RBAC di Layer 5). **Stub untuk tim lain**: expose endpoint dummy `/login` yang selalu mengembalikan token valid, supaya Yudistira & lainnya bisa mulai kerja tanpa menunggu implementasi asli selesai.

### Layer 2 — TLS (Maulida)
Untuk lingkungan lokal (bukan production), cukup sertifikat self-signed:
```bash
openssl req -x509 -newkey rsa:2048 -nodes \
  -keyout certs/key.pem -out certs/cert.pem -days 30
```
```python
if __name__ == "__main__":
    app.run(ssl_context=('certs/cert.pem', 'certs/key.pem'), port=5000)
```
Uji dengan Wireshark: filter `tcp.port == 5000`, buktikan payload tidak plaintext saat HTTPS aktif, lalu ulangi dengan HTTP biasa sebagai pembanding (ini persis Skenario 2).

### Layer 3 — AES Database Encryption (Mario)
```python
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.primitives import padding
import os

AES_KEY = os.environ["DB_AES_KEY"]  # 32 bytes, simpan di .env, JANGAN commit

def encrypt_aes(plaintext: bytes) -> bytes:
    iv = os.urandom(16)
    padder = padding.PKCS7(128).padder()
    padded = padder.update(plaintext) + padder.finalize()
    cipher = Cipher(algorithms.AES(AES_KEY), modes.CBC(iv))
    ct = cipher.encryptor().update(padded)
    return iv + ct  # simpan IV di depan ciphertext

def decrypt_aes(data: bytes) -> bytes:
    iv, ct = data[:16], data[16:]
    cipher = Cipher(algorithms.AES(AES_KEY), modes.CBC(iv))
    padded = cipher.decryptor().update(ct)
    unpadder = padding.PKCS7(128).unpadder()
    return unpadder.update(padded) + unpadder.finalize()
```
Terapkan `encrypt_aes`/`decrypt_aes` di setiap query ke kolom `*_enc` pada tabel `nilai`.

### Layer 4 — Hybrid Encryption / Envelope Encryption (Sabila)
```bash
# Generate pasangan kunci RSA sekali di awal
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -out public.pem
```
```python
from cryptography.hazmat.primitives.asymmetric import padding as rsa_padding
from cryptography.hazmat.primitives import hashes, serialization

def encrypt_file(filepath: str, out_path: str):
    aes_key = os.urandom(32)
    with open(filepath, "rb") as f:
        data = f.read()
    enc_data = encrypt_aes_generic(data, aes_key)   # AES-256-CBC seperti di atas
    with open(out_path, "wb") as f:
        f.write(enc_data)

    pub_key = serialization.load_pem_public_key(open("public.pem","rb").read())
    encrypted_aes_key = pub_key.encrypt(
        aes_key,
        rsa_padding.OAEP(mgf=rsa_padding.MGF1(hashes.SHA256()),
                          algorithm=hashes.SHA256(), label=None)
    )
    return encrypted_aes_key  # simpan ini di kolom files.encrypted_aes_key
```
Dekripsi: private key membuka `encrypted_aes_key` → dapat AES key asli → dekripsi isi file `.enc`.

### Layer 5 — RBAC (Yudistira)
```python
from functools import wraps
from flask_jwt_extended import get_jwt

def require_role(*allowed_roles):
    def decorator(fn):
        @wraps(fn)
        def wrapper(*args, **kwargs):
            role = get_jwt().get("role")
            if role not in allowed_roles:
                audit_log(action="ACCESS_DENIED", object=fn.__name__, status="FAILED")
                return {"error": "Forbidden"}, 403
            return fn(*args, **kwargs)
        return wrapper
    return decorator

@app.route("/api/nilai/<int:mhs_id>")
@require_role("dosen", "admin")
def get_nilai(mhs_id):
    ...
```
Frontend React: simpan `role` dari JWT payload, render dashboard/menu berbeda per role (`ProtectedRoute` component sederhana yang cek role sebelum render halaman).

### Layer 6 — Audit Logging (PIC hasil kesepakatan §1)
```python
def audit_log(user_id=None, action="", object="", status="SUCCESS"):
    entry = AuditLog(user_id=user_id, action=action, object=object, status=status)
    db.session.add(entry)
    db.session.commit()
```
Panggil `audit_log(...)` di setiap titik penting: login sukses/gagal, upload file, akses dokumen, RBAC denied (lihat contoh di Layer 5), perubahan nilai (lengkapi dengan trigger DB di §2.4 sebagai lapisan kedua yang tidak bisa dibypass dari level aplikasi).

---

## 5. Checklist Pengujian → Bukti untuk Laporan Bab IV

Dokumentasikan **screenshot + hasil mentah** untuk tiap skenario, simpan di `docs/pengujian/skenario-N/`:

- [ ] **S1** Hash password — screenshot kolom `password_hash` di DB (bukan plaintext) + login sukses/gagal
- [ ] **S2** TLS/MitM — screenshot capture Wireshark saat HTTPS (ciphertext) vs HTTP (plaintext)
- [ ] **S3** Kebocoran DB — screenshot tabel `nilai` diakses langsung via DBMS, tampil ciphertext
- [ ] **S4** Integritas file & hybrid — screenshot file `.enc` tidak bisa dibuka + kolom `encrypted_aes_key` di DB
- [ ] **S5** RBAC — screenshot response HTTP 403 untuk akses lintas peran (pakai Postman)
- [ ] **S6** Audit logging — screenshot tabel `audit_log` cocok dengan aksi yang dilakukan
- [ ] **S7** End-to-end upload — rekam video/screenshot alur lengkap upload dokumen dengan semua layer aktif
- [ ] **S8** End-to-end akses — sama, untuk alur akses/download oleh dosen berwenang vs tidak berwenang
- [ ] **S9** Before/after security — matikan sementara modul keamanan, buktikan serangan berhasil; nyalakan lagi, buktikan gagal — dokumentasikan keduanya
- [ ] **S10** Performa AES vs Hybrid — jalankan skrip benchmark (30 iterasi × 3 ukuran file), simpan hasil sebagai tabel/grafik untuk laporan

---

## 6. Struktur Laporan yang Perlu Dilengkapi

Bab I–III sudah ada dari proposal (tinggal disesuaikan tense-nya dari rencana ke aktual). Yang perlu ditulis baru:
- **Bab IV — Hasil dan Pembahasan**: hasil tiap skenario pengujian (§5), tabel perbandingan performa AES vs Hybrid dari S10, pembahasan resistensi dari S9.
- **Bab V — Penutup**: kesimpulan menjawab 3 rumusan masalah di Bab I, keterbatasan (termasuk kejujuran soal keterbatasan waktu jika relevan), saran pengembangan.
- Lampiran: source code (link repo), screenshot pengujian.

---

## 7. Jika Ada Anggota yang Stuck

- Modul terberat biasanya Layer 4 (hybrid encryption) dan Layer 6 (audit logging terintegrasi ke banyak titik) — anggota yang selesai lebih dulu (kemungkinan Layer 1/2) sebaiknya standby membantu dua modul ini di hari 4–5.
- Jangan debug sendirian lebih dari ~45 menit untuk error kriptografi (padding, IV, key length) — ini kelas bug yang sering butuh sepasang mata kedua karena errornya "silent" (hasil dekripsi salah tanpa exception jelas).
