#!/bin/bash
set -e

export STEAMCMD="/opt/steam/steamcmd.sh"
export SERVER_DIR="/opt/steam/server"
export STEAM_RUNTIME_DIR=/opt/steam/steam-runtime
export LD_LIBRARY_PATH=/opt/steam/steam-runtime/i386/lib/i386-linux-gnu:/opt/steam/steam-runtime/i386/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH

mkdir -p "$SERVER_DIR"

echo "Starting container..."

# Determine login method
if [ -z "$STEAM_USERNAME" ] || [ -z "$STEAM_PASSWORD" ]; then
  echo "No Steam credentials provided, using anonymous login"
  LOGIN_CMD="+login anonymous"
else
  echo "Using Steam credentials"
  LOGIN_CMD="+login $STEAM_USERNAME $STEAM_PASSWORD"
fi

# Install or update the server
echo "Updating game server..."

$STEAMCMD \
  +@sSteamCmdForcePlatformType linux \
  +force_install_dir "$SERVER_DIR" \
  $LOGIN_CMD \
  +app_set_config "$APP_ID" mod "$GAME" \
  +app_update "$APP_ID" validate \
  +logout \
  +quit


echo "Server installation/update complete."

# Copy steamclient.so after install
mkdir -p /root/.steam/sdk32
cp /opt/steam/linux32/steamclient.so /root/.steam/sdk32/steamclient.so

# Set AppID
echo "$APP_ID\n" > /opt/steam/server/steam_appid.txt
chmod 444 /opt/steam/server/steam_appid.txt

mv /server.cfg /opt/steam/server/zp
ln -sf zp/server.cfg startup_server.cfg

# Start HLDS
echo "Launching server..."

$STEAM_RUNTIME_DIR/run.sh ./hlds_run -game "$GAME" +port 27016 +maxplayers 24 -insecure +map zp_clubzombo