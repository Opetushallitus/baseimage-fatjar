FROM adoptopenjdk/openjdk11:alpine-slim

RUN addgroup -S oph -g 1001 && adduser -u 1001 -S -G oph oph

COPY files/dump_threads.sh /usr/local/bin/
COPY files/run.sh /usr/local/bin/run

WORKDIR /root/
COPY *.sh ./
RUN \
  sh install.sh && \
  sh test.sh && \
  rm *.sh
