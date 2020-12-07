FROM rust

RUN apt-get update && apt-get install -y mariadb-client-10.3
RUN cargo install sqlx-cli
RUN git clone https://github.com/launchbadge/sqlx.git /src/upstream

WORKDIR /src/upstream/examples/mysql/todos
ARG DATABASE_URL

ADD run /src/run

ENTRYPOINT ["/src/run"]

