FROM ubuntu:18.04

ARG LDC_VERSION=1.30.0

RUN apt-get update && \
	apt-get install -y wget xz-utils build-essential libxml2-dev git zip

COPY ./src /cogito/src
COPY ./include /cogito/include
COPY ./Makefile /cogito/Makefile
COPY ./dub.json /cogito/dub.json
COPY ./.git /cogito/.git

WORKDIR /cogito

RUN wget -P /cogito/tools \
	https://github.com/ldc-developers/ldc/releases/download/v$LDC_VERSION/ldc2-$LDC_VERSION-linux-x86_64.tar.xz
RUN tar -C /usr --strip-components=1 \
	-Jxvf /cogito/tools/ldc2-$LDC_VERSION-linux-x86_64.tar.xz
RUN make -C /cogito install && make -C /cogito release

ENTRYPOINT ["/cogito/build/release/bin/cogito"]
