#!/bin/bash

# Usage: ./create-rev-proxy.sh NOM_PROJET PORT_PROXY PORT_APP

if [ "$#" -ne 4 ]; then
  echo "Usage: $0 NOM_PROJET IP_SERVEUR PORT_PROXY PORT_APP"
  exit 1
fi

NOM_PROJET=$1
IP_SERVEUR=$2
PORT_PROXY=$3
PORT_APP=$4

CONF_PATH="/etc/apache2/sites-available/$NOM_PROJET.conf"

PORTS_CONF="/etc/apache2/ports.conf"
if ! grep -q "Listen $PORT_PROXY" "$PORTS_CONF"; then
  echo "Ajout de Listen $PORT_PROXY dans $PORTS_CONF"
  echo "Listen $PORT_PROXY" | sudo tee -a "$PORTS_CONF" > /dev/null
else
  echo "Port $PORT_PROXY déjà présent dans $PORTS_CONF"
fi


echo "Création du fichier de config Apache: $CONF_PATH"
sudo tee "$CONF_PATH" > /dev/null <<EOF
<VirtualHost *:$PORT_PROXY>
    ServerName $IP_SERVEUR

    ProxyPreserveHost On
    ProxyRequests Off

    ProxyPass / http://127.0.0.1:$PORT_APP/
    ProxyPassReverse / http://127.0.0.1:$PORT_APP/

    ErrorLog \${APACHE_LOG_DIR}/$NOM_PROJET_error.log
    CustomLog \${APACHE_LOG_DIR}/$NOM_PROJET_access.log combined
</VirtualHost>
EOF

echo "Validation de la configuration"
apachectl configtest

echo "Activation du reverse proxy pour $NOM_PROJET"
a2ensite "$NOM_PROJET.conf"

echo "Reload Apache"
systemctl reload apache2

echo "Ouverture du port"
ufw allow $PORT_PROXY/tcp
iptables -I INPUT -p tcp --dport $PORT_PROXY -j ACCEPT

echo "Vérification port"
ss -tuln | grep $PORT_PROXY
echo "Vérification pare-feu"
iptables -L -n -v | grep $PORT_PROXY
ufw status | grep $PORT_PROXY

echo "Reverse proxy pour le projet $NOM_PROJET configuré sur le port $PORT_PROXY vers le container 127.0.0.1:$PORT_APP"
