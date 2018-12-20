# MIT License
#
# Copyright (c) 2018 Hilmar Gústafsson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# nxtOSEK cross compiler
FROM ubuntu:14.04

##
# Installation
##

# nxtOSEK dependencies
RUN apt-get update
RUN apt-get -y install build-essential texinfo libgmp-dev libmpfr-dev libppl-dev libcloog-ppl-dev gcc-4.8

# Wine
RUN dpkg --add-architecture i386
RUN wget -nc https://dl.winehq.org/wine-builds/Release.key
RUN apt-key add Release.key
RUN apt-add-repository https://dl.winehq.org/wine-builds/ubuntu/
RUN apt-get -y install apt-transport-https
RUN apt-get update
RUN apt-get -y install --install-recommends winehq-stable

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

