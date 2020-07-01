FROM centos:latest

COPY ./assets /assets
RUN chmod +x /assets/install.sh && /assets/install.sh

USER oracle
ENTRYPOINT ~/start-wsl.sh