FROM docker.elastic.co/elasticsearch/elasticsearch:7.12.1

RUN TZ=Asia/Taipei \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Setting Container
WORKDIR shell/
