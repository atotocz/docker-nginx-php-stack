# Base docker image with NGINX and PHP

> Base docker image with NGINX and PHP7-FPM used by atoto.cz

- GitHub: https://github.com/atotocz/docker-nginx-php-stack
- Docker Hub: https://hub.docker.com/r/atoto/docker-nginx-php-stack/

## Installed tools

- Based on Debian 8.5 (jessie)
- PHP 7, php-fpm with extensions mongodb, bcmath, mbstring, intl, iconv, mcrypt, zip
- NGINX 1.6
- Supervisor
- GIT
- Composer 

## How to use this image as a base php image

- Copy sources of your application to `/var/www/html`
- All HTTP requests are routed to `/var/www/html/web/app.php`
- Update `Dockerfile`:

```Dockerfile
FROM atoto/docker-nginx-php-stack:stable

# copy sources to container
ADD . /var/www/html

# create necessary files and directories, install dependencies
RUN mkdir -p var && \
    chmod -R 0777 var && \
    cp app/config/parameters.prod.yml.dist app/config/parameters.yml && \
    composer install --no-dev --optimize-autoloader && \
    bin/console  doctrine:mongodb:generate:proxies
    # ...
```

- NGIX will listen on port `8080`
- If you would like to run some commands on container start (migrate database etc.), just create file called `docker-run.sh` in your project root:

```bash
# contents of file docker-run.sh

bin/console monitoring:mapping
bin/console doctrine:mongodb:schema:update
# ...
```

- If you would like to add something to supervisor configuration (consumers etc.), create file called `supervisord.conf` in your project root:

```
# contents of file supervisord.conf

[program:product-sync]
command=bin/console r:c -w -m 100 products-sync

[program:another]
command=bin/console another:command
```

## Recommendations

- run `composer install` before building your docker image and setup caching for faster builds:

```yml
# circle.yml

dependencies:
    cache_directories:
        - ~/.composer/cache
    override:
        - composer install --ignore-platform-reqs --no-interaction --no-dev --optimize-autoloader
        - docker build -t atotocz/image:tag .
```

- cache docker layers ([not enabled by default](https://circleci.com/docs/docker/#caching-docker-layers])):

```yml
# circle.yml

dependencies:
    cache_directories:
        - "~/docker"
    override:
        - if [[ -e ~/docker/image.tar ]]; then docker load -i ~/docker/image.tar; fi
        - docker build -t atotocz/image:tag .
        - mkdir -p ~/docker; docker save atotocz/image:tag > ~/docker/image.tar
```
