FROM golang

ADD . /src
WORKDIR /src
RUN go build .
ENTRYPOINT ["go", "run", "."]
