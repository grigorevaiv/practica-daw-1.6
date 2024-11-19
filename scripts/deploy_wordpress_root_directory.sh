#!/bin/bash
# configuramos el script para que se muestren los comandos
# y finalice cuando hay un error en la ejecución
set -ex


# importamos el contenido de las variables  de entorno
source .env

# Eliminamos descargas previas de Wordpress
rm -rf /tmp/latest.tar.gz

# Descargamos codigo fuente de Wordpress
wget http://wordpress.org/latest.tar.gz -P /tmp

# Descomprimimos el codigo fuente de WordPress
tar -xzvf /tmp/latest.tar.gz -C /tmp

# Eliminamos instalaciones previas en /var/www/html
rm -rf /var/www/html/*

# Movemos el codigo fuente de WordPress a /var/www/html
mv -f /tmp/wordpress/* /var/www/html

# Creamos la base de datos y el usuario para WordPress
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"

# Creamos el archivo wp-config.php
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
# Configuramos el archivo wp-config.php
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php

# Cambiamos el propietario y el grupo
chown -R www-data:www-data /var/www/html/