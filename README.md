# Base docker image with NGINX and PHP

> Base docker image with NGINX and PHP7-FPM used by atoto.cz

- GitHub: https://github.com/atotocz/docker-nginx-php-stack
- Docker Hub: https://hub.docker.com/r/atoto/docker-nginx-php-stack/

## Installed tools

- Based on Debian 8.5 (jessie)
- PHP 7, php-fpm with extensions mongodb, bcmath, mbstring, intl, iconv, mcrypt, zip...
- NGINX
- Supervisor
- GIT
- Composer 

## How to use this image as a base php image

- Copy sources of your application to `/var/www/html`
- All HTTP requests will be routed to `/var/www/html/web/app.php`
- Update `Dockerfile`:

```Dockerfile
FROM atoto/docker-nginx-php-stack:latest

# install dependencies
RUN composer config -g github-oauth.github.com abcdef1021992sdmksmkskm
COPY composer.json composer.lock /var/www/html/
RUN composer install --no-dev --optimize-autoloader

# copy sources to container
ADD . /var/www/html

# create necessary files and directories, set permissions
RUN rm -fr var/* && \
    mkdir -p var var/logs var/temp var/cache && \
    chown -R www-data:www-data /var/www/* && \
    chmod -R 777 var/* && \
    bin/console  doctrine:mongodb:generate:proxies
    # ...

# start container as a non-root user
USER www-data
```

- NGIX will be listening on port `8080`
- If you would like to run some commands on container start (migrate database etc.), just create file called `docker-run.sh` in your project root or in `.docker` directory:

```bash
# contents of file docker-run.sh

bin/console monitoring:mapping
bin/console doctrine:mongodb:schema:update
# ...
```

- If you would like to add something to supervisor configuration (consumers etc.), create file called `supervisord.conf` in your project root or in `.docker` directory:

```
# contents of file supervisord.conf

[program:product-sync]
command=bin/console r:c -w -m 100 products-sync

[program:another]
command=bin/console another:command
```

- You can define `crontab` which will be used to run cron jobs inside container (you must be root):

```bash
# contents of file crontab

* * * * * echo "Hello world every minute"
```
