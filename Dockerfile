FROM sameersbn/debian:jessie.20140918
MAINTAINER sameer@damagehead.com

RUN echo -n > /etc/apt/apt.conf.d/01proxy
RUN apt-get update \
 && apt-get install -y apt-transport-https \
 && wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
 && echo 'deb https://deb.nodesource.com/node jessie main' > /etc/apt/sources.list.d/nodesource.list \
 && apt-get update \
 && apt-get install -y git nodejs authbind gcc g++ make python libc6-dev \
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
