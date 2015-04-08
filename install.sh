#!/usr/bin/env bash

# Author: Thiago Luís <thiagoluis@ymail.com>

# The following procedures were tested under Debian and derivatives.
# IMPORTANT! You must have administrator permission to perform some of the commands below.

# Create the directory to Instantcliente 12.1
mkdir -p ~/provision/oracle12

# Links for Instantclient
# http://download.oracle.com/otn/linux/instantclient/121020/instantclient-basic-linux.x64-12.1.0.2.0.zip
# http://download.oracle.com/otn/linux/instantclient/121020/instantclient-sdk-linux.x64-12.1.0.2.0.zip

mkdir -p /usr/lib/oracle/12.1/client64/lib /usr/lib/oracle/12.1/client64/bin

unzip ~/provision/oracle12/instantclient-basic-linux.x64-12.1.0.2.0.zip -d /usr/lib/oracle/
cp -a /usr/lib/oracle/instantclient_12_1/* /usr/lib/oracle/12.1/client64/lib
mv /usr/lib/oracle/12.1/client64/lib/genezi /usr/lib/oracle/12.1/client64/bin

unzip ~/provision/oracle12/instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /usr/lib/oracle/
cp -a /usr/lib/oracle/instantclient_12_1/sdk /usr/lib/oracle/12.1/ 

rm -rf /usr/lib/oracle/instantclient_12_1

ln -s /usr/lib/oracle/12.1/sdk/include /usr/lib/oracle/12.1/client64/include
ln -s /usr/lib/oracle/12.1/client64/lib/libclntsh.so.12.1 /usr/lib/oracle/12.1/client64/lib/libclntsh.so
ln -s /usr/lib/oracle/12.1/client64/lib/libocci.so.12.1 /usr/lib/oracle/12.1/client64/lib/libocci.so
ln -s /usr/lib/oracle/12.1/client64 /usr/lib/oracle/12.1/client

# Create the directory to the drivers oci8, pdo e pdo_oci.
mkdir -p ~/provision/php

# Download oci, pdo e pdo_oci.
wget -P ~/provision/php http://pecl.php.net/get/oci8-2.0.8.tgz
wget -P ~/provision/php http://pecl.php.net/get/PDO-1.0.3.tgz
wget -P ~/provision/php http://pecl.php.net/get/PDO_OCI-1.0.tgz

# Compilation oci8 e pdo_oci.
# When not in use the module fpm (FastCGI Process Manager), change the path of the extensions.
# With fpm - /etc/php5/fpm/conf.d
# Without fpm - /etc/php5/apache2/conf.d

# Create the directory for compilation oci8 e pdo_oci.
mkdir -p /usr/lib/php

# Compilation oci8.
tar xvzf ~/provision/php/oci8-2.0.8.tgz --directory /usr/lib/php
cd /usr/lib/php/oci8-2.0.8
phpize
./configure --with-oci8=shared,instantclient,/usr/lib/oracle/12.1/client/lib
make install
echo "extension=oci8.so" > /etc/php5/mods-available/oci8.ini
# Change the way when not using fpm.
ln -s /etc/php5/mods-available/oci8.ini /etc/php5/fpm/conf.d/20-oci8.ini

# Compilation pdo_oci.
ln -s /usr/lib/oracle/12.1 /usr/lib/oracle/10.2
tar xvzf ~/provision/php/PDO-1.0.3.tgz --directory /usr/lib/php
tar xvzf ~/provision/php/PDO_OCI-1.0.tgz --directory /usr/lib/php

mkdir -p /usr/lib/php/PDO_OCI-1.0/include/php/ext/pdo
ln -s /usr/lib/php/PDO-1.0.3/php_pdo_driver.h /usr/lib/php/PDO_OCI-1.0/include/php/ext/pdo/php_pdo_driver.h

cd /usr/lib/php/PDO_OCI-1.0
sed -i 's/function_entry/zend_function_entry/' pdo_oci.c
phpize
./configure --with-pdo-oci=instantclient,/usr,10.2
make && make test && make install
echo "extension=pdo_oci.so" > /etc/php5/mods-available/pdo_oci.ini
# Change the way when not using fpm.
ln -s /etc/php5/mods-available/pdo_oci.ini /etc/php5/fpm/conf.d/20-pdo_oci.ini

# Clear downloads oci8, pdo and pdo_oci
rm -rf ~/provision/php/*

# Restart php5-fpm or apache2 when not using fpm.
service php5-fpm restart
