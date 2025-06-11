FROM alpine:latest

# Update und essentielle Pakete installieren
RUN apk update && apk upgrade && apk add --no-cache \
    apache2 \
    php8 \
    php8-apache2 \
    php8-mysqli \
    php8-session \
    php8-json \
    php8-pdo \
    php8-pdo_mysql \
    php8-openssl \
    php8-mbstring \
    php8-gd \
    php8-dom \
    php8-curl \
    php8-zip \
    php8-tokenizer \
    mariadb mariadb-client \
    git \
    supervisor \
    curl

# MariaDB initialisieren
RUN mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql

# DVWA klonen
RUN git clone https://github.com/digininja/DVWA.git /var/www/localhost/htdocs/dvwa

# Apache-Konfiguration
RUN sed -i 's|^DocumentRoot ".*|DocumentRoot "/var/www/localhost/htdocs/dvwa"|' /etc/apache2/httpd.conf && \
    echo "IncludeOptional /etc/apache2/conf.d/*.conf" >> /etc/apache2/httpd.conf

# Apache und MariaDB via Supervisor starten
COPY supervisord.conf /etc/supervisord.conf

# Port freigeben
EXPOSE 80

# Start-Befehl
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

