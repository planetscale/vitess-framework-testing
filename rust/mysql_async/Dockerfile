FROM rust AS builder

ADD src/Cargo.toml /src/
WORKDIR /src
ADD src/src /src/src
RUN cargo build
ENTRYPOINT ["/src/target/debug/mysql-test"]

FROM fedora:32
COPY --from=builder /src/target/debug/mysql-test /
ENTRYPOINT ["/mysql-test"]

