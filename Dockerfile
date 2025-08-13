FROM fedora:latest

LABEL maintainer="belamadar" \
      description="Farming Simulator 22 Dedicated Server (Wine, Fedora base) in Docker"

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

COPY --chmod=0755 --chown=$USER:$USER entrypoint.sh /fs22/entrypoint.sh

USER $USER
WORKDIR /fs22

EXPOSE 10823/udp 10823/tcp 8080/tcp

ENTRYPOINT ["/fs22/entrypoint.sh"]
