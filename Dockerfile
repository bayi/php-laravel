FROM ubuntu:bionic
LABEL maintainer "Balázs Batári <bayi@bayi.hu>"

# Fix debconf warnings upon build
ENV TERM=linux
ENV DEBIAN_FRONTEND=noninteractive
# Disable XDEBUG
ENV XDEBUG="false"

WORKDIR "/application"

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg \
    && echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" > /etc/apt/sources.list.d/ondrej-php.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C \
    && apt-get update \
        && apt-get -y --no-install-recommends install \
        ca-certificates \
        curl \
        unzip \
        php-apcu \
        php-apcu-bc \
        php7.2-cli \
        php7.2-curl \
        php7.2-json \
        php7.2-mbstring \
        php7.2-opcache \
        php7.2-readline \
        php7.2-xml \
        php7.2-zip \
        php7.2-mysql \
        php7.2-bcmath \
        php7.2-bz2 \
        php7.2-gd \
        php7.2-gmp \
        php-imagick \
        php7.2-intl \
        php7.2-fpm \
        php7.2-ldap \
        php7.2-soap \
        php-redis \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        webp \
        imagemagick \
        ghostscript \
        git \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer global require hirak/prestissimo \
    && composer clear-cache \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* ~/.composer

STOPSIGNAL SIGQUIT

COPY overrides.conf /etc/php/7.2/fpm/pool.d/z-overrides.conf
COPY php.ini /etc/php/7.2/fpm/conf.d/99-overrides.ini
COPY polcy.xml /etc/ImageMagick-6/policy.xml
COPY wait-for-it.sh /usr/bin/wait-for-it.sh
RUN chmod +x /usr/bin/wait-for-it.sh

# Fix permissions
RUN usermod -u 1000 www-data
RUN groupmod -g 1000 www-data
RUN usermod -d /application www-data
RUN mkdir /run/php-fpm
RUN chown -fhR www-data:www-data /run/php-fpm

# Aliases
RUN echo '#!/bin/bash\n/usr/bin/php /application/artisan "$@"' > /usr/bin/artisan
RUN chmod +x /usr/bin/artisan

# Run command
ENTRYPOINT ["/usr/sbin/php-fpm7.2", "-O" ]

# Open up fcgi port
EXPOSE 9000
