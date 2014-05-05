FROM debian:7.4
MAINTAINER Bruno Antunes <sardaukar.siet@gmail.com>

# no prompts in APT about being a non-interactive pseudoterm
ENV DEBIAN_FRONTEND noninteractive
# no kernel stuff
ENV INITRD No

# speed up APT and cleanup on exit
RUN echo 'force-unsafe-io' | tee /etc/dpkg/dpkg.cfg.d/02apt-speedup
RUN echo 'DPkg::Post-Invoke {"/bin/rm -f /var/cache/apt/archives/*.deb || true";};' | tee /etc/apt/apt.conf.d/no-cache

# do updates
RUN apt-get update -y && apt-get dist-upgrade -y

# install need stuffs
RUN apt-get install -y build-essential pkg-config make g++ linux-libc-dev libncurses5-dev libnspr4-dev cvs libpcap-dev gdb zip unzip lrzsz gkermit wget

# Synchronet stuff
RUN mkdir /sbbs
WORKDIR /sbbs
RUN ["wget","http://cvs.synchro.net/cgi-bin/viewcvs.cgi/*checkout*/install/GNUmakefile"]
RUN ["make", "install", "SYMLINK=1"]

# cleanup on exit
RUN apt-get clean
RUN rm -rf /var/cache/apt/*

ENV SBBSCTRL /sbbs/ctrl
ENV SBBSROOT /sbbs
ENV SHELL /bin/bash

EXPOSE 23

CMD /sbbs/exec/sbbs -d
