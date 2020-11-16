FROM rust

RUN git clone https://github.com/launchbadge/sqlx.git /src/upstream
WORKDIR /src/examples/mysql/todos
ARG DATABASE_URL
ENTRYPOINT ["run"]

