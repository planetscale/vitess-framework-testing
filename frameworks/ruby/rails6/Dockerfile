FROM ruby:2.6.5

ADD src /src
WORKDIR /src
ENV PATH /src/bin:$PATH
RUN bundle install & apt-get update && apt-get install -y yarnpkg && rm -Rvf /var/lib/apt && yarn install --check-files && wait

ENV RAILS_ENV=prod

ENTRYPOINT ["rake", "db:migrate"]

