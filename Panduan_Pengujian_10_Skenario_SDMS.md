# Panduan Pengujian — 10 Skenario Keamanan SDMS
**Untuk pemula, dijelaskan langkah per langkah dengan bahasa sederhana**

Selamat, implementasinya sudah jalan! Sekarang saatnya **membuktikan** bahwa tiap lapisan keamanan benar-benar bekerja. Ini penting bukan cuma buat nilai — ini adalah bukti nyata yang akan jadi isi Bab IV (Hasil dan Pembahasan) di laporan kalian.

## Cara Pakai Dokumen Ini

- Kerjakan skenario **secara berurutan** (1 → 10). Skenario 1–6 menguji tiap layer sendiri-sendiri, skenario 7–8 menguji semuanya sekaligus (jadi harus 1–6 lulus dulu), skenario 9–10 adalah analisis pembanding.
- **Setiap langkah yang ada tanda 📸, wajib di-screenshot.** Simpan di folder `docs/pengujian/skenario-1/`, `skenario-2/`, dst. Ini nanti langsung jadi lampiran laporan.
- Kalau satu langkah gagal (hasilnya tidak sesuai "Cara Tahu Berhasil"), **jangan panik** — itu artinya ada bug di implementasi, bukan berarti skenarionya salah. Catat error-nya, screenshot juga, lalu perbaiki kode dan ulangi.
- Istilah "server jalan" di bawah = backend Flask kalian aktif (`python run.py`) dan frontend React aktif (`npm run dev`).

---

## Persiapan Alat (lakukan sekali di awal)

| Alat | Fungsi | Cara Dapat |
|---|---|---|
| **DBeaver** atau **phpMyAdmin** | Melihat isi database secara langsung | DBeaver: download di dbeaver.io (gratis). phpMyAdmin: biasanya sudah ada kalau pakai XAMPP |
| **Postman** | Mengirim request ke API tanpa lewat tampilan web (jadi bisa uji backend langsung) | Download di postman.com, install, buat akun gratis |
| **Wireshark** | Menyadap/melihat paket data yang lewat jaringan | Download di wireshark.org |
| **Browser + DevTools** | Chrome/Firefox, tekan F12 untuk buka DevTools (tab Network berguna buat lihat request) | Sudah ada di browser kalian |

Tidak perlu install semua di awal — install saat mau dipakai saja, supaya tidak makan waktu di Hari 1.

---

## Skenario 1: Password Tidak Boleh Tersimpan Polos

**Yang diuji:** Layer 1 (Hash Password)
**Intinya:** Membuktikan kalau password disimpan dalam bentuk acak (hash), bukan tulisan asli, dan sistem login bekerja benar.

### Langkah-langkah
1. Buka web kalian, isi form **registrasi** — misal username `testuser1`, password `RahasiaBanget123`. Submit.
2. Buka **DBeaver/phpMyAdmin**, connect ke database `sdms`, buka tabel `users`.
3. Cari baris dengan username `testuser1`, lihat kolom `password_hash`.
   📸 **Screenshot kolom ini** — harusnya isinya teks acak panjang seperti `$2b$12$KIXQ...` (bukan `RahasiaBanget123`).
4. Balik ke web, coba **login** pakai username & password yang benar tadi.
   📸 **Screenshot halaman setelah berhasil login.**
5. Logout, coba login lagi tapi dengan password yang **sengaja salah** (misal `salahpassword`).
   📸 **Screenshot pesan error/penolakan login.**

### Cara Tahu Berhasil
- ✅ Kolom `password_hash` di database berisi teks acak, bukan `RahasiaBanget123` asli.
- ✅ Login dengan password benar → berhasil masuk.
- ✅ Login dengan password salah → ditolak, muncul pesan error.

### Kalau Gagal
Kalau di database kolomnya masih kelihatan `RahasiaBanget123` — berarti kode belum benar-benar memanggil `bcrypt.hashpw()` sebelum simpan ke database. Cek fungsi register di backend.

---

## Skenario 2: Data yang Dikirim Tidak Bisa Disadap (TLS)

