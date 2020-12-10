FROM python

RUN mkdir /src
ADD src /src/
WORKDIR /src
RUN pip install --no-cache-dir -r requirements.txt
ENTRYPOINT ["bash", "-c", "python manage.py makemigrations && python manage.py migrate && python manage.py shell < test.py"]

