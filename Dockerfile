# PHP Docker Image + Necessary Extensions + Tools

FROM php:7.1.1-fpm-alpine
MAINTAINER Toby Merz <realtiaz@gmail.com>

RUN apk --update add \
    sudo \
    imagemagick

RUN apk --update add --virtual build-dependencies \
    wget \
    build-base \
    autoconf \
    imagemagick-dev \
    libtool

RUN docker-php-source extract \
    && yes | pecl install imagick \
    && docker-php-source delete

# URL: https://getcomposer.org/download/
ENV COMPOSER_VERSION "1.3.2"

# Install Composer
RUN wget https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Clean up
RUN apk del build-dependencies

#WORKDIR /var/www
#EXPOSE 9000
#CMD ["/usr/local/sbin/php-fpm", "--allow-to-run-as-root"]