FROM ubuntu:22.04

RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y wget xz-utils build-essential libxml2-dev git zip

ARG LDC_VERSION=1.40.0

RUN wget -P /cogito/tools \
	https://github.com/ldc-developers/ldc/releases/download/v$LDC_VERSION/ldc2-$LDC_VERSION-linux-x86_64.tar.xz
RUN tar -C /usr --strip-components=1 \
	-Jxvf /cogito/tools/ldc2-$LDC_VERSION-linux-x86_64.tar.xz

COPY ./src /cogito/src
COPY ./Makefile /cogito/Makefile
COPY ./dub.json /cogito/dub.json
COPY ./dub.selections.json /cogito/dub.selections.json
COPY ./.git /cogito/.git

WORKDIR /cogito
RUN make -C /cogito install && make -C /cogito release

ENTRYPOINT ["/cogito/build/release/bin/cogito"]
