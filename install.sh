# Strict mode
set -eu

echo "Installing dependencies"
apk update
apk --no-cache add \
  bash \
  bzip2 \
  ca-certificates \
  fontconfig \
  jq \
  lftp \
  openssh \
  openssl \
  python \
  py-jinja2 \
  py-pip \
  unzip \
  wget \
  zip

echo "Install specific version of PyYAML for awscli, fixes version conflict"
rm -rf /usr/lib/python3/dist-packages/PyYAML-*
pip install --ignore-installed 'pyyaml==3.13'  # awscli requires this version. Unfortunately it has CVE-2017-18342

echo "Installing tools for downloading environment configuration during service run script"
pip install --upgrade pip
pip install \
  awscli \
  docker-py \
  j2cli \
  jinja2 \
  jinja2-cli \
  pyasn1 \
  six
rm -rf /root/.cache

echo "Downloading glibc for compiling locale definitions"
GLIBC_VERSION="2.28-r0"
wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk
echo "f0a00f56fdee9dc888bafec0bf8f54fb188e99b5346032251abb79ef9c99f079  glibc-${GLIBC_VERSION}.apk" |sha256sum -c
wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk
echo "b9a0d8359b12a9768f6378156f160d40f8e432e78e0b2aabc9d0a81e216e7f49  glibc-bin-${GLIBC_VERSION}.apk" |sha256sum -c
wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n-${GLIBC_VERSION}.apk
echo "948aa0a87b2b93cef561d31c02060a162d592a3545af56171c3f8b0d6f918a48  glibc-i18n-${GLIBC_VERSION}.apk" |sha256sum -c

echo "Installing glibc for compiling locale definitions"
apk add \
  glibc-${GLIBC_VERSION}.apk \
  glibc-bin-${GLIBC_VERSION}.apk \
  glibc-i18n-${GLIBC_VERSION}.apk
rm -v glibc-*.apk
/usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8
/usr/glibc-compat/bin/localedef -i fi_FI -f UTF-8 fi_FI.UTF-8

echo "Creating cache directories for package managers"
mkdir /home/oph/.m2/
mkdir /home/oph/.ivy2/

mkdir /etc/oph

echo "Installing Bouncy Castle bcprov security provider"
BCPROV_DL_PREFIX="https://www.bouncycastle.org/download"
BCPROV_PACKAGE="bcprov-jdk15on-161.jar"
wget -c -q -P /usr/java/latest/jre/lib/ext/ ${BCPROV_DL_PREFIX}/${BCPROV_PACKAGE}
echo "dba6e408f205215ad1a89b70b37353d3cdae4ec61037e1feee885704e2413458  /usr/java/latest/jre/lib/ext/${BCPROV_PACKAGE}" |sha256sum -c

echo "Updating java.security"
JAVA_SECURITY_FILE=/opt/java/openjdk/jre/lib/security/java.security
TMP_SECURITY_FILE=/tmp/java.security.new
BC_SECURITY_PROVIDER_LINE="security.provider.10=org.bouncycastle.jce.provider.BouncyCastleProvider"
awk -v line_to_insert="$BC_SECURITY_PROVIDER_LINE" '/^security.provider./ { if (inserted!=1) {print line_to_insert; inserted=1}  } { print $0 }' $JAVA_SECURITY_FILE > $TMP_SECURITY_FILE
mv $TMP_SECURITY_FILE $JAVA_SECURITY_FILE

echo "Installing Prometheus jmx_exporter"
JMX_EXPORTER_VERSION="0.3.1"
wget -q https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/${JMX_EXPORTER_VERSION}/jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar
mv jmx_prometheus_javaagent-${JMX_EXPORTER_VERSION}.jar jmx_prometheus_javaagent.jar
echo "2a25e74e7af7f4e63c227bf5d0d0a4da9b6b146ce521eca58fcde3bf803f1974  jmx_prometheus_javaagent.jar" |sha256sum -c
mv jmx_prometheus_javaagent.jar /usr/local/bin/

echo "Installing Prometheus node_exporter"
NODE_EXPORTER_VERSION="0.15.1"
wget -q https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
echo "7ffb3773abb71dd2b2119c5f6a7a0dbca0cff34b24b2ced9e01d9897df61a127  node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz" |sha256sum -c
tar -xvzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
rm node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin/
rm -rf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64

echo "Init Prometheus config file"
echo "{}" > /etc/prometheus.yaml

echo "Symlink /root/logs,dumps to /home/oph/logs,dumps for backwards compatibility"
chown -R oph:oph /root
for path in logs dumps; do
  ln -s /home/oph/$path /root/$path
  chown oph:oph -h /root/$path
done


echo "Make run script executable"
chmod ug+x /usr/local/bin/run