FROM alpine:latest

RUN apk update
RUN apk --no-cache add \
  bash \
  bzip2 \
  ca-certificates \
  fontconfig \
  jq \
  openssh \
  openssl \
  python \
  py-yaml \
  py-jinja2 \
  py-pip \
  py2-yaml \
  unzip \
  wget \
  zip

# Install tools for downloading environment configuration during service run script
RUN pip install --upgrade pip
RUN pip install \
  awscli \
  docker-py \
  j2cli \
  jinja2 \
  jinja2-cli \
  pyasn1 \
  pyyaml \
  six

# Install glibc for compiling locale definitions
ENV GLIBC_VERSION 2.28-r0
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
RUN wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
RUN wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk
RUN wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk
RUN apk add \
  glibc-${GLIBC_VERSION}.apk \
  glibc-bin-${GLIBC_VERSION}.apk \
  glibc-i18n-${GLIBC_VERSION}.apk
RUN rm -v glibc-*.apk
RUN /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
RUN /usr/glibc-compat/bin/localedef -i fi_FI -f UTF-8 fi_FI.UTF-8

# Create cache directories for package managers
RUN mkdir /root/.m2/
RUN mkdir /root/.ivy2/

# Generate SSH key and get GitHub public keys
RUN /usr/bin/ssh-keygen -q -t rsa -f /root/.ssh/id_rsa -N ""
RUN /usr/bin/ssh-keyscan -H github.com >> /root/.ssh/known_hosts

# Install Oracle JDK
ENV JDK_DL_PREFIX "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/"
ENV JDK_PACKAGE "jdk-8u181-linux-x64.tar.gz"
ENV JCE_DL_PREFIX "http://download.oracle.com/otn-pub/java/jce/8/"
ENV JCE_PACKAGE "jce_policy-8.zip"
RUN wget -c -q -P /tmp/ --header "Cookie: oraclelicense=accept-securebackup-cookie" ${JDK_DL_PREFIX}/${JDK_PACKAGE}
RUN wget -c -q -P /tmp/ --header "Cookie: oraclelicense=accept-securebackup-cookie" ${JCE_DL_PREFIX}/${JCE_PACKAGE}
RUN mkdir -p /usr/java/latest
RUN tar xf /tmp/${JDK_PACKAGE} -C /usr/java/latest --strip-components=1
RUN ln -s /usr/java/latest/bin/* /usr/bin/
RUN unzip -jo -d /usr/java/latest/jre/lib/security /tmp/${JCE_PACKAGE}

# Size optimization: Unused JDK sources and libraries
RUN rm /usr/java/latest/jre/lib/security/README.txt
RUN rm -rf /usr/java/latest/*src.zip
RUN rm -rf /usr/java/latest/lib/missioncontrol
RUN rm -rf /usr/java/latest/lib/visualvm
RUN rm -rf /usr/java/latest/lib/*javafx*
RUN rm -rf /usr/java/latest/jre/lib/plugin.jar
RUN rm -rf /usr/java/latest/jre/lib/ext/jfxrt.jar
RUN rm -rf /usr/java/latest/jre/bin/javaws
RUN rm -rf /usr/java/latest/jre/lib/javaws.jar
RUN rm -rf /usr/java/latest/jre/lib/desktop
RUN rm -rf /usr/java/latest/jre/plugin/
RUN rm -rf /usr/java/latest/jre/lib/deploy*
RUN rm -rf /usr/java/latest/jre/lib/*javafx*
RUN rm -rf /usr/java/latest/jre/lib/*jfx*
RUN rm -rf /usr/java/latest/jre/lib/amd64/libdecora_sse.so
RUN rm -rf /usr/java/latest/jre/lib/amd64/libprism_*.so
RUN rm -rf /usr/java/latest/jre/lib/amd64/libfxplugins.so
RUN rm -rf /usr/java/latest/jre/lib/amd64/libglass.so
RUN rm -rf /usr/java/latest/jre/lib/amd64/libgstreamer-lite.so
RUN rm -rf /usr/java/latest/jre/lib/amd64/libjavafx*.so
RUN rm -rf /usr/java/latest/jre/lib/amd64/libjfx*.so

# Size optimization: Clear caches
RUN rm -rf /root/.cache
RUN rm -rf /tmp/*

# Tests
RUN apk --version
RUN aws --version
RUN java -version
RUN j2 --version
RUN cat /etc/alpine-release

# Show directory sizes
RUN du -d 2 -h /
