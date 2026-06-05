#!/usr/bin/env bash

set -e

echo "Installation du repository CrowdSec..."
curl -s https://install.crowdsec.net | sudo sh

echo "Verification du paquet CrowdSec disponible..."
apt list crowdsec

echo "Installation du Security Engine CrowdSec..."
sudo apt install -y crowdsec

echo "Verification du service CrowdSec..."
sudo systemctl status crowdsec --no-pager

echo "Installation terminee."
