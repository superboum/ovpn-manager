############################################################
# VPN Server
# Based on Ubuntu
############################################################

FROM ubuntu
MAINTAINER Quentin Dufour <quentin@dufour.tk>

RUN apt-get update && apt-get install -y ruby openvpn build-essential ruby-dev libsqlite3-dev git iptables
RUN gem install bundler

ADD . /root/manager
WORKDIR /root/manager
RUN git reset --hard HEAD && rm -rf .git/ persist/* log/*
RUN bundle install
RUN cp config/database.sample.yml config/database.yml

EXPOSE 1194/udp
EXPOSE 9292


VOLUME ["/root/manager/persist"]

CMD ["./start"]
