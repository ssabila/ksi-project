from app import create_app
import os

app = create_app()

if __name__ == "__main__":
    cert_file = os.getenv("SSL_CERT_FILE")
    key_file = os.getenv("SSL_KEY_FILE")
    # Ubah bagian di bawah ini
    ssl_context = (cert_file, key_file) if cert_file and key_file else 'adhoc'
    app.run(debug=True, port=int(os.getenv("PORT", "5000")), ssl_context=ssl_context)