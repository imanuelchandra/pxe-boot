FROM debian:bullseye

MAINTAINER Chandra Lefta <lefta.chandra@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN groupadd -g 6565 pxeboot
RUN useradd -d /home/pxeboot -ms /bin/bash pxeboot  -u 6565 -g 6565
RUN usermod -a -G root pxeboot

RUN apt-get -y update
RUN apt-get install -y iproute2 procps \
                       nfs-kernel-server nfs-common rpcbind portmap  
RUN apt clean 

ENV NAME pxeboot
ENV HOME /home/pxeboot

WORKDIR /home/pxeboot

VOLUME /home/pxeboot

ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["eth0"]