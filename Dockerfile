FROM debian:latest

# LABEL maintainer "Matej Meško <meshosk@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

# update APT
RUN apt-get update
RUN apt-get upgrade -y

## install basics
RUN apt-get install -y software-properties-common

RUN apt-get install -y bash curl ca-certificates sudo locales && \
         update-locale LANG=C.UTF-8 LC_MESSAGES=POSIX && \
         locale-gen en_US.UTF-8 && \
         dpkg-reconfigure locales

# Create sudo user ham
RUN  useradd -ms /bin/bash ham && \
    #  mkdir -p /opt/ham && chown ham:ham /opt/ham && \
      sed -i -e 's/\s*Defaults\s*secure_path\s*=/# Defaults secure_path=/' /etc/sudoers && \
      echo "ham ALL=NOPASSWD: ALL" >> /etc/sudoers

# The following security actions are recommended by some security scans.
# https://console.bluemix.net/docs/services/va/va_index.html
RUN  sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS    90/' /etc/login.defs && \
      sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS    1/' /etc/login.defs && \
      sed -i 's/sha512/sha512 minlen=8/' /etc/pam.d/common-password

# apache2
RUN apt-get install -y apache2
RUN a2enmod rewrite

# add needed libraries
RUN apt-get install -y imagemagick

# setup PHP 7.3
RUN apt-get install -y php7.3 php7.3-mbstring php7.3-opcache php7.3-xml php7.3-curl php7.3-json php7.3-sqlite3 php7.3-mysql php7.3-zip php7.3-gd php7.3-imap

# install latest xdebug pecl via pecl
RUN apt-get install -y php7.3-dev php-pear
RUN pecl install xdebug

RUN apt-get install -y php-imagick

# setup node 12
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -  && apt-get install -y nodejs

# setup global composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
   # php -r "if (hash_file('sha384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"  && \
    php composer-setup.php  && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer

EXPOSE 80

WORKDIR /var/www/html