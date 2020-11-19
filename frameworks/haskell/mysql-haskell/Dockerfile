FROM haskell:8.6

RUN \
	apt-get update && \
	apt-get install -y libghc-hsopenssl-dev ghc-8.6.5-prof && \
	rm -Rvf /var/lib/apt

RUN \
	cabal update && \
	cabal install --enable-profiling mysql-haskell tasty-hunit

WORKDIR /src
ADD src/test.cabal src/cabal.project.local /src/
RUN cabal v2-build --dependencies-only --enable-profiling

ADD src/* /src/

RUN cabal v2-build --enable-profiling

ENTRYPOINT ["/src/dist-newstyle/build/x86_64-linux/ghc-8.6.5/test-0.1.0.0/x/test/build/test/test", "+RTS", "-xc"]

