FROM adoptopenjdk/openjdk8:alpine-slim

ARG DL_PATH_TOKEN

COPY files/dump_threads.sh /root/bin/
COPY files/run.sh /tmp/scripts/run

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
