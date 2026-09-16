import os
import uuid
from io import BytesIO
from pathlib import Path

import bcrypt
from flask import Blueprint, current_app, jsonify, request, send_file
from flask_jwt_extended import get_jwt, jwt_required
from werkzeug.utils import secure_filename

from . import db
from .audit import audit_log
from .auth import current_user, hash_password, make_token, verify_password
from .crypto.aes_db import decrypt_value, encrypt_value
from .crypto.hybrid_file import decrypt_file, encrypt_file
from .models import AuditLog, Nilai, StoredFile, User
from .rbac import require_roles

api = Blueprint("api", __name__)
SCORE_FIELDS = ("uts", "uas", "tugas", "praktikum")
ALLOWED_EXTENSIONS = {"pdf", "doc", "docx", "jpg", "jpeg", "png", "txt"}


def validate_scores(payload):
    if not isinstance(payload, dict):
        return "Body request harus berupa JSON"
    required = ("mahasiswa_id", *SCORE_FIELDS)
    missing = [field for field in required if field not in payload]
    if missing:
        return f"Field wajib belum diisi: {', '.join(missing)}"
    try:
        student_id = int(payload["mahasiswa_id"])
        scores = {field: int(payload[field]) for field in SCORE_FIELDS}
    except (TypeError, ValueError):
        return "Semua nilai harus berupa angka bulat"
    if student_id <= 0:
        return "ID mahasiswa harus lebih besar dari 0"
    if any(score < 0 or score > 100 for score in scores.values()):
        return "Nilai harus berada di antara 0 dan 100"
    return None


def nilai_to_dict(record):
    return {
        "id": record.id,
        "mahasiswa_id": record.mahasiswa_id,
        **{field: decrypt_value(getattr(record, f"{field}_enc")) for field in SCORE_FIELDS},
        "created_at": record.created_at.isoformat(timespec="seconds"),
    }


def is_owner_or_staff(student_id):
    claims = get_jwt()
    return claims.get("role") == "dosen" or int(claims["sub"]) == student_id


@api.get("/health")
def health():
    return jsonify({"status": "ok", "service": "sdms-api", "security": "enabled"})


@api.post("/auth/register")
def register():
    payload = request.get_json(silent=True) or {}
    username = str(payload.get("username", "")).strip().lower()
    password = str(payload.get("password", ""))
    if len(username) < 3 or len(password) < 8:
        return jsonify({"error": "Username minimal 3 karakter dan password minimal 8 karakter"}), 400
    if User.query.filter_by(username=username).first():
        return jsonify({"error": "Username sudah digunakan"}), 409
    user = User(username=username, password_hash=hash_password(password), role="mahasiswa")
    db.session.add(user)
    db.session.commit()
    audit_log("REGISTER", f"user:{user.id}", user_id=user.id)
    return jsonify({"id": user.id, "username": user.username, "role": user.role}), 201


@api.post("/auth/login")
def login():
    payload = request.get_json(silent=True) or {}
    user = User.query.filter_by(username=str(payload.get("username", "")).strip().lower()).first()
    if user is None or not verify_password(str(payload.get("password", "")), user.password_hash):
        audit_log("LOGIN", str(payload.get("username", "")), "FAILED")
        return jsonify({"error": "Username atau password salah"}), 401
    token = make_token(user)
    audit_log("LOGIN", f"user:{user.id}", user_id=user.id)
    return jsonify({"access_token": token, "user": {"id": user.id, "username": user.username, "role": user.role}})


@api.get("/auth/me")
@jwt_required()
def me():
    user = current_user()
    return jsonify({"id": user.id, "username": user.username, "role": user.role})


@api.get("/mahasiswa")
@require_roles("dosen", "admin")
def list_mahasiswa():
    students = User.query.filter_by(role="mahasiswa").order_by(User.username.asc()).all()
    return jsonify([
        {"id": student.id, "username": student.username, "role": student.role}
        for student in students
    ])


@api.post("/nilai")
@require_roles("dosen")
def create_nilai():
    payload = request.get_json(silent=True)
    error = validate_scores(payload)
    if error:
        return jsonify({"error": error}), 400
    nilai = Nilai(
        mahasiswa_id=int(payload["mahasiswa_id"]),
        **{f"{field}_enc": encrypt_value(payload[field]) for field in SCORE_FIELDS},
    )
    db.session.add(nilai)
    db.session.commit()
    audit_log("CREATE_NILAI", f"nilai:{nilai.id}")
    return jsonify(nilai_to_dict(nilai)), 201


