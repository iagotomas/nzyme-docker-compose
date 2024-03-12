FROM ubuntu:22.04

ARG NZYME_VERSION=2.0.0-alpha.9
ENV NZYME_NODE_NAME=nzyme-node-01
ENV DB_PASSWORD=nzyme
ENV DB_USERNAME=nzyme
ENV DB_HOST=postgres
ENV FETCH_OUIS=true
ENV NTP_SERVER=pool.ntp.org
ENV VERSION_CHECKS=true

RUN apt-get -y update && apt-get install -y wget openjdk-11-jre-headless gettext
RUN wget -q https://github.com/nzymedefense/nzyme/releases/download/${NZYME_VERSION}/nzyme-node_${NZYME_VERSION}.deb && dpkg -i nzyme-node_${NZYME_VERSION}.deb

COPY ./conf/nzyme.conf.template /etc/nzyme/
COPY ./run-nzyme.sh /
RUN chmod +x /run-nzyme.sh
CMD /run-nzyme.sh