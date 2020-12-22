FROM haskell:8.6 AS builder

RUN \
	apt-get update && \
	apt-get install -y libmariadb-dev-compat libpcre3-dev libghc-hsopenssl-dev ghc-8.6.5-prof && \
	rm -Rvf /var/lib/apt

RUN cabal update

WORKDIR /src
ADD src/test.cabal /src/
RUN cabal v2-build --dependencies-only

ADD src/* /src/

RUN cabal v2-build

FROM debian:stretch-slim
RUN apt-get update && apt-get install -y libgmp10 && rm -Rvf /var/lib/apt
RUN apt-get update && apt-get install -y libpcre3 libmariadb2 && rm -Rvf /var/lib/apt
COPY --from=builder /src/dist-newstyle/build/x86_64-linux/ghc-8.6.5/test-0.1.0.0/build/test/test /test

ENTRYPOINT ["/test"]

