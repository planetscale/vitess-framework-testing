FROM rust

ADD upstream /src
WORKDIR /src/examples/mysql/todos
ARG DATABASE_URL
RUN cargo build
ENTRYPOINT ["cargo", "run"]

