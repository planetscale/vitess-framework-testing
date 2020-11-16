FROM rust

RUN git clone https://github.com/launchbadge/sqlx.git /src/upstream
RUN apt-get update && apt-get install -y mariadb-client-10.3

WORKDIR /src/upstream/examples/mysql/todos
ARG DATABASE_URL

ADD run /src/run

ENTRYPOINT ["/src/run"]

