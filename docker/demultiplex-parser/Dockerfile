FROM python:3.9.0a6-buster

WORKDIR /app

COPY DemultiplexParser .

RUN apt-get update && \
    apt-get -y install python3-pandas

RUN pip3 install --no-cache-dir -r DemultiplexParser/requirements.txt