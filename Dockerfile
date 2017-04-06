FROM python:3.6-slim

RUN apt-get update && apt-get install -y \
    spatialite-bin \
    libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

WORKDIR /usr/src
