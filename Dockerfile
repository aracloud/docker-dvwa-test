FROM alpine:latest
LABEL maintainer="ndee"

RUN apk add --no-cache \
    apache2 \
    php php-apache2 php-mysqli php-session php-pdo php-pdo_mysql \
    php-gd php-mbstring php-xml php-json php-openssl \
    mariadb mariadb-client \
    supervisor git bash curl

# --- neu: Laufzeit‑Verzeichnisse anlegen -------------------
RUN mkdir -p /run/apache2 /run/mysqld /var/lib/mysql /var/www/localhost/htdocs \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# DVWA holen …
RUN git clone https://github.com/digininja/DVWA.git /var/www/localhost/htdocs/dvwa \
 && cp /var/www/localhost/htdocs/dvwa/config/config.inc.php.dist \
        /var/www/localhost/htdocs/dvwa/config/config.inc.php

# DB initialisieren
RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# Root‑PW + DVWA‑DB
RUN mariadbd --user=mysql --bootstrap <<'EOSQL'
CREATE DATABASE dvwa;
CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'dvwa';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';
FLUSH PRIVILEGES;
EOSQL

# DVWA‑Config anpassen (bleibt wie gehabt)

COPY supervisord.conf /etc/supervisord.conf
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
