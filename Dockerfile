FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV HOME=/home/user

USER root
RUN apt-get update && apt-get install -y \
    xvfb x11vnc novnc websockify \
    xfce4 xfce4-terminal firefox wine64 wget dbus-x11 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Téléchargement de l'installateur MT5 pendant le build
RUN wget https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe -O /tmp/mt5setup.exe

# Création de l'utilisateur standard pour Render
RUN useradd -m -u 1000 user
RUN ln -s /usr/share/novnc/vnc.html /usr/share/novnc/index.html

WORKDIR /home/user
USER user

# Port par défaut utilisé par Render pour les Web Services
EXPOSE 10000

# Lancement des services avec délais de sécurité et IP fixe
CMD rm -rf /tmp/.X* && \
    (Xvfb :1 -screen 0 1280x720x24 &) && sleep 5 && \
    (DISPLAY=:1 startxfce4 &) && sleep 5 && \
    (x11vnc -display :1 -nopw -forever -listen 127.0.0.1 &) && sleep 5 && \
    websockify --web /usr/share/novnc 10000 127.0.0.1:5900
