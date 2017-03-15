# PHP Docker Image + Necessary Extensions + Tools

FROM php:7.0.15-fpm-alpine
MAINTAINER Toby Merz <realtiaz@gmail.com>

RUN apk --update add \  
    #sudo \
    #wget \
    #imagemagick

    sudo \
    wget \
    vim \
    bash \
    git \
    tar \
    curl \
    grep \
    zlib \
    make \
    libxml2 \
    libxslt \
    libedit \
    readline \
    recode \
    freetype \
    openssl \
    libjpeg-turbo \
    libpng \
    libmcrypt \
    libwebp \
    icu \
    imagemagick \
    zip

RUN apk --update add --virtual build-dependencies \
    build-base \
    autoconf \
    bzip2-dev \
    libpng-dev \
    imagemagick-dev \
    curl-dev \
    libxml2-dev \
    libxslt-dev \
    libmcrypt-dev \
    sqlite-dev \
    postgresql-dev \
    libedit-dev \
    libtool \

    #build-base \
    re2c \
    file \
    readline-dev \
    recode-dev \
    #autoconf \
    binutils \
    bison \
    #libxml2-dev \
    #curl-dev \
    freetype-dev \
    openssl-dev \
    libjpeg-turbo-dev \
    #libpng-dev \
    libwebp-dev \
    #libmcrypt-dev \
    gmp-dev \
    icu-dev \
    #libmemcached-dev \
    linux-headers

RUN docker-php-source extract \
    && yes | pecl install \
        imagick \
        yaml \
    && docker-php-ext-install \
        bcmath \
        #bz2 \
        calendar \
        ctype \
        curl \
        dba \
        dom \
        #enchant \
        exif \
        fileinfo \
        #filter \
        ftp \
        gd \
        #gettext \
        gmp \
        hash \
        iconv \
        #imap \
        #interbase \
        #intl \
        json \
        #ldap \
        mbstring \
        mcrypt \
        mysqli \
        #oci8 \
        #odbc \
        opcache \
        pcntl \
        pdo \
        #pdo_dblib \
        #pdo_firebird \
        pdo_mysql \
        #pdo_oci \
        #pdo_odbc \
        #pdo_pgsql \
        pdo_sqlite \
        #pgsql \
        phar \
        posix \
        #pspell \
        readline \
        recode \
        #reflection \
        session \
        #shmop \
        simplexml \
        #snmp \
        soap \
        sockets \
        #spl \
        #standard \
        #sysvmsg \
        #sysvsem \
        #sysvshm \
        #tidy \
        tokenizer \
        #wddx \
        xml \
        #xmlreader \
        #xmlrpc \
        #xmlwriter \
        xsl \
        zip \
    && docker-php-ext-enable \
        imagick \
        #yaml \
    && docker-php-source delete

# URL: https://getcomposer.org/download/
ENV COMPOSER_VERSION "1.4.1"

# Install Composer
RUN wget https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar && \
    mv composer.phar /usr/local/bin/composer && \
    chmod +x /usr/local/bin/composer

# Clean up
RUN apk del build-dependencies

# Setup user and group
ENV USER_ID 1000
ENV GROUP_ID 100

RUN echo "developer:x:${USER_ID}:${GROUP_ID}:Developer,,,:/var/www/html:/bin/ash" >> /etc/passwd && \
    echo "developer:x:${USER_ID}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${USER_ID}:${GROUP_ID} -R /var/www/html

# Create user tm and allow to use sudo
#RUN adduser -D -H -G www-data tm \
#    && echo "tm ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Run commands as user developer
USER developer