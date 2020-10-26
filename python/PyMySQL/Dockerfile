FROM python

RUN mkdir /src
ADD src/requirements.txt /src/
WORKDIR /src
RUN pip install --no-cache-dir -r requirements.txt
ADD src/* ./

ENTRYPOINT ["python3", "test.py"]

