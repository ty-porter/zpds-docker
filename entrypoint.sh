#!/bin/bash
set -e

export STEAM_RUNTIME_DIR=/opt/steam/steam-runtime
export LD_LIBRARY_PATH=/opt/steam/steam-runtime/i386/lib/i386-linux-gnu:/opt/steam/steam-runtime/i386/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH
export HOME=/home/steam

cp /server.cfg /opt/steam/server/zp/server.cfg
ln -sf zp/server.cfg /opt/steam/server/startup_server.cfg

echo "Launching server..."

$STEAM_RUNTIME_DIR/run.sh ./hlds_run -game "$GAME" +port 27016 +maxplayers 24 -insecure +map zp_clubzombo
