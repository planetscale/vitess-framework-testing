FROM php:8-cli

RUN docker-php-ext-install mysqli

ADD src/run /src/run
ENTRYPOINT ["/src/run"]

