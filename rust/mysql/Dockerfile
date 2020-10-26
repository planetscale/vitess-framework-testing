FROM rust AS builder

ADD Cargo.toml /src/
WORKDIR /src
RUN \
	mkdir -pv /src/src && \
	echo 'fn main() {}' > /src/src/main.rs && \
	cargo build && \
	rm -Rvf /src/src
ADD src /src/src
RUN cargo build

FROM gcr.io/distroless/cc-debian10
COPY --from=builder /src/target/debug/mysql-test /
ENTRYPOINT ["/mysql-test"]
