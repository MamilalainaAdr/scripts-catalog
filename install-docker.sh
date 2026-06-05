#!/usr/bin/env bash
set -e

echo "Mise a jour des paquets..."
sudo apt update

echo "Suppression des anciennes versions eventuelles..."
sudo apt remove -y docker.io docker-compose docker-compose-v2 docker-doc podman-docker containerd runc || true

echo "Installation des dependances..."
sudo apt install -y ca-certificates curl

echo "Creation du dossier des keyrings..."
sudo install -m 0755 -d /etc/apt/keyrings

echo "Ajout de la cle GPG officielle Docker..."
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Ajout du repository Docker..."
echo \
"Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources > /dev/null

echo "Mise a jour des sources APT..."
sudo apt update

echo "Installation de Docker Engine..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Activation du service Docker..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
sudo systemctl start docker

echo "Creation du groupe docker (si non existant)..."
sudo groupadd docker 2>/dev/null || true

echo "Ajout de l'utilisateur courant au groupe docker..."
sudo usermod -aG docker "$USER"

echo "Application des changements"
newgrp docker

echo "Verification du service Docker..."
sudo systemctl status docker --no-pager

echo "Test avec hello-world..."
docker run hello-world

echo "Installation terminee."
