FROM phpdockerio/php74-fpm:latest

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive
ARG APPDIR=/application
ARG LOCALE=fr_FR.UTF-8
ARG LC_ALL=fr_FR.UTF-8
ENV LOCALE=fr_FR.UTF-8
ENV LC_ALL=fr_FR.UTF-8

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install curl wget git sudo cron locales \
    && locale-gen $LOCALE && update-locale \
    && usermod -u 33 -d $APPDIR www-data && groupmod -g 33 www-data \
    && mkdir -p $APPDIR && chown www-data:www-data $APPDIR

RUN cd /tmp && wget https://deb.nodesource.com/setup_12.x && chmod +x setup_12.x && ./setup_12.x && \
cd /tmp && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
apt update && apt install -y --force-yes nodejs yarn

RUN apt-get update \
    && apt-get -y --no-install-recommends install php-memcached php7.4-mysql php-pgsql php7.4-sqlite3 php7.4-intl php-gd php-mbstring php-yaml php-curl php-json php-redis \
&& cd /tmp \
&& php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
&& php composer-setup.php \
&& php -r "unlink('composer-setup.php');" \
&& mv composer.phar /usr/local/bin/composer

RUN apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Run cron
RUN service cron start

COPY ./ini/php-ini-overrides.ini /etc/php/7.4/fpm/conf.d/99-overrides.ini

EXPOSE 9000
VOLUME [ "$APPDIR" ]
WORKDIR $APPDIR
# USER 33:33
