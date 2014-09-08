FROM sameersbn/ubuntu:14.04.20140818
MAINTAINER sameer@damagehead.com

RUN echo -n > /etc/apt/apt.conf.d/01proxy
RUN wget -q https://deb.nodesource.com/setup -O - | bash - \
 && apt-get install -y build-essential checkinstall git nodejs authbind \
 && npm install -g bower \
 && rm -rf /var/lib/apt/lists/* # 20140818

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
