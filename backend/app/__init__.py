import os
from pathlib import Path

import bcrypt
from dotenv import load_dotenv
from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from flask_migrate import Migrate
from flask_sqlalchemy import SQLAlchemy

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / ".env")

db = SQLAlchemy()


def create_app():
    app = Flask(__name__)
    database_url = os.getenv("DATABASE_URL", "sqlite:///sdms.db")
    app.config["SQLALCHEMY_DATABASE_URI"] = database_url
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["JWT_SECRET_KEY"] = os.getenv(
        "JWT_SECRET_KEY", "local-development-secret-change-me"
    )
    app.config["JWT_ACCESS_TOKEN_EXPIRES"] = 60 * 60 * 8
    app.config["UPLOAD_DIR"] = str(BASE_DIR / os.getenv("UPLOAD_DIR", "storage"))

    db.init_app(app)
    Migrate(app, db)
    JWTManager(app)
    CORS(app, resources={r"/api/*": {"origins": "http://localhost:5173"}}, supports_credentials=True)
    from .routes import api
    app.register_blueprint(api, url_prefix="/api")

    with app.app_context():
        from . import models
        db.create_all()
        seed_demo_users()

    @app.errorhandler(404)
    def not_found(_error):
        return jsonify({"error": "Endpoint tidak ditemukan"}), 404

    return app


def seed_demo_users():
    if os.getenv("SEED_DEMO_USERS", "true").lower() != "true":
        return

    from .models import User

    demo_users = (
        ("admin", "admin", os.getenv("DEMO_ADMIN_PASSWORD", "Admin123!")),
        ("dosen", "dosen", os.getenv("DEMO_DOSEN_PASSWORD", "Dosen123!")),
        (
            "mahasiswa",
            "mahasiswa",
            os.getenv("DEMO_MAHASISWA_PASSWORD", "Mahasiswa123!"),
        ),
    )
    for username, role, password in demo_users:
        if User.query.filter_by(username=username).first() is None:
            password_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
            db.session.add(User(username=username, password_hash=password_hash, role=role))
    db.session.commit()
