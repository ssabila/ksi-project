from datetime import datetime

from . import db


class Nilai(db.Model):
    __tablename__ = "nilai"

    id = db.Column(db.Integer, primary_key=True)
    mahasiswa_id = db.Column(db.Integer, nullable=False, index=True)
    uts_enc = db.Column(db.LargeBinary, nullable=False)
    uas_enc = db.Column(db.LargeBinary, nullable=False)
    tugas_enc = db.Column(db.LargeBinary, nullable=False)
    praktikum_enc = db.Column(db.LargeBinary, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)


class User(db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), nullable=False, default="mahasiswa")
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)


class StoredFile(db.Model):
    __tablename__ = "files"

    id = db.Column(db.Integer, primary_key=True)
    mahasiswa_id = db.Column(db.Integer, nullable=False, index=True)
    original_name = db.Column(db.String(255), nullable=False)
    filepath = db.Column(db.String(500), nullable=False)
    encrypted_aes_key = db.Column(db.LargeBinary, nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)


class AuditLog(db.Model):
    __tablename__ = "audit_log"

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer)
    action = db.Column(db.String(100), nullable=False)
    object = db.Column(db.String(100))
    status = db.Column(db.String(20), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)
