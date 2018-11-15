FROM alpine:3.7
LABEL maintainer="Emmanuel BORGES <contact@eborges.fr>"

# Install PHP 7.1 and nginx
RUN apk update && apk upgrade
RUN apk add nginx curl bash supervisor \
php7 php7-fpm php7-cli php7-opcache php7-phar php7-memcached php7-apcu \
php7-gd php7-mysqli php7-zlib php7-curl php7-pdo_mysql php7-ftp \
php7-openssl php7-redis php7-mbstring php7-xml php7-dom php7-simplexml \
php7-json php7-iconv php7-xdebug php7-zip php7-amqp php7-mcrypt php7-session

# add composer if necessary
RUN curl -fSL https://getcomposer.org/installer -o composer-setup.php \
&& php composer-setup.php --install-dir=bin --filename=composer \
&& rm composer-setup.php

# add blackfire if necessary
RUN curl -fSL https://packages.blackfire.io/binaries/blackfire-php/1.23.1/blackfire-php-linux_amd64-php-71.so -o blackfire.so \
&& mv blackfire.so /usr/lib/php7/modules/blackfire.so \
&& printf "extension=blackfire.so\nblackfire.agent_socket=tcp://blackfire:8707\n" > /etc/php7/conf.d/90-blackfire.ini

# enable xdebug if necessary
RUN echo 'zend_extension=xdebug.so' > /etc/php7/conf.d/xdebug.ini
RUN echo "xdebug.remote_enable = 1" | tee -a /etc/php7/conf.d/docker-php-ext-xdebug.ini
RUN echo "memory_limit = \"-1\"" | tee -a /etc/php7/conf.d/memory-limit.ini

# Copy files and create directories
RUN mkdir -p /var/www/html
RUN mkdir -p /var/log/
COPY nginx.conf /etc/nginx/nginx.conf
COPY symfony.conf /etc/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisord.conf
COPY date.ini /etc/php7/conf.d/date.ini

# Permissions
RUN chmod -Rf 0777 /var/log/
RUN chmod a+x /bin/composer

# Expose ports
EXPOSE 80

# Run entrypoint
WORKDIR /var/www/html

# start supervisord
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]