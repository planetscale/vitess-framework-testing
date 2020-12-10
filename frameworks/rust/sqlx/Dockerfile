FROM rust

RUN apt-get update && apt-get install -y mariadb-client-10.3
RUN cargo install sqlx-cli
RUN git clone https://github.com/launchbadge/sqlx.git /src/upstream

WORKDIR /src/upstream/examples/mysql/todos
# Cache a layer with all the dependencies built
RUN \
	# TODO:  Remove this `sed` once https://github.com/launchbadge/sqlx/pull/882 is merged
	sed -i 's/"mysql"/"mysql", "runtime-async-std-rustls"/' Cargo.toml && \
	mv -vf src src.real && \
	mkdir src && \
	echo 'fn main() {}' > src/main.rs && \
	cargo build && \
	rm -Rvf src && \
	mv -vf src.real src

ARG DATABASE_URL

ADD run /src/run

ENTRYPOINT ["/src/run"]

