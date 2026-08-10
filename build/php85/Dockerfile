FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_VERSION=2.10.0
ENV COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates curl git gnupg lsb-release msmtp msmtp-mta \
        software-properties-common sudo tini tzdata unzip zip && \
    add-apt-repository ppa:ondrej/php && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        default-mysql-client \
        php8.5 php8.5-apcu php8.5-bcmath php8.5-cli php8.5-common php8.5-curl \
        php8.5-fpm php8.5-gd php8.5-intl php8.5-mbstring \
        php8.5-mysql php8.5-readline php8.5-redis php8.5-soap \
        php8.5-sockets php8.5-ssh2 php8.5-xdebug php8.5-xml php8.5-xsl php8.5-zip && \
    curl -fsSL "https://getcomposer.org/download/${COMPOSER_VERSION}/composer.phar" -o /usr/bin/composer && \
    chmod +x /usr/bin/composer && \
    curl -fsSL https://files.magerun.net/n98-magerun2.phar -o /usr/bin/n98-magerun2.phar && \
    chmod +x /usr/bin/n98-magerun2.phar && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_20.x nodistro main" > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    npm install -g grunt-cli && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN if ! getent group nginx >/dev/null; then \
        if getent group 1000 >/dev/null; then groupmod -n nginx "$(getent group 1000 | cut -d: -f1)"; else groupadd -g 1000 nginx; fi; \
    fi && \
    if ! id -u nginx >/dev/null 2>&1; then \
        if getent passwd 1000 >/dev/null; then usermod -l nginx -d /home/nginx -m "$(getent passwd 1000 | cut -d: -f1)" && usermod -g nginx nginx; else useradd -u 1000 -g nginx -m -d /home/nginx -s /bin/bash nginx; fi; \
    fi && \
    mkdir -p /home/public_html /home/nginx/.composer /run/php /var/lib/php/session /var/lib/php/wsdlcache /var/log/php-fpm && \
    chown -R nginx:nginx /home/public_html /home/nginx /var/lib/php /var/log/php-fpm

RUN update-alternatives --set php /usr/bin/php8.5 && \
    update-alternatives --set phar /usr/bin/phar8.5 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar8.5 && \
    rm -f /etc/php/8.5/cli/conf.d/20-xdebug.ini /etc/php/8.5/fpm/conf.d/20-xdebug.ini

RUN printf '%s\n' \
    'defaults' \
    'auth off' \
    'tls off' \
    'logfile -' \
    'account mailpit' \
    'host mailhog' \
    'port 1025' \
    'from docker@local' \
    'account default : mailpit' \
    > /etc/msmtprc && chmod 644 /etc/msmtprc

COPY entrypoint.sh /usr/local/bin/php85-entrypoint
RUN chmod +x /usr/local/bin/php85-entrypoint

WORKDIR /home/public_html

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/php85-entrypoint"]
CMD ["/usr/sbin/php-fpm8.5", "-F", "-O", "--fpm-config", "/etc/php/8.5/fpm/php-fpm.conf"]
