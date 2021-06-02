FROM python:3.9-alpine3.12

RUN apk add --no-cache mariadb-connector-c

ADD src/requirements.txt /src/requirements.txt
RUN \
	apk add --no-cache --virtual .build-deps gcc libc-dev mariadb-dev zlib-dev jpeg-dev gcc musl-dev && \
	pip install --no-cache-dir -r /src/requirements.txt 

ADD src /src
WORKDIR /src
ENTRYPOINT ["sh", "-c", "python manage.py makemigrations && python manage.py migrate && python manage.py test -v 2"]

