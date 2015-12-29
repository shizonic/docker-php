# PHP Docker Image + Necessary Extensions + Tools

FROM servivum/debian:jessie
MAINTAINER Patrick Baber <patrick.baber@servivum.com>

# Version
ENV PHP_VERSION "7.0.1"

# Install build essentials
RUN apt-get update && apt-get install -y \
    build-essential \
    libfcgi-dev \
    libfcgi0ldbl \
    libjpeg62-turbo-dbg \
    libmcrypt-dev \
    libssl-dev \
    libc-client2007e \
    libc-client2007e-dev \
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
    pkg-config \
    && \
    mkdir -p /usr/src/php

# Load and compile
RUN cd /usr/src/php && \
    wget http://de1.php.net/get/php-${PHP_VERSION}.tar.gz/from/this/mirror -O php-${PHP_VERSION}.tar.gz && \
    tar -xvzf php-${PHP_VERSION}.tar.gz && \
    cd php-${PHP_VERSION}/ && \
    ./configure \
    --disable-cgi \
    --enable-fpm \
    --enable-mysqlnd \
    --with-config-file-path="/etc/php" \
    --with-config-file-scan-dir="/etc/php/conf.d" \
    --with-curl \
    --with-gd \
    --with-pdo-mysql \
    --with-mysqli \
    --with-openssl \
    --with-readline \
    --with-recode \
    --with-zlib \
    && \
    make && \
    make install && \
    rm -rf /usr/src/php

# Add supervisor conf
COPY etc/supervisor/conf.d/php-fpm.conf /etc/supervisor/conf.d/php-fpm.conf

# Clean up
RUN apt-get purge -y -f \
	build-essential \
	&& \
	apt-get clean autoclean && \
	apt-get autoremove -y && \
	rm -rf /var/lib/apt/lists/*

WORKDIR /var/www
EXPOSE 9000
CMD ["/usr/bin/supervisord"]