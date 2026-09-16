from pathlib import Path

from app import create_app, db
from app.crypto.aes_db import encrypt_value
from app.crypto.hybrid_file import encrypt_file
from app.models import AuditLog, Nilai, StoredFile, User


DEMO_STUDENTS = (
    ("andi", "Andi", "Andi12345!", (86, 90, 88, 92)),
    ("sari", "Sari", "Sari12345!", (78, 84, 91, 87)),
)


def get_or_create_student(username, password):
    user = User.query.filter_by(username=username).first()
    if user:
        return user
    from app.auth import hash_password

    user = User(
        username=username,
        password_hash=hash_password(password),
        role="mahasiswa",
    )
    db.session.add(user)
    db.session.flush()
    return user


def seed_scores(user, scores):
    exists = Nilai.query.filter_by(mahasiswa_id=user.id).first()
    if exists:
        return False
    db.session.add(
        Nilai(
            mahasiswa_id=user.id,
            uts_enc=encrypt_value(scores[0]),
            uas_enc=encrypt_value(scores[1]),
            tugas_enc=encrypt_value(scores[2]),
            praktikum_enc=encrypt_value(scores[3]),
        )
    )
    return True


def seed_file(user, app):
    if StoredFile.query.filter_by(mahasiswa_id=user.id).first():
        return False
    plaintext = (
        f"Dokumen dummy SDMS\nMahasiswa: {user.username}\n"
        "File ini hanya untuk pengujian enkripsi hybrid.\n"
    ).encode()
    encrypted_data, encrypted_aes_key = encrypt_file(plaintext)
    storage_dir = Path(app.config["UPLOAD_DIR"])
    storage_dir.mkdir(parents=True, exist_ok=True)
    stored_path = storage_dir / f"dummy-{user.username}.txt.enc"
    stored_path.write_bytes(encrypted_data)
    db.session.add(
        StoredFile(
            mahasiswa_id=user.id,
            original_name=f"dokumen-{user.username}.txt",
            filepath=str(stored_path),
            encrypted_aes_key=encrypted_aes_key,
        )
    )
    return True


def main():
    app = create_app()
    with app.app_context():
        created_scores = 0
        created_files = 0
        for username, _display_name, password, scores in DEMO_STUDENTS:
            user = get_or_create_student(username, password)
            if seed_scores(user, scores):
                created_scores += 1
            if seed_file(user, app):
                created_files += 1
        db.session.commit()

        admin = User.query.filter_by(username="admin").first()
        if not AuditLog.query.filter_by(action="SEED_DEMO", object="database").first():
            db.session.add(
                AuditLog(
                    user_id=admin.id if admin else None,
                    action="SEED_DEMO",
                    object="database",
                    status="SUCCESS",
                )
            )
            db.session.commit()
        print(f"Data dummy siap: {created_scores} nilai baru, {created_files} file baru.")
        print("Akun tambahan: andi / Andi12345!, sari / Sari12345!")


if __name__ == "__main__":
    main()
