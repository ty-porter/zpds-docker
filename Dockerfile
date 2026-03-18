# syntax=docker/dockerfile:1
FROM ubuntu:24.04

ENV GAME=zp
ENV SERVER_APP_ID=4523420
ENV CLIENT_APP_ID=3825360

# Internal Directories
ENV BASE_DIR=/opt/steam
ENV STEAMCMD_DIR=${BASE_DIR}/steamcmd
ENV STEAM_RUNTIME_DIR=${BASE_DIR}/steam-runtime
ENV SERVER_DIR=${BASE_DIR}/server

# Addons directories
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
        nano \
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

# Install game server
RUN ${STEAMCMD_DIR}/steamcmd.sh \
        +@sSteamCmdForcePlatformType linux \
        +force_install_dir ${SERVER_DIR} \
        +login anonymous \
        +app_update ${SERVER_APP_ID} validate \
        +logout \
        +quit

# Set up Steam client SDKs & app IDs
RUN mkdir -p /home/steam/.steam/sdk32 /root/.steam/sdk32 && \
    cp ${STEAMCMD_DIR}/linux32/steamclient.so /home/steam/.steam/sdk32/steamclient.so && \
    cp ${STEAMCMD_DIR}/linux32/steamclient.so /root/.steam/sdk32/steamclient.so && \
    printf '%s\n' "${CLIENT_APP_ID}" > ${SERVER_DIR}/steam_appid.txt && \
    chmod 444 ${SERVER_DIR}/steam_appid.txt

# Install Metamod-P into server addons
RUN mkdir -p ${ADDONS_DIR} ${SERVER_DIR}/tmp ${METAMOD_DIR}/dlls && \
    curl -sL https://github.com/Bots-United/metamod-p/releases/download/v1.21p38/metamod_i686_linux_win32-1.21p38.tar.xz \
    | tar -C ${SERVER_DIR}/tmp -xvJf - && \
    cp ${SERVER_DIR}/tmp/metamod.so ${METAMOD_DIR}/dlls && \
    rm -rf ${SERVER_DIR}/tmp && \
    sed -i 's|gamedll_linux "dlls/zp.so"|gamedll_linux "addons/metamod/dlls/metamod.so"|' ${SERVER_DIR}/zp/liblist.gam && \
    touch ${METAMOD_DIR}/config.ini && \
    printf 'gamedll %s/zp/dlls/zp.so' ${SERVER_DIR} > ${METAMOD_DIR}/config.ini

# Install AMX Mod X into server addons
RUN mkdir -p ${SERVER_DIR}/tmp && \
    curl -sL https://www.amxmodx.org/amxxdrop/1.10/amxmodx-1.10.0-git5474-base-linux.tar.gz \
    | tar -C ${SERVER_DIR}/tmp -zxvf - && \
    cp -r ${SERVER_DIR}/tmp/addons/amxmodx ${ADDONS_DIR} && \
    rm -rf ${SERVER_DIR}/tmp && \
    touch ${METAMOD_DIR}/plugins.ini && \
    printf "linux %s/dlls/amxmodx_mm_i386.so" ${AMXMODX_DIR} > ${METAMOD_DIR}/plugins.ini

COPY entrypoint.sh /entrypoint.sh
COPY server.cfg.seed ${SERVER_DIR}/zp/server.cfg
COPY scripts/ ${SERVER_DIR}/scripts

RUN chmod +x /entrypoint.sh

WORKDIR /opt/steam/server

ENTRYPOINT ["/entrypoint.sh"]
