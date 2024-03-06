FROM ubuntu:22.04
RUN apt-get -y update && apt-get install -y wget openjdk-11-jre-headless
RUN wget https://github.com/nzymedefense/nzyme/releases/download/2.0.0-alpha.9/nzyme-node_2.0.0-alpha.9.deb && dpkg -i nzyme-node_2.0.0-alpha.9.deb
COPY ./conf/nzyme.conf /etc/nzyme/
CMD /usr/share/nzyme/bin/nzyme
#RUN postgres psql; CREATE DATABASE nzyme;CREATE USER nzyme WITH ENCRYPTED PASSWORD 'test1';GRANT ALL PRIVILEGES ON DATABASE nzyme TO nzyme;