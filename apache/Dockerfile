FROM registry.access.redhat.com/ubi9/httpd-24:latest
USER 0
COPY proxy.conf /etc/httpd/conf.d/00-middleware-lab-proxy.conf
RUN chmod 0644 /etc/httpd/conf.d/00-middleware-lab-proxy.conf
USER 1001
