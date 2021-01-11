FROM rust

RUN apt-get update && apt-get install -y mariadb-client-10.3
RUN cargo install diesel_cli --no-default-features --features mysql
RUN git clone https://github.com/mcronce/diesel.git /src/upstream

WORKDIR /src/upstream/examples/mysql
RUN \
	set -ex && \
	for dir in *; do \
		if [ -d "${dir}" ]; then \
			cd "${dir}" && \
			cargo build && \
			cd ..; \
		fi; \
	done

ARG DATABASE_URL

ADD run /src/run

ENTRYPOINT ["/src/run"]

