FROM rust

ADD Cargo.toml /src/
ADD src /src/src
WORKDIR /src
RUN cargo build && rm -Rvf target/*/deps target/*/incremental target/*/build
ENTRYPOINT ["/src/target/debug/mysql-test"]
