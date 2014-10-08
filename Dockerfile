FROM sameersbn/ubuntu:14.04.20141001
MAINTAINER sameer@damagehead.com

RUN apt-get update \
 && apt-get install -y git nodejs npm authbind python make \
 && npm install -g bower \
 && rm -rf /var/lib/apt/lists/* # 20140918

ADD assets/install /app/
RUN chmod 755 /app/install
RUN /app/install

ADD assets/config/ /app/config/
ADD assets/init /app/init
RUN chmod 755 /app/init

EXPOSE 80

VOLUME ["/home/laboard/data"]
ENTRYPOINT ["/app/init"]
CMD ["app:start"]
