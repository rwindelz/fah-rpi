# docker buildx build --platform linux/arm64 -t rwindelz/fah-rpi:latest --push .
### Build stage #######################################################
FROM debian:stable as builder

# Set fahclient major/minor version
ARG CLIENT_MAJOR_VERSION=7.6
ARG CLIENT_MINOR_VERION=21

USER root
RUN apt update && \
    apt install -y curl bzip2 debconf-utils

# Install folding@home fahclient
WORKDIR /root
RUN curl -O https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-arm64/v${CLIENT_MAJOR_VERSION}/fahclient_${CLIENT_MAJOR_VERSION}.${CLIENT_MINOR_VERION}_arm64.deb
RUN dpkg -i --force-depends fahclient_${CLIENT_MAJOR_VERSION}.${CLIENT_MINOR_VERION}_arm64.deb

### Image stage #######################################################
FROM debian:stable-slim
LABEL maintainer="rwindelz@github.com"

RUN apt update

COPY --from=builder /usr/bin/FAH* /usr/bin/
COPY --from=builder /etc/init.d/FAHClient /etc/init.d/FAHClient
COPY --from=builder /etc/fahclient /etc/fahclient

WORKDIR /var/lib/fahclient
CMD	["/usr/bin/FAHClient", \
	"--config", "/etc/fahclient/config.xml", \
	"--config-rotate=false", \
	"--pid-file=/var/run/fahclient.pid"]
