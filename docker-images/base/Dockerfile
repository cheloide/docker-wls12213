FROM centos:latest

# ENV http_proxy=myproxy.com:8080
COPY ./assets /assets
RUN chmod +x /assets/install.sh && /assets/install.sh
# ENV http_proxy=
USER oracle
ENTRYPOINT ["/bin/sh"]