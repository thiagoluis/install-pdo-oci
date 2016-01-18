#!/usr/bin/env bash

# Author: Thiago Luís <thiagoluismo@gmail.com>

# The following procedures were tested under Debian and derivatives.

# http://nginx.org/en/linux_packages.html
NGINX_DISTRIBUTION="ubuntu"
NGINX_CODENAME="trusty"

# Downloads to $DIR_FILES
# instantclient-basic-linux.x64-12.1.0.2.0.zip
# instantclient-sdk-linux.x64-12.1.0.2.0.zip
# http://pecl.php.net/get/oci8-2.0.8.tgz
# http://pecl.php.net/get/PDO-1.0.3.tgz
# http://pecl.php.net/get/PDO_OCI-1.0.tgz
# http://nginx.org/keys/nginx_signing.key
DIR_FILES=/vagrant/provision

apt-key add $DIR_FILES/nginx_signing.key
echo "#nginx" >> /etc/apt/sources.list
echo "deb http://nginx.org/packages/$NGINX_DISTRIBUTION/ $NGINX_CODENAME nginx" >> /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/$NGINX_DISTRIBUTION/ $NGINX_CODENAME nginx" >> /etc/apt/sources.list

apt-get update
apt-get install -y build-essential libaio1 unzip php-pear php5 php5-common php5-cli php5-fpm php5-dev nginx

# instantclient
mkdir -p /opt/oracle/
unzip $DIR_FILES/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle
unzip $DIR_FILES/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle
mv /opt/oracle/instantclient_12_1 /opt/oracle/instantclient
ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so

# local where php extensions will be put
mkdir -p /usr/lib/php

# compilation oci8
tar xvzf $DIR_FILES/oci8-2.0.10.tgz --directory /usr/lib/php
cd /usr/lib/php/oci8-2.0.10
phpize
./configure --with-oci8=shared,instantclient,/opt/oracle/instantclient/
make install
echo "extension=oci8.so" > /etc/php5/mods-available/oci8.ini
ln -s /etc/php5/mods-available/oci8.ini /etc/php5/fpm/conf.d/20-oci8.ini

# compilation pdo_oci

# patches
ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so.10.1
mkdir -p /opt/oracle/instantclient/lib
ln -s /opt/oracle/instantclient/*so* /opt/oracle/instantclient/lib
ln -s /opt/oracle/instantclient/sdk/include /opt/oracle/instantclient/include

tar xvzf $DIR_FILES/PDO-1.0.3.tgz --directory /usr/lib/php
tar xvzf $DIR_FILES/PDO_OCI-1.0.tgz --directory /usr/lib/php

mkdir -p /usr/lib/php/PDO_OCI-1.0/include/php/ext/pdo
ln -s /usr/lib/php/PDO-1.0.3/php_pdo_driver.h /usr/lib/php/PDO_OCI-1.0/include/php/ext/pdo/php_pdo_driver.h

cd /usr/lib/php/PDO_OCI-1.0
sed -i 's/function_entry/zend_function_entry/' pdo_oci.c
phpize
./configure --with-pdo-oci=/opt/oracle/instantclient
make && make test && make install
echo "extension=pdo_oci.so" > /etc/php5/mods-available/pdo_oci.ini
ln -s /etc/php5/mods-available/pdo_oci.ini /etc/php5/fpm/conf.d/20-pdo_oci.ini

# Restart
service php5-fpm restart

# END
