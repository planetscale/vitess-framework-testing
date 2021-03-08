FROM node:alpine3.13

RUN mkdir /src
WORKDIR /src

RUN \
	apk add --no-cache git && \
	git clone https://github.com/prisma/prisma.git /src/upstream && \
	rm -Rvf /src/upstream/.git && \
	apk del --no-cache git
RUN \
	cd upstream && \
	sh .github/workflows/setup.sh && \
	npm cache clean --force && \
	rm -Rf ~/.pnpm-store

RUN apk add --no-cache patch

ADD run __database.ts.patch /src/
ENTRYPOINT ["./run"]

