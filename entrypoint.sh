#!/bin/bash
set -e

export LD_LIBRARY_PATH=$STEAM_RUNTIME_DIR/i386/lib/i386-linux-gnu:$STEAM_RUNTIME_DIR/i386/usr/lib/i386-linux-gnu:$LD_LIBRARY_PATH

echo "Launching server..."
exec $STEAM_RUNTIME_DIR/run.sh ./hlds_run "$@"
