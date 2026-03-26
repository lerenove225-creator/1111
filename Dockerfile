FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

USER root
RUN apt-get update && apt-get install -y \
    xvfb x11vnc novnc websockify \
    icewm wine64 wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 user
WORKDIR /home/user

# Téléchargement de l'installateur
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe -O /home/user/mt5setup.exe

EXPOSE 10000

# On réduit la résolution au minimum pour économiser la RAM (800x600)
CMD rm -rf /tmp/.X* && \
    (Xvfb :1 -screen 0 800x600x16 &) && sleep 2 && \
    (icewm &) && sleep 2 && \
    (x11vnc -display :1 -nopw -forever -listen 127.0.0.1 &) && sleep 2 && \
    /usr/bin/websockify --web /usr/share/novnc 10000 127.0.0.1:5900
