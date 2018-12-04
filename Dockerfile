# nxtOSEK cross compiler
FROM ubuntu:14.04

##
# Installation
##

# nxtOSEK dependencies
RUN apt-get update
RUN apt-get -y install tk-dev ncurses-dev libmpfr-dev wget gzip tar software-properties-common xvfb

# Wine
RUN dpkg --add-architecture i386
RUN wget -nc https://dl.winehq.org/wine-builds/Release.key
RUN apt-key add Release.key
RUN apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
RUN apt-get -y install apt-transport-https
RUN apt-get update
RUN apt-get -y install --install-recommends winehq-stable

# texinfo
RUN wget http://ftp.gnu.org/gnu/texinfo/texinfo-4.13.tar.gz
RUN gzip -dc < texinfo-4.13.tar.gz | tar -xf -
RUN cd texinfo-4.13 && ./configure && make && make install

# arm toolchain
COPY --chown=755 build_arm_toolchain.sh home/
RUN home/build_arm_toolchain.sh

##
# Usage setup
##

# User
RUN useradd --create-home \
            --password nxt \ 
            nxt
USER nxt
WORKDIR /home/nxt

# Add nxtOSEK
ENV NXTOSEK /home/nxt/nxtOSEK
ADD nxtOSEK.tar.xz ./

# Enable virtual frame buffer for wine
ENV WINEARCH=win32
ENV DISPLAY 1
RUN Xvfb :1 &
RUN wine wineboot

# Start in code
WORKDIR /home/nxt/code

