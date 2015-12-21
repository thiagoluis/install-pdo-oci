#!/usr/bin/env bash

# Author: Thiago Luís <thiagoluismo@gmail.com>

# The following procedures were tested under Debian and derivatives.

# Downloads
# instantclient-basic-linux.x64-12.1.0.2.0.zip
# instantclient-sdk-linux.x64-12.1.0.2.0.zip
# http://pecl.php.net/get/oci8-2.0.8.tgz
# http://pecl.php.net/get/PDO-1.0.3.tgz
# http://pecl.php.net/get/PDO_OCI-1.0.tgz

apt-get update

apt-get install -y build-essential libaio1 tree unzip vim php-pear php5 php5-common php5-cli php5-fpm php5-dev php5-xdebug php5-mcrypt php5-intl php5-memcache php5-apcu nginx

# php mcrypt
ln -s /etc/php5/mods-available/mcrypt.ini /etc/php5/fpm/conf.d/20-mcrypt.ini

# instantclient
mkdir -p /opt/oracle/
unzip /vagrant/provision/oracle/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle
unzip /vagrant/provision/oracle/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle
mv /opt/oracle/instantclient_12_1 /opt/oracle/instantclient
ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so

export LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH
export NLS_LANG=AMERICAN_AMERICA.UTF8

echo LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH >> /etc/environment
echo NLS_LANG=AMERICAN_AMERICA.UTF8 >> /etc/environment

echo '/opt/oracle/instantclient/' | sudo tee -a /etc/ld.so.conf.d/oracle_instant_client.conf
ldconfig

# oci8 and pdo_oci
mkdir -p /usr/lib/php

# oci8
tar xvzf /vagrant/provision/php/oci8-2.0.10.tgz --directory /usr/lib/php
cd /usr/lib/php/oci8-2.0.10
phpize
./configure --with-oci8=shared,instantclient,/opt/oracle/instantclient/
make install
echo "extension=oci8.so" > /etc/php5/mods-available/oci8.ini
ln -s /etc/php5/mods-available/oci8.ini /etc/php5/fpm/conf.d/20-oci8.ini

# pdo_oci

# patch pdo_oci
ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so.10.1
ln -s /opt/oracle/instantclient /opt/oracle/instantclient/lib
ln -s /opt/oracle/instantclient/sdk/include /opt/oracle/instantclient/include

tar xvzf /vagrant/provision/php/PDO-1.0.3.tgz --directory /usr/lib/php
tar xvzf /vagrant/provision/php/PDO_OCI-1.0.tgz --directory /usr/lib/php

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
service nginx restart

# END
