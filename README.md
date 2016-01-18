# Install pdo_oci
The instructions to install extension pdo_oci this in file `install-pdo-oci.sh`, set variables according to your environment.

After configure, execute how to administrator:

    ./intall-pdo-oci.sh

## Testing
Create /usr/share/nginx/html/phpinfo.php:

    <?php phpinfo(); ?>

Before execute [http://localhost/phpinfo.php](), follow steps below:

### Configure php5-fpm

Set the address that accepts requests.

 Replace in file `/etc/php5/fpm/pool.d/www.conf`:

  Value of *listen*. From `listen = /var/run/php5-fpm.sock` to `listen = 127.0.0.1:9000` with your text editor, or execute:

    sed -i 's/\/var\/run\/php5-fpm.sock/127.0.0.1:9000/' /etc/php5/fpm/pool.d/www.conf

Restart

    service php5-fpm restart

### Configure Nginx
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

Restart

    service nginx restart
