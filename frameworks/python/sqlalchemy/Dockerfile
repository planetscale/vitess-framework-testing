FROM python

RUN pip3 install --no-cache-dir mysqlclient asyncpg
ADD src/upstream /src/upstream
RUN pip3 install --no-cache-dir /src/upstream
ADD src /src
WORKDIR /src

ENTRYPOINT ["/src/run-examples-with-database-url"]
