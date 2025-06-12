FROM alpine:latest

# Installiere Pakete
RUN apk update && apk add --no-cache \
    lighttpd \
    php83 \
    php83-mysqli \
    php83-pdo \
    php83-pdo_mysql \
    php83-session \
    php83-openssl \
    php83-curl \
    php83-gd \
    php83-dom \
    php83-mbstring \
    php83-json \
    php83-tokenizer \
    php83-xml \
    php83-common \
    php83-iconv \
    php83-fileinfo \
    php83-fpm \
    mariadb mariadb-client \
    supervisor \
    curl \
    git \
    bash

# Linke PHP
#RUN ln -s /usr/bin/php83 /usr/bin/php && \
#    ln -s /etc/php83 /etc/php
RUN  ln -s /etc/php83 /etc/php

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
#RUN echo 'server.modules += ( "mod_fastcgi" )\n\
#fastcgi.server = ( ".php" => ((\n\
#  "host" => "127.0.0.1",\n\
#  "port" => 9000\n\
#)))' >> /etc/lighttpd/lighttpd.conf
COPY http.conf /http.conf
RUN cat /http.conf >> /etc/lighttpd/lighttpd.conf

# Konfiguration anpassen (php.ini)
RUN echo "allow_url_fopen = On\ndisplay_errors = On" >> /etc/php83/php.ini

# Supervisor-Konfiguration
COPY supervisord.conf /etc/supervisord.conf

# Standard-Port öffnen
EXPOSE 80

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

