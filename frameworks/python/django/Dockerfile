FROM python

RUN mkdir /src
ADD src /src/
WORKDIR /src
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT python manage.py shell < test.py

