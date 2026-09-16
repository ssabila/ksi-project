import os
from pathlib import Path

from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa

BASE_DIR = Path(__file__).resolve().parents[2]


def _path(env_name, default):
    value = Path(os.getenv(env_name, default))
    return value if value.is_absolute() else BASE_DIR / value


def ensure_rsa_keys():
    private_path = _path("RSA_PRIVATE_KEY_PATH", "keys/private.pem")
    public_path = _path("RSA_PUBLIC_KEY_PATH", "keys/public.pem")
    if not private_path.exists() or not public_path.exists():
        private_path.parent.mkdir(parents=True, exist_ok=True)
        private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
        private_path.write_bytes(
            private_key.private_bytes(
                serialization.Encoding.PEM,
                serialization.PrivateFormat.PKCS8,
                serialization.NoEncryption(),
            )
        )
        public_path.write_bytes(
            private_key.public_key().public_bytes(
                serialization.Encoding.PEM,
                serialization.PublicFormat.SubjectPublicKeyInfo,
            )
        )
    return private_path, public_path


def load_public_key():
    _, public_path = ensure_rsa_keys()
    return serialization.load_pem_public_key(public_path.read_bytes())


def load_private_key():
    private_path, _ = ensure_rsa_keys()
    return serialization.load_pem_private_key(private_path.read_bytes(), password=None)


def rsa_oaep_encrypt(data):
    return load_public_key().encrypt(
        data,
        rsa_padding(),
    )


def rsa_padding():
    from cryptography.hazmat.primitives.asymmetric import padding

    return padding.OAEP(
        mgf=padding.MGF1(algorithm=hashes.SHA256()),
        algorithm=hashes.SHA256(),
        label=None,
    )


def rsa_oaep_decrypt(data):
    return load_private_key().decrypt(data, rsa_padding())
