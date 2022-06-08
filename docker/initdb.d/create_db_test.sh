#!/bin/sh

mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "CREATE DATABASE akeneo"
mysql -u root -p${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON akeneo.* TO '${MYSQL_USER}'@'%'"
