FROM ubuntu:22.04

# ===============================
# Base setup
# ===============================
RUN apt-get update && \
    apt-get install -y nginx tini tzdata && \
    apt-get clean

RUN mkdir -p /home/public_html /run/php /var/lib/php/session && \
    groupadd -g 1000 nginx && \
    useradd -u 1000 -g nginx -m -d /home/nginx -s /bin/bash nginx && \
    chown -R nginx:nginx /home/public_html/ && \
    chown -R nginx:nginx /var/lib/php/

WORKDIR /home/public_html

# ===============================
# PHP 8.4 installation
# ===============================
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && apt-get install -y software-properties-common
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && apt-get update -y

# PHP 8.4 core + extensions (Magento needs these)
RUN apt-get install -y \
    php8.4 php8.4-fpm php8.4-common php8.4-cli php8.4-dev \
    php8.4-apcu php8.4-bcmath php8.4-curl php8.4-gd php8.4-intl \
    php8.4-mbstring php8.4-mysql php8.4-soap php8.4-xsl \
    php8.4-xml php8.4-zip php8.4-opcache php8.4-readline php8.4-sockets php8.4-xdebug

# Set PHP 8.4 as default
RUN update-alternatives --set php /usr/bin/php8.4 && \
    update-alternatives --set phar /usr/bin/phar8.4 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar8.4 && \
    update-alternatives --set phpize /usr/bin/phpize8.4 && \
    update-alternatives --set php-config /usr/bin/php-config8.4

# ===============================
# Utility packages
# ===============================
RUN apt-get install -y curl git sudo apt-utils vim zip unzip && \
    dpkg-reconfigure -f noninteractive tzdata

# ===============================
# Composer & n98-magerun2
# ===============================
RUN curl -fsSL https://getcomposer.org/download/2.8.4/composer.phar -o /usr/bin/composer && chmod +x /usr/bin/composer
RUN curl -fsSL https://files.magerun.net/n98-magerun2.phar -o /usr/bin/n98-magerun2.phar && chmod +x /usr/bin/n98-magerun2.phar

# ===============================
# Node.js + Grunt CLI (for Magento frontend)
# ===============================
RUN curl -sL https://deb.nodesource.com/setup_18.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs && \
    npm install -g grunt-cli

# ===============================
# NVM setup for nginx user
# ===============================
RUN su - nginx -c "touch /home/nginx/.bash_profile"
RUN su - nginx -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"
RUN chmod +x /home/nginx/.nvm/nvm.sh
RUN su - nginx -c "echo '[ -s /home/nginx/.nvm/nvm.sh ] && . /home/nginx/.nvm/nvm.sh # This loads NVM' > .profile"

# ===============================
# Xdebug configuration
# ===============================
RUN unlink /etc/php/8.4/cli/conf.d/20-xdebug.ini || true && \
    unlink /etc/php/8.4/fpm/conf.d/20-xdebug.ini || true

RUN pecl channel-update pecl.php.net

# ===============================
# Composer setup for nginx
# ===============================
RUN mkdir -p /home/nginx/.composer && chown -R nginx:nginx /home/nginx/.composer

# ===============================
# Entrypoint
# ===============================
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/sbin/php-fpm8.4", "-F", "-O", "--fpm-config", "/etc/php/8.4/fpm/php-fpm.conf"]
