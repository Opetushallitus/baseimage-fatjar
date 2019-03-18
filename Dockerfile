FROM adoptopenjdk/openjdk11:alpine-slim

ENV LD_LIBRARY_PATH /usr/lib

COPY files/dump_threads.sh /root/bin/
COPY files/run.sh /tmp/scripts/run

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
