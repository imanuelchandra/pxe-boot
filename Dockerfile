FROM chandralefta/nfs-server:1.1.0

MAINTAINER Chandra Lefta <lefta.chandra@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

RUN groupadd -g 6565 pxeadmin
RUN useradd -d /home/pxeadmin -ms /bin/bash pxeadmin -u 6565 -g 6565
RUN usermod -aG sudo pxeadmin
RUN passwd -d pxeadmin
RUN echo 'pxeadmin ALL=(ALL) ALL' >> /etc/sudoers