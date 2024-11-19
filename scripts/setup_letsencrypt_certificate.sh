#!/bin/bash
set -x

# Configuramos las variables con los datos que necesita el certificado
source .env

echo $LE_EMAIL
echo $LE_DOMAIN

snap install core
snap refresh core

apt remove certbot -y

snap install --classic certbot

ln -fs /snap/bin/certbot /usr/bin/certbot

certbot --apache -m $LE_EMAIL --agree-tos --no-eff-email -d $LE_DOMAIN --non-interactive