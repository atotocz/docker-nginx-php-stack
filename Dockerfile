FROM php:7.0.10-fpm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -qqy nginx supervisor git locales libssl-dev libmcrypt-dev libicu-dev openvpn curl links && \
    echo "cs_CZ.UTF-8 UTF-8" > /etc/locale.gen && locale-gen cs_CZ.UTF-8 && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen en_US.UTF-8 && \
    dpkg-reconfigure locales && \
    pecl install mongodb && docker-php-ext-enable mongodb && \
    docker-php-ext-install bcmath mbstring intl iconv mcrypt zip mysqli pdo pdo_mysql && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/www/html/* && \
    touch /run/nginx.pid && touch /run/supervisord.pid && \
    chown -R www-data:www-data /var/www /var/lib/nginx /run/nginx.pid /run/supervisord.pid && \
    php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

COPY rootfs /

RUN chown www-data:www-data /etc/supervisor/supervisord.conf && \
    chmod +x /entrypoint.sh

WORKDIR /var/www/html

USER www-data

EXPOSE 8080

CMD ["/entrypoint.sh"]
