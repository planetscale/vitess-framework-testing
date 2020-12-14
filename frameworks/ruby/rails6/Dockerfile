FROM ruby:2.6.5

RUN gem update bundler

ADD src/Gemfile /src/Gemfile
WORKDIR /src
ENV PATH /src/bin:$PATH

RUN bundle install --no-deployment & apt-get update && apt-get install -y yarnpkg && rm -Rvf /var/lib/apt && wait && rm -Rvf /src
ADD src /src
RUN bundle install && yarn install --check-files

ENV RAILS_ENV=production

ENTRYPOINT ["rake", "db:migrate"]

