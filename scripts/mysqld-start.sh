#!/bin/sh
mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

exec su -s /bin/sh mysql -c \
  "exec mysqld --basedir=/usr --datadir=/var/lib/mysql --user=mysql --port=3306"

