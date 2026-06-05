#!/bin/bash

# Usage: ./create-rev-proxy-nginx.sh NOM_PROJET IP_SERVEUR PORT_PROXY PORT_APP

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 NOM_PROJET IP_SERVEUR PORT_PROXY PORT_APP"
  exit 1
fi

NOM_PROJET=$1
IP_SERVEUR=$2
PORT_PROXY=$3
PORT_APP=$4

CONF_PATH="/etc/nginx/sites-available/$NOM_PROJET.conf"

echo "Création du fichier de config Nginx: $CONF_PATH"
sudo tee "$CONF_PATH" > /dev/null <<EOF
server {
    listen $PORT_PROXY;
    server_name $IP_SERVEUR;

    location / {
        proxy_pass http://127.0.0.1:$PORT_APP;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_log /var/log/nginx/${NOM_PROJET}_error.log;
    access_log /var/log/nginx/${NOM_PROJET}_access.log;
}
EOF

echo "Activation du site Nginx"
ln -sf "$CONF_PATH" /etc/nginx/sites-enabled/

echo "Test de la configuration Nginx"
nginx -t

echo "Reload Nginx"
systemctl reload nginx

echo "Ouverture du port"
ufw allow $PORT_PROXY/tcp
iptables -I INPUT -p tcp --dport $PORT_PROXY -j ACCEPT

echo "Vérification port"
ss -tuln | grep $PORT_PROXY
echo "Vérification pare-feu"
iptables -L -n -v | grep $PORT_PROXY
ufw status | grep $PORT_PROXY

echo "Reverse proxy Nginx pour le projet $NOM_PROJET configuré sur le port $PORT_PROXY vers 127.0.0.1:$PORT_APP"