**Yang diuji:** Layer 2 (TLS/HTTPS)
**Intinya:** Membuktikan kalau data yang lewat antara browser dan server tidak bisa dibaca orang lain yang "nguping" di jaringan.

### Langkah-langkah
1. Buka **Wireshark**, pilih interface jaringan yang aktif (biasanya `Wi-Fi` atau `Loopback` kalau semua di 1 laptop), klik tombol biru untuk mulai menangkap paket (*capture*).
2. Di kolom filter Wireshark, ketik: `tcp.port == 5000` (sesuaikan port backend kalian), tekan Enter.
3. Balik ke web, lakukan **login** seperti biasa (pastikan HTTPS sudah aktif, URL diawali `https://`).
4. Kembali ke Wireshark, cari paket yang barusan tertangkap, klik kanan → **Follow → HTTP Stream** (atau TLS Stream).
   📸 **Screenshot isi paketnya** — harusnya kelihatan teks acak/tidak terbaca (ciphertext), bukan tulisan `username=testuser1&password=...` yang jelas terbaca.
5. **Sebagai pembanding**, matikan sementara TLS di backend (jalankan tanpa `ssl_context`, akses lewat `http://` bukan `https://`), ulangi capture Wireshark, lakukan login lagi.
   📸 **Screenshot ini juga** — kali ini harusnya kelihatan `username=` dan `password=` dalam teks jelas. Ini bukti pembanding bahwa tanpa TLS, data bisa dibaca siapa saja yang menyadap jaringan.
6. Nyalakan lagi TLS-nya setelah selesai (jangan lupa!).

### Cara Tahu Berhasil
- ✅ Saat HTTPS aktif: isi paket berupa teks acak (tidak terbaca).
- ✅ Saat HTTP (tanpa TLS): isi paket terbaca jelas, termasuk password — ini justru **harus** terjadi supaya jadi bukti pembanding yang valid.

---

## Skenario 3: Data di Database Tidak Bisa Dibaca Langsung

**Yang diuji:** Layer 3 (Enkripsi AES di Database)
**Intinya:** Membuktikan kalau seseorang berhasil "masuk" ke database (skenario terburuk), dia tetap tidak bisa membaca nilai mahasiswa.

### Langkah-langkah
1. Login sebagai mahasiswa di web, **input nilai** (UTS, UAS, Tugas, Praktikum) lewat form.
2. Buka DBeaver/phpMyAdmin, buka tabel `nilai`.
   📸 **Screenshot isi tabel tersebut** — kolom `uts_enc`, `uas_enc`, dll harus berisi data acak (bytes/ciphertext), **bukan** angka nilai yang bisa dibaca langsung seperti `85`.
3. Coba baca ulang nilainya lewat **web** (halaman "lihat nilai").
   📸 **Screenshot halaman ini** — di sini nilainya harus muncul normal (angka asli), karena aplikasi yang mendekripsi otomatis pakai kunci AES-nya.

### Cara Tahu Berhasil
- ✅ Lihat langsung di database → data acak, tidak terbaca.
- ✅ Lihat lewat aplikasi (yang punya kunci dekripsi) → data normal, terbaca dengan benar.

---

## Skenario 4: File yang Diunggah Terenkripsi & Kuncinya Dilindungi RSA

**Yang diuji:** Layer 4 (Hybrid Encryption: AES + RSA)
**Intinya:** File yang diupload tidak bisa dibuka orang lain, dan kunci untuk membukanya (kunci AES) juga terkunci lagi pakai RSA.

### Langkah-langkah
1. Login, **upload dokumen** (misal PDF/gambar) lewat form upload di web.
2. Buka folder penyimpanan file di server (folder tempat backend menyimpan file upload).
   📸 **Screenshot nama file-nya** — harus berekstensi `.enc`, bukan `.pdf` atau `.jpg` asli.
3. Coba **buka file `.enc` itu langsung** pakai aplikasi biasa (misal buka pakai Adobe/Preview).
   📸 **Screenshot pesan error** — harusnya gagal dibuka/rusak/tidak dikenali.
