import os
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives import serialization

def generate_rsa_keys():
    os.makedirs("keys", exist_ok=True)
    
    # Membuat Private Key 2048-bit
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
    )
    
    # Menyimpan Private Key
    with open("keys/private.pem", "wb") as f:
        f.write(private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.TraditionalOpenSSL,
            encryption_algorithm=serialization.NoEncryption()
        ))
        
    # Mengekstrak dan Menyimpan Public Key
    public_key = private_key.public_key()
    with open("keys/public.pem", "wb") as f:
        f.write(public_key.public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        ))
        
    print("✅ Kunci RSA 2048-bit sukses dibuat di folder 'keys'!")

if __name__ == "__main__":
    generate_rsa_keys()