FROM ubuntu:22.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y nginx tini tzdata && \
    apt-get clean

RUN mkdir -p /home/public_html /run/php /var/lib/php/session && \
    groupadd -g 1000 nginx && useradd -u 1000 -g nginx -m -d /home/nginx -s /bin/bash nginx && \
    chown -R nginx:nginx /home/public_html/ && \
    chown -R nginx:nginx /var/lib/php/

WORKDIR /home/public_html

# Install dependencies
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update -y
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y software-properties-common
RUN export DEBIAN_FRONTEND=noninteractive && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php && apt-get update -y
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y php8.3 php8.3-dev php8.3-apcu php8.3-fpm php8.3-common \
    php8.3-gd php8.3-intl php8.3-soap php8.3-opcache php8.3-xml php8.3-mysql \
    php8.3-mbstring php8.3-bcmath php8.3-curl php8.3-zip php8.3-xdebug

RUN update-alternatives --set php /usr/bin/php8.3 && \
    update-alternatives --set phar /usr/bin/phar8.3 && \
    update-alternatives --set phar.phar /usr/bin/phar.phar8.3 && \
    update-alternatives --set phpize /usr/bin/phpize8.3 && \
    update-alternatives --set php-config /usr/bin/php-config8.3

RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -y curl git sudo apt-utils vim zip unzip
RUN dpkg-reconfigure -f noninteractive tzdata

# Install Composer
RUN curl https://getcomposer.org/download/2.8.4/composer.phar --output /usr/bin/composer && chmod +x /usr/bin/composer
RUN curl https://files.magerun.net/n98-magerun2.phar --output /usr/bin/n98-magerun2.phar && chmod +x /usr/bin/n98-magerun2.phar

# Install Node.js and Grunt CLI
RUN export DEBIAN_FRONTEND=noninteractive && \
    curl -sL https://deb.nodesource.com/setup_14.x -o nodesource_setup.sh && \
    bash nodesource_setup.sh && \
    apt-get install -y nodejs && \
    npm install -g grunt-cli

# NVM setup for nginx user
RUN su - nginx -c "touch /home/nginx/.bash_profile"
RUN su - nginx -c "curl https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash"
RUN chmod +x /home/nginx/.nvm/nvm.sh
RUN su - nginx -c "echo '[ -s /home/nginx/.nvm/nvm.sh ] && . /home/nginx/.nvm/nvm.sh # This loads NVM' > .profile"

# Xdebug configuration
RUN unlink /etc/php/8.3/cli/conf.d/20-xdebug.ini && \
    unlink /etc/php/8.3/fpm/conf.d/20-xdebug.ini


RUN pecl channel-update pecl.php.net

# Create Composer directory
RUN mkdir /home/nginx/.composer && chown -R nginx:nginx /home/nginx/.composer

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/sbin/php-fpm8.3", "-F", "-O", "--fpm-config", "/etc/php/8.3/fpm/php-fpm.conf"]