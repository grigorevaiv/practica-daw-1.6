# Instalación de WordPress en una instancia EC2 de AWS
**Requisitos**<br>
* Una instancia de AWS configurada, con una IP pública
* Una pila LAMP instalada y configurada en dicha instancia

## Instalación de WordPress en el directorio raíz
**1.** Elimina descargas previas de Wordpress si existen
```
rm -rf /tmp/latest.tar.gz
```
**2.** Descarga la última versión de WordPress (en adelante - WP)    
```
wget http://wordpress.org/latest.tar.gz -P /tmp
```
**3.** Discomprime el archivo 
```
tar -xzvf /tmp/latest.tar.gz -C /tmp
```
Usa los parámetros:
```x``` extraer el contenido<br>
```z``` descomprimir<br>
```v``` muestra el proceso de descompresión<br>
```f``` indica el nombre del archivo de entrada<br>
```c``` indica el diretorio destino (en este caso - ```tmp```)<br>
Con este comando el archivo descomprime en /tmp/wordpress

**4.** Mueve el contenido del archivo descomprimido en directorio raiz
```
mv -f /tmp/wordpress/* /var/www/html
```

**5.** Crea una base de datos y el usuario para WP
```
mysql -u root <<< "DROP DATABASE IF EXISTS $WORDPRESS_DB_NAME"
mysql -u root <<< "CREATE DATABASE $WORDPRESS_DB_NAME"
mysql -u root <<< "DROP USER IF EXISTS $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
mysql -u root <<< "CREATE USER $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL IDENTIFIED BY '$WORDPRESS_DB_PASSWORD'"
mysql -u root <<< "GRANT ALL PRIVILEGES ON $WORDPRESS_DB_NAME.* TO $WORDPRESS_DB_USER@$IP_CLIENTE_MYSQL"
```
**Nota bene**: las variables se guarda en el archivo .env
Recuerda que la valor de ```$IP_CLIENTE_MYSQL``` depende del objetivo y puede ser:<br>
```localhost`` permite conectar desde el servidor MySQL
```%``` permite conectar desde cualquier dirreción IP
```3.209.98.219``` permite conectar desde la dirreción IP concreta

**6.** Copia un archivo de configuración para WP en directorio raiz
```
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
```
**7.** Cambia el archivo de configuración para WP<br>
```
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wp-config.php
```
**Recuerda** que el comando ```sed``` se usa para buscar y reemplazar.<br> La notación es la siguente:
```s/buscar/reemplazar/ /ruta/a/tu/directorio``` - s significa "sustituir". Le dice a sed que busque el texto y lo reemplace.
**Nota bene**: las variables se guarda en el archivo .env

**8.** Cambia el propietario y el grupo al directorio ```/var/www/html```<br>
con el comando
```
chown -R www-data:www-data /var/www/html/
```
Cuando instalado WP, este comando se usa para permitir el servidor web acceder a los archivos de WP y descarga su contenido.

**9.** Crea la configuración para los enlaces permanentes de WP
```<IfModule mod_rewrite.c>``` comprueba si el módulo mod_rewrite está habilitado en Apache. Si no, todas las instruccionas abajo se ignoran.<br>
```RewriteEngine On``` habilita un mecanismo de reescritura de URL, para permitir a Apache procesar RewriteRules.<br>
```RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]``` pasa el encabezado de autorización del cliente a la variable de entorno HTTP_AUTHORIZATION.<br>
```RewriteBase /``` especifica la ruta para las reglas de reescritura. En este caso - el directorio raíz.<br>
```RewriteRule ^index\.php$ - [L]``` si  URL es igual a index.php, no haga nada y detenga el procesamiento de reglas. ```[L]``` significa la última regla a procesar.<br>
```RewriteCond %{REQUEST_FILENAME} !-f``` si el archivo solicitado no existe ```(!-f)```, pase a la siguiente regla. Necesario para evitar el procesamiento de los archivos existentes (e.g., styles.css).<br>
```RewriteCond %{REQUEST_FILENAME} !-d``` si el directorio solicitado no existe ```(!-d)```, pase a la siguiente regla. Le permite ignorar las reglas de reescritura para peticiones a directorios existentes.<br>
```RewriteRule . /index.php [L]``` si la petición no es un archivo y no es un directorio, entonces se hace una redirección a index.php.
```</IfModule>``` fin del bloque.<br>
**Conclusión** este archivo hará que todas las peticiones que llegen a este directorio, si no son un archivo o un directorio entonces se redirigen a ```index.php```.

**10.** Habilita el módulo mod_rewrite de Apache
```
a2enmod rewrite
```
**11.** Reinicia el servicio de Apache
```
sudo systemctl restart apache2
```

## Instalación de WordPress en su propio directorio
Pasos de 1 a 7 de instalacón del WP en su propio directorio son los mismos que en el apartado anterior, pero debe cambiar los comandos en:<br>
**Paso 4.** <br>
```mv -f /tmp/wordpress /var/www/html```
**Paso 6.** <br>
```cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php```
**Paso 7.** <br>
```
sed -i "s/database_name_here/$WORDPRESS_DB_NAME/" /var/www/html/wordpress/wp-config.php
sed -i "s/username_here/$WORDPRESS_DB_USER/" /var/www/html/wordpress/wp-config.php
sed -i "s/password_here/$WORDPRESS_DB_PASSWORD/" /var/www/html/wordpress/wp-config.php
sed -i "s/localhost/$WORDPRESS_DB_HOST/" /var/www/html/wordpress/wp-config.php
```
**8.** Configura los variables de configuración:
* ```WP_SITEURL``` dirección de WordPress. Es la URL que incluye el directorio donde está instalado el código fuente de WordPress.
* ```WP_HOME``` dirección del sitio. Es la URL que va a usar los usuarios para acceder a WordPress.

**9.** Copia el archivo ```cp /var/www/html/wordpress/index.php /var/www/html``` ```/var/www/html```.<br>
```cp /var/www/html/wordpress/index.php /var/www/html```<br>
**10.** Cambia el contenido del archivo ```index.php```<br>
```sed -i "s#wp-blog-header.php#wordpress/wp-blog-header.php#" /var/www/html/index.php```<br>
donde wordpress es el directorio con el código fuente de WP.
**11.** Prepara la configuración para los enlaces permanentes de WP.<br>
Hay que crear un archivo .htaccess en el directorio ```/var/www/html``` con el siguente contenido:<br>
```
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
```
**Nota bene**: para permitir al servidor Apache leer un archivo ```.htaccess``` hay que configurar la directiva AllowOverride como AllowOverride All en ```000-defautl.conf```.
**12.** Habilita el módulo mod_rewrite de Apache
```
a2enmod rewrite
```
**13.** Reinicia el servicio de Apache
```
sudo systemctl restart apache2
```



