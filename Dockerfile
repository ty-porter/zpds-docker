# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ARG GAME=zp
ARG APP_ID=3825360

ENV GAME=${GAME}
ENV APP_ID=${APP_ID}

# Install dependencies
RUN dpkg --add-architecture i386 && \
  apt-get update && \
  apt-get install -y \
    libc6:i386 \
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32tinfo6 \
    curl \
    ca-certificates \
    bash \
    tar \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/steam

# Install SteamCMD
RUN curl -sL https://media.steampowered.com/client/installer/steamcmd_linux.tar.gz \
  | tar zxvf -

# Install Steam Runtime
RUN curl -sL "https://repo.steampowered.com/steamrt-images-scout/snapshots/latest-steam-client-general-availability/steam-runtime.tar.xz" \
  | tar xvJ --no-same-owner && \
  ./steam-runtime/setup.sh

RUN useradd -m -s /bin/bash steam

# Install game server using build secrets
RUN --mount=type=secret,id=steam_username \
    --mount=type=secret,id=steam_password \
    /opt/steam/steamcmd.sh \
      +@sSteamCmdForcePlatformType linux \
      +force_install_dir /opt/steam/server \
      +login "$(cat /run/secrets/steam_username)" "$(cat /run/secrets/steam_password)" \
      +app_set_config ${APP_ID} mod ${GAME} \
      +app_update ${APP_ID} validate \
      +logout \
      +quit && \
    mkdir -p /home/steam/.steam/sdk32 && \
    cp /opt/steam/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so && \
    printf '%s\n' "${APP_ID}" > /opt/steam/server/steam_appid.txt && \
    chmod 444 /opt/steam/server/steam_appid.txt && \
    chown -R steam:steam /opt/steam/server /home/steam/.steam

COPY entrypoint.sh /entrypoint.sh
COPY server.cfg /server.cfg

RUN --mount=type=secret,id=rcon_password \
    --mount=type=secret,id=sv_password \
    sed -i "s|{{RCON_PASSWORD}}|$(cat /run/secrets/rcon_password)|g" /server.cfg && \
    sed -i "s|{{SV_PASSWORD}}|$(cat /run/secrets/sv_password)|g" /server.cfg

RUN chmod +x /entrypoint.sh

USER steam

WORKDIR /opt/steam/server

ENTRYPOINT ["/entrypoint.sh"]
