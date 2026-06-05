import os
import subprocess
from datetime import datetime

CERTS_DIR = "/etc/letsencrypt/live"

def get_days_remaining(cert_path):
    try:
        output = subprocess.check_output(
            ["openssl", "x509", "-enddate", "-noout", "-in", cert_path],
            text=True
        )
        end_date = output.strip().split('=')[1]
        expires = datetime.strptime(end_date, "%b %d %H:%M:%S %Y %Z")
        return (expires - datetime.utcnow()).days
    except Exception:
        return None

def main():
    for domain in os.listdir(CERTS_DIR):
        cert_path = os.path.join(CERTS_DIR, domain, "cert.pem")
        if os.path.isfile(cert_path):
            days = get_days_remaining(cert_path)
            if days is None:
                print(f"{domain}: erreur de lecture du certificat")
            elif days < 0:
                print(f"{domain}: ❌ expiré depuis {abs(days)} jour(s)")
            else:
                print(f"{domain}: ✅ {days} jour(s) restants")

if __name__ == "__main__":
    main()
