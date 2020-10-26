FROM python

RUN mkdir /src
ADD requirements.txt /src/
WORKDIR /src
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python3", "test.py"]

