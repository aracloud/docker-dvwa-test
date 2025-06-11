FROM alpine:latest

# Installiere Pakete
RUN apk update && apk add --no-cache \
    lighttpd \
    php81 \
    php81-mysqli \
    php81-pdo \
    php81-pdo_mysql \
    php81-session \
    php81-openssl \
    php81-curl \
    php81-gd \
    php81-dom \
    php81-mbstring \
    php81-json \
    php81-tokenizer \
    php81-xml \
    php81-common \
    php81-iconv \
    php81-fileinfo \
    php81-fpm \
    mariadb mariadb-client \
    supervisor \
    curl \
    git \
    bash

# Linke PHP
RUN ln -s /usr/bin/php81 /usr/bin/php && \
    ln -s /etc/php81 /etc/php

# Setze Arbeitsverzeichnis
WORKDIR /var/www/localhost/htdocs

# DVWA klonen
RUN git clone https://github.com/digininja/DVWA.git . && \
    cp config/config.inc.php.dist config/config.inc.php

# Setze einfache MariaDB-Datenbank
RUN mkdir -p /run/mysqld && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# MariaDB Bootstrap Script
COPY init.sql /init.sql

# Konfiguriere Lighttpd für PHP-FPM
RUN echo 'server.modules += ( "mod_fastcgi" )\n\
fastcgi.server = ( ".php" => ((\n\
  "host" => "127.0.0.1",\n\
  "port" => 9000\n\
)))' >> /etc/lighttpd/lighttpd.conf

# Konfiguration anpassen (php.ini)
RUN echo "allow_url_fopen = On\ndisplay_errors = On" >> /etc/php81/php.ini

# Supervisor-Konfiguration
COPY supervisord.conf /etc/supervisord.conf

# Standard-Port öffnen
EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

