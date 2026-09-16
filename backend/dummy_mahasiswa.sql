-- Jalankan setelah tabel users tersedia.
-- Password hash di bawah adalah bcrypt, bukan plaintext.
-- Aman dijalankan berulang kali karena username memakai INSERT IGNORE.

INSERT IGNORE INTO users (username, password_hash, role, created_at) VALUES
('budi', '$2b$12$VHBCoEW7Hh3rZZ2BjHd8Zut8YVn4eRiGjLUpDz71dhJGhSSeI9Nqe', 'mahasiswa', CURRENT_TIMESTAMP),
('citra', '$2b$12$VHBCoEW7Hh3rZZ2BjHd8Zut8YVn4eRiGjLUpDz71dhJGhSSeI9Nqe', 'mahasiswa', CURRENT_TIMESTAMP),
('dewi', '$2b$12$VHBCoEW7Hh3rZZ2BjHd8Zut8YVn4eRiGjLUpDz71dhJGhSSeI9Nqe', 'mahasiswa', CURRENT_TIMESTAMP),
('eko', '$2b$12$VHBCoEW7Hh3rZZ2BjHd8Zut8YVn4eRiGjLUpDz71dhJGhSSeI9Nqe', 'mahasiswa', CURRENT_TIMESTAMP),
('fitri', '$2b$12$VHBCoEW7Hh3rZZ2BjHd8Zut8YVn4eRiGjLUpDz71dhJGhSSeI9Nqe', 'mahasiswa', CURRENT_TIMESTAMP);

-- Hash di atas menggunakan password demo: Mahasiswa123!
-- Jika password tidak cocok di lingkunganmu, buat hash baru:
-- python -c "import bcrypt; print(bcrypt.hashpw(b'Mahasiswa123!', bcrypt.gensalt()).decode())"
