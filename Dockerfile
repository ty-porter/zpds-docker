FROM ubuntu:24.04

# Default environment values
ENV GAME=zp
ENV APP_ID=3825360

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

# Create steam directory
WORKDIR /opt/steam

# Install SteamCMD
RUN curl -sL https://media.steampowered.com/client/installer/steamcmd_linux.tar.gz \
  | tar zxvf -

# Install Steam Runtime
RUN curl -sL "https://repo.steampowered.com/steamrt-images-scout/snapshots/latest-steam-client-general-availability/steam-runtime.tar.xz" \
  | tar xvJ --no-same-owner && \
  ./steam-runtime/setup.sh

# Copy entrypoints
COPY entrypoint.sh /entrypoint.sh

# Copy server config
COPY server.cfg /server.cfg

WORKDIR /opt/steam/server

ENTRYPOINT ["/entrypoint.sh"]