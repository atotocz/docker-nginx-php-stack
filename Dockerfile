FROM php:7.0.21-fpm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -qqy \
        nginx supervisor cron git curl links vim redis-tools mysql-client locales openvpn \
        libssl-dev libmcrypt-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libpng12-dev libpq-dev g++ libxml2-dev && \
    echo "cs_CZ.UTF-8 UTF-8" > /etc/locale.gen && locale-gen cs_CZ.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    pecl install mongodb && docker-php-ext-enable mongodb && \
    pecl install redis && docker-php-ext-enable redis && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) bcmath mbstring intl iconv mcrypt zip mysqli pdo pdo_mysql opcache soap gd && \
    apt-get purge --auto-remove -y g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/* && \
    touch /run/nginx.pid && touch /run/php-fpm.pid && touch /run/supervisord.pid && touch /var/run/crond.pid && \
    chown -R www-data:www-data /var/www /var/lib/nginx /run/nginx.pid /run/php-fpm.pid /run/supervisord.pid /var/run/crond.pid && \
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

COPY rootfs /

RUN chown www-data:www-data /etc/supervisor/supervisord.conf && \
    chmod +x /entrypoint.sh && \
    mkdir -p /var/www/.composer && \
    chmod -R 777 /var/www/.composer && \
    chown -R www-data:www-data /var/www/*

WORKDIR /var/www/html

EXPOSE 8080

CMD ["/entrypoint.sh"]
