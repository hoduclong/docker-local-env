# Stage 1: Node.js 14 + Grunt CLI
FROM node:14-bullseye as node-build

RUN npm install -g grunt-cli

# Stage 2: PHP 8.1 FPM
FROM php:8.1-fpm

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV TINI_VERSION=v0.19.0

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        git \
        unzip \
        zip \
        gnupg2 \
        ca-certificates \
        libzip-dev \
        libonig-dev \
        libicu-dev \
        libxml2-dev \
        libpng-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libxslt1-dev \
        tzdata \
        build-essential && \
    docker-php-ext-install xsl sockets && \
    rm -rf /var/lib/apt/lists/*

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

RUN mkdir -p /home/public_html /run/php /var/lib/php/session && \
    groupadd -g 1000 nginx && \
    useradd -u 1000 -g nginx -m -d /home/nginx -s /bin/bash nginx && \
    chown -R nginx:nginx /home/public_html /var/lib/php/

WORKDIR /home/public_html

# Enable GD with FreeType & JPEG support
RUN docker-php-ext-configure gd --with-freetype --with-jpeg

RUN docker-php-ext-install \
    pdo_mysql \
    mbstring \
    intl \
    soap \
    gd \
    bcmath \
    zip \
    opcache \
 && pecl install apcu xdebug \
 && docker-php-ext-enable apcu xdebug
 
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN curl -sSL https://files.magerun.net/n98-magerun2.phar -o /usr/bin/n98-magerun2.phar && \
    chmod +x /usr/bin/n98-magerun2.phar

# Copy Node.js and npm from Node.js stage
COPY --from=node-build /usr/local/bin/node /usr/local/bin/node
COPY --from=node-build /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm
RUN ln -s /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

RUN curl -L https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 -o /usr/local/bin/mhsendmail && \
    chmod +x /usr/local/bin/mhsendmail

RUN mkdir /home/nginx/.composer && chown -R nginx:nginx /home/nginx/.composer

# Remove default www.conf so our mounted config can take effect
RUN rm -f /usr/local/etc/php-fpm.d/www.conf
# Modify zz-docker.conf to use port 9001 instead of 9000
RUN sed -i 's/listen = 9000/listen = 9001/' /usr/local/etc/php-fpm.d/zz-docker.conf

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["php-fpm"]