4. Buka database, cek tabel `files`, lihat kolom `encrypted_aes_key`.
   📸 **Screenshot ini** — harus berisi data acak (bukan kunci AES polos).
5. Balik ke web, klik tombol **download/lihat dokumen** sebagai user yang berwenang.
   📸 **Screenshot file berhasil terbuka normal** — buktinya sistem berhasil dekripsi berjenjang (buka kunci AES pakai RSA, lalu buka file pakai AES).

### Cara Tahu Berhasil
- ✅ File di server berekstensi `.enc` dan tidak bisa dibuka aplikasi biasa.
- ✅ Kunci AES di database juga terenkripsi (bukan polos).
- ✅ Lewat aplikasi (proses resmi), file bisa dibuka normal dan isinya utuh (coba bandingkan file asli vs hasil download, harus identik).

---

## Skenario 5: Mahasiswa Tidak Bisa Mengintip Data Orang Lain (RBAC)

**Yang diuji:** Layer 5 (Role-Based Access Control)
**Intinya:** Setiap role (mahasiswa/dosen/admin) cuma boleh akses data & fitur yang memang jadi haknya.

### Langkah-langkah — pakai Postman (lebih gampang dari klik-klik web)
1. Login sebagai **mahasiswa A** di web/Postman, catat token/session yang didapat setelah login.
2. Di Postman, buat request `GET` ke endpoint nilai mahasiswa lain, misal `/api/nilai/<id_mahasiswa_B>`, sertakan token mahasiswa A tadi di header.
   📸 **Screenshot response-nya** — harusnya **403 Forbidden**, bukan data nilai mahasiswa B.
3. Coba juga akses endpoint yang harusnya khusus dosen/admin (misal `/api/admin/users`) pakai token mahasiswa A.
   📸 **Screenshot response 403 lagi.**
4. Sebagai pembanding, login sebagai **dosen**, coba akses endpoint nilai mahasiswa yang memang jadi bimbingannya.
   📸 **Screenshot ini berhasil (200 OK, data muncul)** — bukti kalau RBAC memang membedakan berdasarkan role, bukan asal blokir semua.

### Cara Tahu Berhasil
- ✅ Mahasiswa akses data mahasiswa lain → ditolak (403).
- ✅ Mahasiswa akses halaman admin/dosen → ditolak (403).
- ✅ Dosen akses data yang memang berwenang → berhasil (200).

---

## Skenario 6: Semua Aktivitas Tercatat Otomatis (Audit Log)

**Yang diuji:** Layer 6 (Audit Logging)
**Intinya:** Setiap kali ada perubahan data, sistem otomatis mencatat "siapa melakukan apa kapan" — dan user biasa tidak bisa mengubah/menghapus catatan ini.

### Langkah-langkah
1. Login, lakukan beberapa aksi: **tambah** nilai baru, **ubah** nilai yang sudah ada, **hapus** satu data (kalau ada fitur hapus).
2. Buka database, buka tabel `audit_log`.
   📸 **Screenshot isi tabelnya** — harus ada baris baru untuk tiap aksi tadi, dengan kolom `user_id`, `action` (CREATE/UPDATE/DELETE), `object`, dan `timestamp` yang sesuai waktu kalian melakukannya.
3. Cocokkan satu per satu: aksi yang kalian lakukan tadi vs baris di `audit_log` — pastikan jumlah dan jenisnya match.
4. Coba, sebagai user biasa (bukan lewat akses admin database langsung), cari cara untuk **menghapus/mengubah** isi `audit_log` lewat aplikasi web/API — harusnya **tidak ada endpoint atau fitur untuk itu** di aplikasi.

### Cara Tahu Berhasil
- ✅ Setiap aksi (create/update/delete) yang dilakukan lewat web punya baris log yang sesuai.
- ✅ Tidak ada cara untuk user biasa mengubah/menghapus log lewat aplikasi (hanya bisa dilihat lewat akses database langsung, yang notabene sudah di luar kendali aplikasi).

