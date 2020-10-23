FROM python

RUN pip3 install --no-cache-dir mysqlclient
ADD . /src
WORKDIR /src
RUN pip3 install --no-cache-dir ./upstream

ENTRYPOINT ["/src/run-examples-with-database-url"]

