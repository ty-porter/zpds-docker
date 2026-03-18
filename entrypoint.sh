#!/bin/bash
set -e

export LD_LIBRARY_PATH=$STEAM_RUNTIME_DIR/i386/lib/i386-linux-gnu:$STEAM_RUNTIME_DIR/i386/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH

# Make steam_appid.txt immutable to prevent HLDS from trying to overwrite it
chattr +i $SERVER_DIR/steam_appid.txt

echo "Launching server..."
exec $STEAM_RUNTIME_DIR/run.sh ./hlds_run "$@"
