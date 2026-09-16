from datetime import datetime, timedelta, timezone
from ipaddress import ip_address
from pathlib import Path

from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.x509.oid import NameOID


CERT_DIR = Path(__file__).resolve().parent / "certs"
KEY_PATH = CERT_DIR / "key.pem"
CERT_PATH = CERT_DIR / "cert.pem"

CERT_DIR.mkdir(parents=True, exist_ok=True)
private_key = rsa.generate_private_key(public_exponent=65537, key_size=2048)
subject = issuer = x509.Name(
    [x509.NameAttribute(NameOID.COMMON_NAME, "localhost")]
)
certificate = (
    x509.CertificateBuilder()
    .subject_name(subject)
    .issuer_name(issuer)
    .public_key(private_key.public_key())
    .serial_number(x509.random_serial_number())
    .not_valid_before(datetime.now(timezone.utc))
    .not_valid_after(datetime.now(timezone.utc) + timedelta(days=30))
    .add_extension(
        x509.SubjectAlternativeName(
            [x509.DNSName("localhost"), x509.IPAddress(ip_address("127.0.0.1"))]
        ),
        critical=False,
    )
    .sign(private_key, hashes.SHA256())
)

KEY_PATH.write_bytes(
    private_key.private_bytes(
        serialization.Encoding.PEM,
        serialization.PrivateFormat.TraditionalOpenSSL,
        serialization.NoEncryption(),
    )
)
CERT_PATH.write_bytes(certificate.public_bytes(serialization.Encoding.PEM))
print(f"Sertifikat dibuat: {CERT_PATH}")
print(f"Private key dibuat: {KEY_PATH}")
