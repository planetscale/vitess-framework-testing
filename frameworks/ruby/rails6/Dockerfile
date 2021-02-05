FROM ruby:2.6.5-alpine

RUN apk add --no-cache yarn sqlite mariadb-connector-c tzdata
RUN gem update bundler

ADD src/Gemfile /src/Gemfile
WORKDIR /src
ENV PATH /src/bin:$PATH

RUN \
	apk add --no-cache --virtual .build-deps build-base sqlite-dev mariadb-connector-c-dev && \
	bundle install -j"$(cat /proc/cpuinfo | grep 'cpu cores' | head -n1 | cut -d: -f2 | awk '{print $1}')" --path=vendor/bundle && \
	apk del .build-deps && \
	rm -Rvf vendor/bundle/ruby/*/cache/*.gem && \
	find vendor/bundle/ruby/*/gems -name '*.c' -or -name '*.o' -print -delete

ADD src/app src/babel.config.js src/config src/package.json src/yarn.lock src/postcss.config.js /src/
RUN yarn install --check-files

ADD src /src

RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

ENV RAILS_ENV=production
ADD run.sh /
ADD testingGuides.py /src/

ENTRYPOINT ["/run.sh"]

