FROM alpine:latest
LABEL maintainer="ndee"

RUN apk add --no-cache \
    apache2 \
    php php-apache2 php-mysqli php-session php-pdo php-pdo_mysql \
    php-gd php-mbstring php-xml php-json php-openssl \
    mariadb mariadb-client \
    supervisor git bash curl

# Laufzeitverzeichnisse vorbereiten
RUN mkdir -p /run/apache2 /run/mysqld /var/lib/mysql /var/www/localhost/htdocs \
 && chown -R mysql:mysql /run/mysqld /var/lib/mysql

# DVWA klonen
RUN git clone https://github.com/digininja/DVWA.git /var/www/localhost/htdocs/dvwa \
 && cp /var/www/localhost/htdocs/dvwa/config/config.inc.php.dist \
       /var/www/localhost/htdocs/dvwa/config/config.inc.php

# MariaDB initialisieren
RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# MariaDB temporär starten, um Setup durchzuführen
RUN mysqld_safe --datadir='/var/lib/mysql' --user=mysql & \
    sleep 5 && \
    mysql -u root -e "CREATE DATABASE dvwa;" && \
    mysql -u root -e "CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'dvwa';" && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';" && \
    mysql -u root -e "FLUSH PRIVILEGES;" && \
    killall mysqld && \
    sleep 5

COPY supervisord.conf /etc/supervisord.conf
EXPOSE 80
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
