FROM haskell:8.6 AS builder

RUN \
	sed -i 's/stretch/bullseye/' /etc/apt/sources.list && \
	sed -i '/updates/d' /etc/apt/sources.list && \
	apt-get update && \
	apt-get install -y libghc-hsopenssl-dev ghc-8.6.5-prof

RUN cabal update

WORKDIR /src
ADD src/test.cabal src/cabal.project.local /src/
RUN cabal v2-build --dependencies-only --enable-profiling

ADD src/* /src/

RUN cabal v2-build --enable-profiling

FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y libgmp10 && rm -Rvf /var/lib/apt
COPY --from=builder /src/dist-newstyle/build/x86_64-linux/ghc-8.6.5/test-0.1.0.0/x/test/build/test/test /test

ENTRYPOINT ["/test", "+RTS", "-xc"]

