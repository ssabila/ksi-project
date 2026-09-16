from flask_jwt_extended import get_jwt_identity

from . import db
from .models import AuditLog


def audit_log(action, object_name="", status="SUCCESS", user_id=None):
    if user_id is None:
        try:
            user_id = int(get_jwt_identity())
        except Exception:
            user_id = None
    db.session.add(
        AuditLog(
            user_id=user_id,
            action=action,
            object=object_name,
            status=status,
        )
    )
    db.session.commit()
