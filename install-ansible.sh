#!/bin/bash

set -e

echo "=== Mise à jour ==="
sudo apt update

echo "=== Installation Ansible (repo officiel Ubuntu) ==="
sudo apt install -y ansible || {
    echo "[WARN] échec via apt, fallback vers pipx..."

    sudo apt install -y pipx
    pipx ensurepath
    export PATH=$HOME/.local/bin:$PATH

    pipx install ansible
}

echo "=== Vérification ==="
if command -v ansible >/dev/null 2>&1; then
    ansible --version
else
    echo "[ERREUR] Ansible non installé"
    exit 1
fi

echo "=== Test localhost ==="
ansible localhost -m ping

echo "=== OK terminé ==="
