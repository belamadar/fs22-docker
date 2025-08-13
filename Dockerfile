FROM fedora:latest

LABEL maintainer="you@example.com" \
      description="Farming Simulator 22 Dedicated Server (Wine, Fedora base)"

RUN dnf install -y \
    wine \
    winetricks \
    cabextract \
    tar \
    unzip \
    procps \
    wget \
    && dnf clean all

ENV WINEPREFIX=/fs22/.wine
ENV WINEARCH=win64
ENV USER=another_farmer

RUN useradd -m $USER && \
    mkdir -p /fs22/{game,installer,config,dlc} && \
    chown -R $USER:$USER /fs22

USER $USER
WORKDIR /fs22

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 10823/udp 10823/tcp 8080/tcp

ENTRYPOINT ["/entrypoint.sh"]
