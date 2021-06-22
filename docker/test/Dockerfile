FROM python:slim

RUN \
    apt-get update -y && \
    apt-get install -y netcat iputils-ping telnet

# Setting Container
WORKDIR shell/

CMD ["tail", "-f", "/dev/null"]
