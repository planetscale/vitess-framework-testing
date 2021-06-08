FROM python:3.9-alpine3.12

# Add all the OS dependencies we'll need at run-time in this layer; doing this
#    first saves developer time on incremental builds, because these don't
#    change often
RUN apk add --no-cache mariadb-connector-c zlib jpeg

# Next, add our Python dependencies; we install build-time dependencies and
#    remove them in the same layer to reduce final image size.  Doing this
#    before adding our own code also saves time on incremental builds.
ADD src/requirements.txt /src/requirements.txt
RUN \
	apk add --no-cache --virtual .build-deps gcc libc-dev mariadb-dev zlib-dev jpeg-dev musl-dev && \
	pip install --no-cache-dir -r /src/requirements.txt && \
	apk del .build-deps

ADD src /src
WORKDIR /src
ENTRYPOINT ["sh", "-c", "python manage.py makemigrations && python manage.py migrate && python manage.py test -v 2"]
