# Installation
The instructions in file `install-pdo-oci.sh`, install pdo_oci extension in distribution Debian and derivatives.

    sudo ./install-pdo-oci.sh

## Requirements
+ [http://pecl.php.net/get/oci8-2.0.10.tgz]()
+ [http://pecl.php.net/get/PDO-1.0.3.tgz]()
+ [http://pecl.php.net/get/PDO_OCI-1.0.tgz]()
+ Search in oracle page for:
    + instantclient-basic-linux.x64-12.1.0.2.0.zip
    + instantclient-sdk-linux.x64-12.1.0.2.0.zip

## Testing with nginx
Set your distribution below: [http://nginx.org/en/linux_packages.html]():

    wget http://nginx.org/keys/nginx_signing.key
    sudo apt-key add nginx_signing.key
    echo "#nginx" | sudo tee --append /etc/apt/sources.list
    echo "deb http://nginx.org/packages/<distribution name>/ <distribution codename> nginx" | sudo tee --append /etc/apt/sources.list
    echo "deb-src http://nginx.org/packages/<distribution name>/ <distribution codename> nginx" | sudo tee --append /etc/apt/sources.list
    sudo apt-get update
    sudo apt-get install nginx


Configure your `/etc/nginx/conf.d/default.conf` to execute extensions `.php`. Basically like this:

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }

        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   /usr/share/nginx/html;
        }


        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        location ~ \.php$ {
            root /usr/share/nginx/html;
            fastcgi_pass   127.0.0.1:9000;
            fastcgi_param  SCRIPT_FILENAME  $document_root/$fastcgi_script_name;
            include        fastcgi_params;
        }
    }

Configure php5-fpm, set the address that accepts requests.

Replace in file `/etc/php5/fpm/pool.d/www.conf`, value of *listen*. From `listen = /var/run/php5-fpm.sock` to `listen = 127.0.0.1:9000` with your text editor or execute:

    sudo sed -i 's/\/var\/run\/php5-fpm.sock/127.0.0.1:9000/' /etc/php5/fpm/pool.d/www.conf

Restart

    sudo service php5-fpm restart
    sudo service nginx restart

Create in /usr/share/nginx/html your `phpinfo.php`:

    <?php phpinfo(); ?>

## Finished
Execute [http://localhost/phpinfo.php]() and check section PDO, you must see:

    PDO drivers         oci
