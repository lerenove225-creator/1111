FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

USER root
RUN apt-get update && apt-get install -y \
    xvfb x11vnc novnc websockify \
    xfce4 xfce4-terminal firefox wine64 wget dbus-x11 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Téléchargement auto de MT5
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe -O /tmp/mt5setup.exe

RUN useradd -m -u 1000 user
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

WORKDIR /home/user
USER user

# Koyeb utilise le port 8000 par défaut ou celui que tu choisis
EXPOSE 8000

CMD rm -rf /tmp/.X* && \
    (Xvfb :1 -screen 0 1280x720x24 &) && sleep 3 && \
    (DISPLAY=:1 startxfce4 &) && sleep 3 && \
    (x11vnc -display :1 -nopw -forever -listen 127.0.0.1 &) && sleep 3 && \
    /usr/bin/websockify --web /usr/share/novnc 8000 127.0.0.1:5900
