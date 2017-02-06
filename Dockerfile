# PHP Docker Image + Necessary Extensions + Tools

FROM alpine:latest
MAINTAINER Toby Merz <realtiaz@gmail.com>

# Version
# URL: https://secure.php.net/downloads.php
ENV PHP_VERSION "7.1.1"
ENV PHP_SHA256_CHECKSUM "c136279d539c3c2c25176bf149c14913670e79bb27ee6b73e1cd69003985a70d"

# URL: https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/
ENV GRAPHICSMAGICK_VERSION "1.3.25"
ENV GRAPHICSMAGICK_SHA1_CHECKSUM "0acd6bb1cb3b420fa4b20a06f7aae240169174e3"

# URL: https://getcomposer.org/download/
ENV COMPOSER_VERSION "1.3.2"

# URL: https://phar.phpunit.de/
ENV PHPUNIT_VERSION "6.0.3"
ENV PHPUNIT_SHA256_CHECKSUM "1cad3525717362d0851d67bce8cb85abd100809bf1ddc20139e7387927e2f077"

# Install build essentials & dependencies
RUN apk --no-cache add \
    sudo \
    build-base \
    autoconf \
    make \
    tar \
    curl \
    wget \
    git \
    grep \
    openssl \
    ghostscript \
    readline-dev \
    recode-dev \
    libmcrypt-dev \
    libxml2-dev \
    libjpeg-turbo-dev \
    curl-dev \
    openssl-dev \
    bzip2-dev \
    gmp-dev \
    freetype-dev \
    libxpm-dev \
    libwebp-dev \
    libjpeg \
    krb5-dev \
    && \
    mkdir -p /usr/src/php && \
    mkdir -p /usr/src/graphicsmagick && \

# Load and compile GraphicsMagick


# Load and compile PHP
# @TODO: Make /etc/php to default config path
    cd /usr/src/php && \
    wget http://de1.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror -O php-${PHP_VERSION}.tar.gz && \
    openssl sha256 php-${PHP_VERSION}.tar.gz | grep "${PHP_SHA256_CHECKSUM}" && \
    tar -xvzf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION}/ && \
    mkdir -p /usr/local/etc/php/conf.d && \
    ./configure \
    --disable-cgi \
    --enable-fpm \
    --enable-mbstring \
    --enable-mysqlnd \
    --enable-zip \
    --with-config-file-path="/usr/local/etc/php" \
    --with-config-file-scan-dir="/usr/local/etc/php/conf.d" \
    --with-curl \
    --with-gd \
    --with-pdo-mysql \
    --with-mcrypt \
    --with-mysqli \
    --with-openssl \
    --with-readline \
    --with-recode \
    --with-zlib \
    && \
    make && \
    make install && \

# Load and compose gmagick PHP Extension
    git clone https://github.com/vitoc/gmagick.git && \
    cd gmagick && \
    phpize && \
    ./configure \
    --with-gmagick="/opt/graphicsmagick" \
    && \
    make && \
    make install && \
    rm -rf /usr/src/php && \

# Clean up
    #apt-get purge -y -f \
    #build-essential \
    #&& \
    #apt-get clean autoclean && \
    #apt-get autoremove -y && \
    #rm -rf /var/lib/apt/lists/*

# Install Composer
RUN wget https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Install PHPUnit
RUN wget https://phar.phpunit.de/phpunit-${PHPUNIT_VERSION}.phar && \
    openssl sha256 phpunit-${PHPUNIT_VERSION}.phar | grep "${PHPUNIT_SHA256_CHECKSUM}" && \
    mv phpunit-${PHPUNIT_VERSION}.phar /usr/local/bin/phpunit && \
    chmod +x /usr/local/bin/phpunit

# Add php-fpm pool config
# @TODO: Use php-fpm.conf from the compiling process and not an own version inside this repo.
COPY etc/php/php-fpm.conf /usr/local/etc/php-fpm.conf

# Add supervisor conf
#COPY etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf

WORKDIR /var/www
EXPOSE 9000
#CMD ["/usr/bin/supervisord"]