---

## Skenario 7: Upload Dokumen — Semua Layer Jalan Bersamaan

**Yang diuji:** Layer 1, 2, 4, 5, 6 sekaligus
**Intinya:** Ini "ujian akhir" untuk fitur upload — membuktikan semua layer yang relevan aktif secara bersamaan dalam satu alur nyata, bukan cuma diuji terpisah-pisah.

### Langkah-langkah
1. Nyalakan Wireshark (seperti Skenario 2), siapkan DBeaver/phpMyAdmin terbuka juga.
2. **Login** sebagai mahasiswa (Layer 1 aktif — sesi/token valid).
3. **Upload dokumen** lewat web (pastikan pakai HTTPS — Layer 2).
4. Setelah upload selesai, cek satu-satu:
   - 📸 Trafik di Wireshark saat upload → terenkripsi (tidak terbaca).
   - 📸 File di server → berekstensi `.enc` (Layer 4).
   - 📸 Kolom `encrypted_aes_key` di tabel `files` → terisi data acak (Layer 4).
   - 📸 Tabel `audit_log` → ada baris baru mencatat aksi upload (Layer 6).
5. (Layer 5/RBAC otomatis ikut teruji karena hanya mahasiswa yang login yang bisa sampai ke tahap upload ini.)

### Cara Tahu Berhasil
Semua 4 bukti di atas (poin 4) muncul dan benar **dalam satu kali proses upload** — bukan diuji satu-satu terpisah seperti skenario sebelumnya, tapi dibuktikan terjadi bersamaan dalam 1 alur nyata.

---

## Skenario 8: Akses Dokumen — Dosen Bisa, yang Lain Tidak

**Yang diuji:** Layer 2, 4, 5, 6 sekaligus
**Intinya:** Membuktikan dosen yang berwenang bisa membuka dokumen mahasiswa bimbingannya, tapi orang lain (mahasiswa lain / dosen lain) tidak bisa.

### Langkah-langkah
1. Login sebagai **dosen yang berwenang** (dosen pembimbing mahasiswa yang upload dokumen di Skenario 7).
2. Buka/download dokumen mahasiswa bimbingannya.
   📸 **Screenshot dokumen berhasil terbuka dengan isi yang utuh** (bandingkan dengan file asli sebelum upload, harus identik).
3. Cek tabel `audit_log` lagi — harus ada baris baru mencatat aksi "akses dokumen" oleh dosen ini.
   📸 **Screenshot baris log ini.**
4. Logout, login sebagai **mahasiswa lain** (bukan pemilik dokumen) atau **dosen lain** (bukan pembimbing), coba akses dokumen yang sama.
   📸 **Screenshot respons penolakan (403 Forbidden).**

### Cara Tahu Berhasil
- ✅ Dosen berwenang → berhasil buka dokumen, isi file utuh.
- ✅ User tidak berwenang → ditolak (403).
- ✅ Log mencatat siapa yang mengakses.

---

## Skenario 9: Buktikan Sistem Benar-Benar Lebih Aman "Sebelum vs Sesudah"

**Yang diuji:** Semua layer, dibandingkan
**Intinya:** Ini bagian paling meyakinkan untuk laporan — kalian sengaja **mematikan** keamanan dulu, buktikan serangan berhasil (sistem lemah), lalu **nyalakan lagi**, buktikan serangan yang sama gagal total.

### Langkah-langkah
**Tahap "sebelum" (tanpa proteksi):**
1. Nonaktifkan sementara satu-dua layer (misalnya: comment dulu bagian enkripsi AES di kode, atau jalankan tanpa HTTPS, atau nonaktifkan cek RBAC-nya sementara — lakukan di branch/copy kode terpisah, **jangan di kode utama**, supaya aman).
2. Coba serang: akses database langsung untuk baca nilai (harusnya sekarang kebaca polos), atau coba akses lintas role tanpa ditolak.
   📸 **Screenshot bukti serangan berhasil** — data kebaca polos / akses tanpa proteksi lolos.