@api.get("/nilai/<int:mahasiswa_id>")
@jwt_required()
def list_nilai(mahasiswa_id):
    if not is_owner_or_staff(mahasiswa_id):
        audit_log("ACCESS_DENIED", f"nilai:{mahasiswa_id}", "FAILED")
        return jsonify({"error": "Anda hanya dapat melihat nilai sendiri"}), 403
    records = Nilai.query.filter_by(mahasiswa_id=mahasiswa_id).order_by(Nilai.created_at.desc()).all()
    audit_log("READ_NILAI", f"mahasiswa:{mahasiswa_id}")
    return jsonify([nilai_to_dict(record) for record in records])


@api.post("/files")
@jwt_required()
def upload_file():
    file = request.files.get("file")
    try:
        student_id = int(request.form.get("mahasiswa_id", ""))
    except ValueError:
        return jsonify({"error": "mahasiswa_id tidak valid"}), 400
    if not file or not file.filename:
        return jsonify({"error": "File wajib diisi"}), 400
    claims = get_jwt()
    if claims.get("role") != "mahasiswa" or int(claims["sub"]) != student_id:
        audit_log("UPLOAD_DENIED", f"mahasiswa:{student_id}", "FAILED")
        return jsonify({"error": "Upload dokumen hanya dapat dilakukan mahasiswa untuk dirinya sendiri"}), 403
    original_name = secure_filename(file.filename)
    extension = Path(original_name).suffix.lower().lstrip(".")
    if extension not in ALLOWED_EXTENSIONS:
        return jsonify({"error": "Tipe file tidak diizinkan"}), 400
    data = file.read()
    if len(data) > 10 * 1024 * 1024:
        return jsonify({"error": "Ukuran file maksimal 10 MB"}), 400
    encrypted_data, encrypted_aes_key = encrypt_file(data)
    storage_dir = Path(current_app.config.get("UPLOAD_DIR", "storage"))
    storage_dir.mkdir(parents=True, exist_ok=True)
    stored_path = storage_dir / f"{uuid.uuid4().hex}.enc"
    stored_path.write_bytes(encrypted_data)
    record = StoredFile(
        mahasiswa_id=student_id,
        original_name=original_name,
        filepath=str(stored_path),
        encrypted_aes_key=encrypted_aes_key,
    )
    db.session.add(record)
    db.session.commit()
    audit_log("UPLOAD_FILE", f"file:{record.id}")
    return jsonify(file_to_dict(record)), 201


@api.get("/files")
@jwt_required()
def list_files():
    claims = get_jwt()
    if claims.get("role") == "admin":
        return jsonify({"error": "Admin hanya memiliki akses daftar mahasiswa dan audit log"}), 403
    query = StoredFile.query
    if claims.get("role") == "mahasiswa":
        query = query.filter_by(mahasiswa_id=int(claims["sub"]))
    records = query.order_by(StoredFile.created_at.desc()).all()
    return jsonify([file_to_dict(record) for record in records])


@api.get("/files/<int:file_id>/download")
@jwt_required()
def download_file(file_id):
    record = db.get_or_404(StoredFile, file_id)
    if not is_owner_or_staff(record.mahasiswa_id):
        audit_log("DOWNLOAD_DENIED", f"file:{file_id}", "FAILED")
        return jsonify({"error": "Akses file ditolak"}), 403
    data = decrypt_file(record.filepath, record.encrypted_aes_key)
    audit_log("DOWNLOAD_FILE", f"file:{file_id}")
    return send_file(BytesIO(data), as_attachment=True, download_name=record.original_name)


@api.get("/audit")
@require_roles("admin")
def list_audit():
    records = AuditLog.query.order_by(AuditLog.timestamp.desc()).limit(100).all()
    return jsonify([
        {
            "id": record.id,
            "user_id": record.user_id,
            "action": record.action,
            "object": record.object,
            "status": record.status,
            "timestamp": record.timestamp.isoformat(timespec="seconds"),
        }
        for record in records
    ])


def file_to_dict(record):
    return {
        "id": record.id,
        "mahasiswa_id": record.mahasiswa_id,
        "original_name": record.original_name,
        "created_at": record.created_at.isoformat(timespec="seconds"),
        "download_url": f"/api/files/{record.id}/download",
    }
