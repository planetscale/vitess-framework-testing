FROM php:7-apache

RUN \
	apt-get update && \
	apt-get install -y git curl libpng-dev libonig-dev libxml2-dev zip unzip && \
	rm -Rvf /var/lib/apt

RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

RUN curl -v https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

RUN rm -Rvf /var/www
ADD /src /var/www
RUN chown -Rc www-data:www-data /var/www
WORKDIR /var/www
RUN composer install
RUN mv -vf public html

ENTRYPOINT ["/var/www/test"]

