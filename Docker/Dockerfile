FROM ubuntu:21.10

# Make sure to open your port in your docker run command (EX: -p 7777:7777)
COPY Server/ /root/build/

RUN chmod +x /root/build/Server.x86_64

WORKDIR /root/build/

CMD ["/root/build/Server.x86_64","-batchmode","-nographics"]