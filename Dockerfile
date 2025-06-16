FROM alpine:latest

LABEL maintainer="ndee"

# 1. Abhängigkeiten installieren
RUN apk update && apk add --no-cache \
    apache2 \
    php php-apache2 php-mysqli php-session php-pdo php-pdo_mysql php-gd php-mbstring php-xml php-json php-openssl \
    mariadb mariadb-client \
    supervisor \
    git \
    bash \
    curl

# 2. Ordner anlegen
RUN mkdir -p /run/apache2 /var/lib/mysql /var/www/localhost/htdocs

# 3. DVWA klonen
RUN git clone https://github.com/digininja/DVWA.git /var/www/localhost/htdocs/dvwa && \
    cp /var/www/localhost/htdocs/dvwa/config/config.inc.php.dist /var/www/localhost/htdocs/dvwa/config/config.inc.php

# 4. MariaDB initialisieren
RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# 5. Setze MySQL Root-Passwort und erstelle DVWA-Datenbank mit Benutzer
RUN mysqld --user=mysql --bootstrap <<EOF
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL ON *.* TO 'root'@'localhost' IDENTIFIED BY 'root' WITH GRANT OPTION;
CREATE DATABASE dvwa;
CREATE USER 'dvwa'@'localhost' IDENTIFIED BY 'dvwa';
GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost';
FLUSH PRIVILEGES;
EOF

# 6. DVWA config anpassen
RUN sed -i "s/'user' => 'root'/'user' => 'dvwa'/g" /var/www/localhost/htdocs/dvwa/config/config.inc.php && \
    sed -i "s/'password' => 'p@ssw0rd'/'password' => 'dvwa'/g" /var/www/localhost/htdocs/dvwa/config/config.inc.php && \
    sed -i "s/'db_database' => 'dvwa'/'db_database' => 'dvwa'/g" /var/www/localhost/htdocs/dvwa/config/config.inc.php

# 7. Supervisor Konfiguration
COPY supervisord.conf /etc/supervisord.conf

# 8. Port freigeben
EXPOSE 80

# 9. Start über supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
