# Strict mode
set -eu

echo "Test that required software is installed"
apk --version
aws --version
java -version
j2 --version
cat /etc/alpine-release

echo "Test that baseimage has files expected by the application during run script"
ls -la /root/jmx_prometheus_javaagent.jar
ls -la /root/node_exporter

echo "Largest directories:"
du -d 3 -m /|sort -nr|head -n 20
