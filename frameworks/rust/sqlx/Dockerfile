FROM rust

RUN git clone https://github.com/launchbadge/sqlx.git upstream
ADD upstream /src
WORKDIR /src/examples/mysql/todos
ARG DATABASE_URL
ENTRYPOINT ["run"]

