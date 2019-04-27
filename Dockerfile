FROM ruby:1.9

RUN gem install rake -v 12.2.1 \
 && gem install rails -v 2.3.18 \
 && gem install mysql

COPY . /usr/src/app

WORKDIR /usr/src/app/script
EXPOSE 3000
CMD ["./server", "-e", "development"]

ENTRYPOINT ["/usr/src/app/docker-entrypoint.sh"]
