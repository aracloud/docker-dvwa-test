FROM alpine:3.20

# Environment
ENV PHP_SOCKET=127.0.0.1:9000

# Abhängigkeiten installieren
RUN apk update && apk add --no-cache \
    lighttpd \
    php83 \
    php83-fpm \
    php83-mysqli \
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
    php83-iconv \
    php83-fileinfo \
    php83-common \
    mariadb mariadb-client \
    supervisor \
    curl \
    bash \
    su-exec \
    shadow \
    tzdata \
    && ln -sf /usr/bin/php83 /usr/bin/php \
    && ln -sf /etc/php83 /etc/php

# Lighttpd Konfiguration
COPY configs/lighttpd-fastcgi.conf /etc/lighttpd/conf.d/fastcgi.conf
RUN echo 'include "conf.d/fastcgi.conf"' >> /etc/lighttpd/lighttpd.conf

# MariaDB initialisieren
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld && \
    mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# DVWA holen
RUN mkdir -p /var/www/localhost/htdocs && \
    curl -L https://github.com/digininja/DVWA/archive/master.tar.gz | tar xz --strip 1 -C /var/www/localhost/htdocs && \
    cp /var/www/localhost/htdocs/config/config.inc.php.dist /var/www/localhost/htdocs/config/config.inc.php

# Init-SQL & Startskript
COPY configs/init.sql /init.sql
COPY scripts/mysqld-start.sh /usr/local/bin/mysqld-start
RUN chmod +x /usr/local/bin/mysqld-start

# Supervisor-Konfiguration
COPY configs/supervisord.conf /etc/supervisord.conf

# Port
EXPOSE 80

# Start über Supervisor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