**Tahap "sesudah" (proteksi aktif lagi):**
3. Aktifkan lagi semua layer keamanan (kembali ke kode utama/aslinya).
4. Ulangi persis serangan yang sama seperti tadi.
   📸 **Screenshot bukti serangan gagal** — data tetap ciphertext / akses ditolak (403).
5. Cek `audit_log` — upaya serangan tadi (di tahap "sesudah") harusnya **tercatat**, sebagai bukti sistem sadar ada percobaan mencurigakan.

### Cara Tahu Berhasil
- ✅ Tanpa proteksi: serangan berhasil (data bocor/akses tembus).
- ✅ Dengan proteksi: serangan yang sama gagal total, dan tercatat di log.

Ini nanti jadi tabel perbandingan "before vs after" paling kuat di Bab IV laporan kalian.

---

## Skenario 10: Seberapa "Berat" Enkripsi Hybrid Dibanding AES Biasa

**Yang diuji:** Layer 4 (performa)
**Intinya:** Mengukur berapa lama waktu proses enkripsi AES biasa dibanding Hybrid (AES+RSA), untuk 3 ukuran file berbeda.

### Langkah-langkah
1. Siapkan 3 file contoh: ukuran ±500KB, ±2MB, ±10MB (bisa file PDF/gambar asal-asalan, yang penting ukurannya pas).
2. Buat skrip Python sederhana untuk mengukur waktu (bisa taruh di `backend/benchmark.py`):
```python
import time

def benchmark(func, data, iterations=30):
    times = []
    for _ in range(iterations):
        start = time.perf_counter()
        func(data)
        end = time.perf_counter()
        times.append(end - start)
    return sum(times) / len(times)  # rata-rata

# Contoh pemakaian:
# avg_aes = benchmark(encrypt_aes_only, file_bytes)
# avg_hybrid = benchmark(encrypt_file_hybrid, file_bytes)
# print(f"AES murni: {avg_aes:.4f}s | Hybrid: {avg_hybrid:.4f}s")
```
3. Jalankan skrip ini untuk **masing-masing** dari 3 file, dengan **masing-masing** 2 metode (AES murni vs Hybrid), 30 kali percobaan (`iterations=30`) tiap kombinasi.
4. Catat semua hasil rata-ratanya ke tabel (Excel/spreadsheet), contoh:

| Ukuran File | AES Murni (rata-rata) | Hybrid AES+RSA (rata-rata) |
|---|---|---|
| 500KB | ... detik | ... detik |
| 2MB | ... detik | ... detik |
| 10MB | ... detik | ... detik |

5. Dari tabel ini, buat grafik batang sederhana (pakai Excel/Google Sheets) untuk ditaruh di laporan.

### Cara Tahu Berhasil
- ✅ Semua 6 angka (3 ukuran × 2 metode) berhasil dicatat.
- ✅ Pola masuk akal: Hybrid sedikit lebih lambat dari AES murni (karena ada proses tambahan enkripsi RSA untuk kunci), tapi selisihnya kecil karena RSA cuma dipakai untuk kunci AES yang ukurannya kecil (32 byte), bukan untuk seluruh isi file.

---

## Rekap Checklist Akhir

Centang kalau sudah selesai dan sudah di-screenshot:

- [ ] Skenario 1 — Hash Password
- [ ] Skenario 2 — TLS / MitM
- [ ] Skenario 3 — Kebocoran Database
- [ ] Skenario 4 — Hybrid Encryption File
- [ ] Skenario 5 — RBAC
- [ ] Skenario 6 — Audit Logging
- [ ] Skenario 7 — Upload End-to-End
- [ ] Skenario 8 — Akses End-to-End
- [ ] Skenario 9 — Before/After Security
- [ ] Skenario 10 — Performa AES vs Hybrid

Setelah semua tercentang, kalian sudah punya **semua bahan mentah** untuk menulis Bab IV (Hasil dan Pembahasan) — tinggal susun tiap skenario jadi: apa yang diuji → apa yang dilakukan → screenshot bukti → kesimpulan singkat.
