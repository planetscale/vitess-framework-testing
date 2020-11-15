FROM haskell:8.6

RUN \
	apt-get update && \
	apt-get install -y libmariadb-dev-compat libpcre3-dev libghc-hsopenssl-dev ghc-8.6.5-prof && \
	rm -Rvf /var/lib/apt

RUN \
	cabal update && \
	cabal install --enable-profiling persistent-mysql mysql-simple tasty-hunit

ADD src /src

WORKDIR /src
RUN cabal v2-build

ENTRYPOINT ["/src/dist-newstyle/build/x86_64-linux/ghc-8.6.5/test-0.1.0.0/build/test/test"]
