import bcrypt
from flask_jwt_extended import create_access_token, get_jwt_identity

from .models import User


def hash_password(password):
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verify_password(password, password_hash):
    return bcrypt.checkpw(password.encode(), password_hash.encode())


def make_token(user):
    return create_access_token(
        identity=str(user.id),
        additional_claims={"role": user.role, "username": user.username},
    )


def current_user():
    identity = get_jwt_identity()
    return User.query.get(int(identity))
