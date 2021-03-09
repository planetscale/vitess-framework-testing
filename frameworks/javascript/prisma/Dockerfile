FROM node:alpine3.13

RUN apk add --no-cache patch

RUN mkdir /src
WORKDIR /src

RUN \
	apk add --no-cache git && \
	git clone https://github.com/prisma/prisma.git /src/upstream && \
	rm -Rvf /src/upstream/.git && \
	apk del --no-cache git

ADD hacks.patch /src/
RUN \
	cd /src/upstream && \
	patch -p1 < ../hacks.patch

RUN \
	set -ex && \
	cd upstream && \
	sh .github/workflows/setup.sh && \
	npm cache clean --force && \
	rm -Rf ~/.pnpm-store

ADD run /src/
ENTRYPOINT ["./run"]

