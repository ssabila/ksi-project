from functools import wraps

from flask import jsonify
from flask_jwt_extended import get_jwt, verify_jwt_in_request


def require_roles(*allowed_roles):
    def decorator(function):
        @wraps(function)
        def wrapped(*args, **kwargs):
            verify_jwt_in_request()
            role = get_jwt().get("role")
            if role not in allowed_roles:
                return jsonify({"error": "Akses ditolak untuk role ini"}), 403
            return function(*args, **kwargs)

        return wrapped

    return decorator
