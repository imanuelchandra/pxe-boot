FROM debian:bullseye

MAINTAINER Chandra Lefta <lefta.chandra@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update
RUN apt-get install -y iproute2 procps sudo fuse bindfs \
                       nfs-kernel-server \
                       nfs-common rpcbind portmap 
RUN apt clean 

RUN groupadd -g 6565 pxeadmin
RUN useradd -d /home/pxeadmin -ms /bin/bash pxeadmin -u 6565 -g 6565
RUN usermod -aG sudo pxeadmin
RUN passwd -d pxeadmin
RUN echo 'pxeadmin ALL=(ALL) ALL' >> /etc/sudoers

ADD boot.sh /boot.sh
RUN chmod +x /boot.sh

ENTRYPOINT ["/boot.sh"]
CMD ["eth0"]