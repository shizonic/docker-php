# PHP Docker Image + Necessary Extensions + Tools

FROM servivum/debian:jessie
MAINTAINER Toby Merz <realtiaz@gmail.com>

# Version
# URL: https://secure.php.net/downloads.php
ENV PHP_VERSION "5.6.30"
ENV PHP_SHA256_CHECKSUM "8bc7d93e4c840df11e3d9855dcad15c1b7134e8acf0cf3b90b932baea2d0bde2"

# URL: https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/
ENV GRAPHICSMAGICK_VERSION "1.3.25"
ENV GRAPHICSMAGICK_SHA1_CHECKSUM "0acd6bb1cb3b420fa4b20a06f7aae240169174e3"

# URL: https://getcomposer.org/download/
ENV COMPOSER_VERSION "1.3.2"

# URL: https://phar.phpunit.de/
ENV PHPUNIT_VERSION "5.7.10"
ENV PHPUNIT_SHA256_CHECKSUM "6c60f09fa913c9198efdb39edf2768ad8fdb0ab596c3a608688cb1d86f0706eb"

# Install build essentials & dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    autoconf \
    git \
    build-essential \
    libfcgi-dev \
    libfcgi0ldbl \
    libjpeg62-turbo-dbg \
    libmcrypt-dev \
    libssl-dev \
    libc-client2007e \
#    libc-client2007e-dev \
    libxml2-dev \
    libbz2-dev \
    libcurl4-openssl-dev \
    libjpeg-dev \
    libpng12-dev \
    libfreetype6-dev \
    libkrb5-dev \
    libpq-dev \
    libreadline6-dev \
    librecode-dev \
    libxml2-dev \
    libxslt1-dev \
    libmcrypt4 \
    pkg-config \
    graphicsmagick \
    graphicsmagick-imagemagick-compat \
    ghostscript \
    && \
    mkdir -p /usr/src/php && \
    mkdir -p /usr/src/graphicsmagick && \

# Load and compile GraphicsMagick
    cd /usr/src/graphicsmagick && \
    wget https://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/${GRAPHICSMAGICK_VERSION}/GraphicsMagick-${GRAPHICSMAGICK_VERSION}.tar.gz -O GraphicsMagick-${GRAPHICSMAGICK_VERSION}.tar.gz && \
    openssl sha1 GraphicsMagick-${GRAPHICSMAGICK_VERSION}.tar.gz | grep "${GRAPHICSMAGICK_SHA1_CHECKSUM}" && \
    tar -xvzf GraphicsMagick-${GRAPHICSMAGICK_VERSION}.tar.gz && \
    cd GraphicsMagick-${GRAPHICSMAGICK_VERSION}/ && \
    ./configure \
    --prefix=/opt/graphicsmagick \
    --without-perl --enable-shared \
    && \
    make && \
    make install && \
    rm -rf /usr/src/graphicsmagick && \

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
    apt-get purge -y -f \
    build-essential \
    && \
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

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
COPY etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf

WORKDIR /var/www
EXPOSE 9000
CMD ["/usr/bin/supervisord"]
