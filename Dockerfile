FROM ubuntu:22.04

ARG NZYME_VERSION=ubuntu-2204jammy-noarch-2.0.0-alpha.17
ARG NZYME_VERSION_SHORT=2.0.0-alpha.17
ENV NZYME_NODE_NAME=nzyme-node-01
ENV NZYME_HOSTNAME=localhost
ENV NZYME_PORT=22900
ENV NZYME_DB_PASSWORD=nzyme
ENV NZYME_DB_USERNAME=nzyme
ENV NZYME_DB_HOST=postgres
ENV NZYME_FETCH_OUIS=true
ENV NZYME_NTP_SERVER=pool.ntp.org
ENV NZYME_VERSION_CHECKS=true

RUN apt-get -y update && apt-get install -y wget openjdk-17-jre-headless gettext
RUN wget -q https://github.com/nzymedefense/nzyme/releases/download/${NZYME_VERSION_SHORT}/nzyme-node_${NZYME_VERSION}.deb && dpkg -i nzyme-node_${NZYME_VERSION}.deb

COPY ./conf/nzyme.conf.template /etc/nzyme/
COPY ./run-nzyme.sh /
RUN chmod +x /run-nzyme.sh

# Enable console logging for production
COPY ./log4j2.xml /etc/nzyme/log4j2-production.xml

CMD ["/run-nzyme.sh"]