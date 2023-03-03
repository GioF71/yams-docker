ARG BASE_IMAGE="${BASE_IMAGE:-python:slim}"
FROM ${BASE_IMAGE} AS BASE

RUN apt-get update
RUN apt-get install -y git
RUN apt-get install -y gcc python3-dev

RUN mkdir /src
WORKDIR /src

RUN git clone https://github.com/Berulacks/yams.git

WORKDIR /src/yams

RUN pip install --upgrade pip
RUN pip install -r requirements.txt
RUN pip3 install .

RUN rm /src -Rf

RUN apt-get remove -y git
RUN apt-get autoremove -y

RUN rm -rf /var/lib/apt/lists/*

FROM scratch
COPY --from=BASE / /

LABEL maintainer="GioF71"
LABEL source="https://github.com/GioF71/yams-docker"

RUN mkdir -p /data
RUN mkdir -p /app/bin
RUN mkdir -p /app/log

RUN chmod -R 755 /app

VOLUME /yams

ENV STARTUP_DELAY_SEC ""

ENV MPD_HOST ""
ENV MPD_PORT ""

ENV USER_MODE ""
ENV PUID ""
ENV PGID ""

COPY app/bin/run-yams.sh /app/bin/run-yams.sh
RUN chmod 755 /app/bin/run-yams.sh

WORKDIR /app/bin

ENTRYPOINT ["/app/bin/run-yams.sh"]

