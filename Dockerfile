# syntax=docker/dockerfile:1
FROM ubuntu:24.04

# Default game information -- this likely never needs to change!
ARG GAME=zp
ARG APP_ID=3825360

ENV GAME=${GAME}
ENV APP_ID=${APP_ID}

# Directories
ENV BASE_DIR=/opt/steam
ENV STEAMCMD_DIR=${BASE_DIR}/steamcmd
ENV STEAM_RUNTIME_DIR=${BASE_DIR}/steam-runtime
ENV SERVER_DIR=${BASE_DIR}/server
ENV ADDONS_DIR=${SERVER_DIR}/zp/addons
ENV METAMOD_DIR=${ADDONS_DIR}/metamod
ENV AMXMODX_DIR=${ADDONS_DIR}/amxmodx

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
RUN mkdir -p ${STEAMCMD_DIR} && \
    curl -sL https://media.steampowered.com/client/installer/steamcmd_linux.tar.gz \
    | tar -C ${STEAMCMD_DIR} -zxvf -

# Install Steam Runtime
RUN curl -sL "https://repo.steampowered.com/steamrt-images-scout/snapshots/latest-steam-client-general-availability/steam-runtime.tar.xz" \
    | tar xvJ --no-same-owner && \
    ./steam-runtime/setup.sh

RUN useradd -m -s /bin/bash steam

# Install game server using build secrets
RUN --mount=type=secret,id=steam_username \
    --mount=type=secret,id=steam_password \
    ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType linux \
        +force_install_dir ${SERVER_DIR} \
        +login "$(cat /run/secrets/steam_username)" "$(cat /run/secrets/steam_password)" \
        +app_set_config ${APP_ID} mod ${GAME} \
        +app_update ${APP_ID} validate \
        +logout \
        +quit

# Set up Steam client SDKs & app IDs
RUN mkdir -p /home/steam/.steam/sdk32 && \
    cp ${STEAMCMD_DIR}/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so && \
    printf '%s\n' "${APP_ID}" > ${SERVER_DIR}/steam_appid.txt && \
    chmod 444 ${SERVER_DIR}/steam_appid.txt && \
    chown -R steam:steam ${SERVER_DIR} /home/steam/.steam

# Install Metamod-P into server addons
RUN mkdir -p ${ADDONS_DIR} ${SERVER_DIR}/tmp ${METAMOD_DIR}/dlls && \
    curl -sL https://downloads.sourceforge.net/project/metamod-p/Metamod-P%20Binaries/1.21p37/metamod-p-1.21p37-linux_i686.tar.gz \
    | tar -C ${SERVER_DIR}/tmp -zxvf - && \
    cp ${SERVER_DIR}/tmp/metamod.so ${METAMOD_DIR}/dlls && \
    rm -rf ${SERVER_DIR}/tmp && \
    sed -i 's|gamedll_linux "dlls/zp.so"|gamedll_linux "addons/metamod/dlls/metamod.so"|' ${SERVER_DIR}/zp/liblist.gam

# Install AMX Mod X into server addons
RUN mkdir -p ${ADDONS_DIR} ${SERVER_DIR}/tmp && \
    curl -sL https://www.amxmodx.org/amxxdrop/1.10/amxmodx-1.10.0-git5474-base-linux.tar.gz \
    | tar -C ${SERVER_DIR}/tmp -zxvf - && \
    cp -r ${SERVER_DIR}/tmp/addons/amxmodx ${ADDONS_DIR} && \
    rm -rf ${SERVER_DIR}/tmp && \
    touch ${METAMOD_DIR}/plugins.ini && \
    echo "linux addons/amxmodx/dlls/amxmodx_mm_i386.so" > ${METAMOD_DIR}/plugins.ini

COPY entrypoint.sh /entrypoint.sh
COPY server.cfg /server.cfg

# Copy the server config
RUN cp /server.cfg ${SERVER_DIR}/zp/server.cfg && \
    ln -sf zp/server.cfg ${SERVER_DIR}/startup_server.cfg && \
    chmod +x /entrypoint.sh

RUN --mount=type=secret,id=rcon_password \
    --mount=type=secret,id=sv_password \
    sed -i "s|{{RCON_PASSWORD}}|$(cat /run/secrets/rcon_password)|g" /server.cfg && \
    sed -i "s|{{SV_PASSWORD}}|$(cat /run/secrets/sv_password)|g" /server.cfg

USER steam

WORKDIR /opt/steam/server

ENTRYPOINT ["/entrypoint.sh"]
