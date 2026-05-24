FROM registry.access.redhat.com/ubi9/openjdk-17-runtime:latest

USER 0

ARG TOMCAT_VERSION=10.1.33
ENV CATALINA_HOME=/opt/tomcat
ENV PATH="${CATALINA_HOME}/bin:${PATH}"

RUN set -eux; \
    microdnf install -y tar gzip shadow-utils ca-certificates procps-ng findutils; \
    microdnf clean all; \
    mkdir -p /opt/tomcat; \
    curl -fL --retry 5 --retry-delay 10 \
      "https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
      -o /tmp/tomcat.tar.gz; \
    tar -xzf /tmp/tomcat.tar.gz -C /opt/tomcat --strip-components=1; \
    rm -f /tmp/tomcat.tar.gz; \
    chmod +x /opt/tomcat/bin/*.sh; \
    mkdir -p /opt/tomcat/logs /opt/tomcat/webapps /opt/tomcat/temp /opt/tomcat/work; \
    chgrp -R 0 /opt/tomcat; \
    chmod -R g=u /opt/tomcat

USER 1001

WORKDIR /opt/tomcat
EXPOSE 8080
CMD ["catalina.sh", "run"]
