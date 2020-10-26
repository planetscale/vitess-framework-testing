FROM rust

ADD upstream /src
WORKDIR /src/examples/mysql/todos
RUN \
	mv -vf src/main.rs src/main.rs.real && \
	echo 'fn main() {}' > src/main.rs && \
	cargo build && \
	mv -vf src/main.rs.real src/main.rs
ENTRYPOINT ["cargo", "run"]

