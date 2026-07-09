FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8

RUN apt-get update && \
    apt-get install -y --no-install-recommends tini tzdata software-properties-common curl git sudo zip unzip ca-certificates gnupg vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/public_html /run/php /var/lib/php/session && \
    groupadd -g 1000 nginx && \
    useradd -u 1000 -g nginx -m -d /home/nginx -s /bin/bash nginx && \
    chown -R nginx:nginx /home/public_html /var/lib/php/

WORKDIR /home/public_html

RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
    php8.1 php8.1-dev php8.1-apcu php8.1-fpm php8.1-common \
    php8.1-gd php8.1-intl php8.1-soap php8.1-opcache php8.1-xml \
    php8.1-mysql php8.1-mbstring php8.1-bcmath php8.1-curl php8.1-zip \
    php8.1-xdebug && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN update-alternatives --set php /usr/bin/php8.1 && \
    update-alternatives --set phar /usr/bin/phar8.1 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar8.1 && \
    update-alternatives --set phpize /usr/bin/phpize8.1 && \
    update-alternatives --set php-config /usr/bin/php-config8.1

RUN dpkg-reconfigure -f noninteractive tzdata

RUN unlink /etc/php/8.1/cli/conf.d/20-xdebug.ini 2>/dev/null || true && \
    unlink /etc/php/8.1/fpm/conf.d/20-xdebug.ini 2>/dev/null || true

RUN curl https://getcomposer.org/download/2.8.4/composer.phar --output /usr/bin/composer && chmod +x /usr/bin/composer

RUN curl -sSL https://files.magerun.net/n98-magerun2.phar -o /usr/bin/n98-magerun2.phar && chmod +x /usr/bin/n98-magerun2.phar

# Install Node.js 18.x and Grunt CLI via NodeSource (multi-arch supported)
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_18.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g grunt-cli && \
    npm cache clean --force && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install mhsendmail (compiled from source for multi-arch support)
RUN apt-get update && \
    apt-get install -y --no-install-recommends golang-go && \
    GOPATH=/tmp/gopath go install github.com/mailhog/mhsendmail@latest && \
    cp /tmp/gopath/bin/mhsendmail /usr/local/bin/mhsendmail && \
    chmod +x /usr/local/bin/mhsendmail && \
    apt-get purge -y --auto-remove golang-go && \
    apt-get clean && \
    rm -rf /tmp/gopath /var/lib/apt/lists/*

RUN mkdir -p /home/nginx/.composer && chown -R nginx:nginx /home/nginx/.composer

RUN rm -f /etc/php/8.1/fpm/pool.d/www.conf

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/sbin/php-fpm8.1", "-F", "-O", "--fpm-config", "/etc/php/8.1/fpm/php-fpm.conf"]
