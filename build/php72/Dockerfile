# Stage 1: Node.js + Grunt CLI
FROM node:18-bullseye AS node-build
RUN npm install -g grunt-cli

# Stage 2: PHP 7.2 FPM (official image, no external repo needed)
FROM php:7.2-fpm

ENV DEBIAN_FRONTEND=noninteractive
ENV TINI_VERSION=v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

RUN mkdir -p /home/public_html /run/php /var/lib/php/session && \
    groupadd -g 1000 nginx && \
    useradd -u 1000 -g nginx -m -d /home/nginx -s /bin/bash nginx && \
    chown -R nginx:nginx /home/public_html /var/lib/php/

WORKDIR /home/public_html

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash curl git unzip zip gnupg2 ca-certificates sudo vim \
        libzip-dev libonig-dev libicu-dev libxml2-dev \
        libpng-dev libjpeg-dev libfreetype6-dev libxslt1-dev \
        libmcrypt-dev tzdata build-essential && \
    rm -rf /var/lib/apt/lists/*

# PHP 7.2 GD syntax (changed in 7.4, so keep --with-freetype-dir/--with-jpeg-dir)
RUN docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install \
        bcmath gd intl mbstring opcache pdo_mysql soap xsl zip sockets

RUN pecl install apcu && docker-php-ext-enable apcu
RUN pecl install mcrypt && docker-php-ext-enable mcrypt
RUN pecl install xdebug-2.9.8 && docker-php-ext-enable xdebug

RUN ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Composer 1.x — required for Magento 2.3.x
RUN curl -sSL https://getcomposer.org/download/1.10.19/composer.phar -o /usr/bin/composer && \
    chmod +x /usr/bin/composer

RUN curl -sSL https://files.magerun.net/n98-magerun2.phar -o /usr/bin/n98-magerun2.phar && \
    chmod +x /usr/bin/n98-magerun2.phar

# Copy Node.js + npm + grunt-cli from node build stage
COPY --from=node-build /usr/local/bin/node /usr/local/bin/node
COPY --from=node-build /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx && \
    ln -sf /usr/local/lib/node_modules/grunt-cli/bin/grunt /usr/local/bin/grunt

RUN curl -sSL https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 -o /usr/local/bin/mhsendmail && \
    chmod +x /usr/local/bin/mhsendmail

RUN mkdir -p /home/nginx/.composer && chown -R nginx:nginx /home/nginx/.composer
RUN echo "nginx ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/nginx

# Remove default www.conf so mounted magento.conf takes effect
RUN rm -f /usr/local/etc/php-fpm.d/www.conf
# Overwrite zz-docker.conf keeping only [global] daemonize=no
# (the [www] section would create an incomplete pool conflicting with our [magento] pool)
RUN printf '[global]\ndaemonize = no\n' > /usr/local/etc/php-fpm.d/zz-docker.conf

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["php-fpm"]
