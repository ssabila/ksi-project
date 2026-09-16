CREATE DATABASE IF NOT EXISTS sdms;
USE sdms;

CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('mahasiswa', 'dosen', 'admin') NOT NULL DEFAULT 'mahasiswa',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS nilai (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_id INT NOT NULL,
    uts_enc VARBINARY(255) NOT NULL,
    uas_enc VARBINARY(255) NOT NULL,
    tugas_enc VARBINARY(255) NOT NULL,
    praktikum_enc VARBINARY(255) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_nilai_mahasiswa (mahasiswa_id)
);

CREATE TABLE IF NOT EXISTS files (
    id INT PRIMARY KEY AUTO_INCREMENT,
    mahasiswa_id INT NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    filepath VARCHAR(500) NOT NULL,
    encrypted_aes_key VARBINARY(512) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_files_mahasiswa (mahasiswa_id)
);

CREATE TABLE IF NOT EXISTS audit_log (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    object VARCHAR(100),
    status VARCHAR(20) NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_timestamp (timestamp)
);

-- Trigger opsional untuk deployment MySQL. Aplikasi tetap mencatat audit
-- karena trigger tidak dapat membaca identitas JWT secara otomatis.
DELIMITER //
CREATE TRIGGER trg_nilai_update
AFTER UPDATE ON nilai
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_id, action, object, status)
    VALUES (@current_user_id, 'UPDATE', CONCAT('nilai:', NEW.id), 'SUCCESS');
END//
DELIMITER ;
