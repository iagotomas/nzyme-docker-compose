FROM ubuntu:22.04

ARG NZYME_VERSION=2.0.0-alpha.9
ENV NZYME_NODE_NAME=nzyme-node-01
ENV NZYME_HOSTNAME=localhost
ENV NZYME_PORT=22900
ENV NZYME_DB_PASSWORD=nzyme
ENV NZYME_DB_USERNAME=nzyme
ENV NZYME_DB_HOST=postgres
ENV NZYME_FETCH_OUIS=true
ENV NZYME_NTP_SERVER=pool.ntp.org
ENV NZYME_VERSION_CHECKS=true

RUN apt-get -y update && apt-get install -y wget openjdk-11-jre-headless gettext
RUN wget -q https://github.com/nzymedefense/nzyme/releases/download/${NZYME_VERSION}/nzyme-node_${NZYME_VERSION}.deb && dpkg -i nzyme-node_${NZYME_VERSION}.deb

COPY ./conf/nzyme.conf.template /etc/nzyme/
COPY ./run-nzyme.sh /
RUN chmod +x /run-nzyme.sh
CMD /run-nzyme.sh