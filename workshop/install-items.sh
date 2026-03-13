#!/bin/bash
set -e

if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: $0 <steam_username> <steam_password>"
  exit 1
fi

ITEMS_FILE="$(dirname "$0")/items.txt"

# Build workshop_download_item args from items.txt (strip comments and blank lines)
workshop_args=()
while IFS= read -r line; do
  id="${line%%;*}"   # everything before the first ;
  id="${id// /}"     # strip spaces
  [[ -z "$id" ]] && continue
  workshop_args+=(+workshop_download_item ${APP_ID} ${id})
done < "$ITEMS_FILE"

pushd $SERVER_DIR

# Install the workshop items
${STEAMCMD_DIR}/steamcmd.sh \
  +@sSteamCmdForcePlatformType linux \
  +force_install_dir ${SERVER_DIR} \
  +login $1 $2 \
  ${workshop_args[@]} \
  +logout \
  +quit
  
# Copy all workshop content into the game directory and generate .res files for WADs
for item_dir in ${SERVER_DIR}/steamapps/workshop/content/${APP_ID}/*/; do
  cp -r "${item_dir}." "${SERVER_DIR}/zp/"

  # For each BSP in this item, create a .res file listing any WADs bundled with it
  wads=()
  while IFS= read -r wad; do
    wads+=("zp/$(basename "$wad")")
  done < <(find "$item_dir" -maxdepth 1 -name "*.wad")

  if [[ ${#wads[@]} -gt 0 ]]; then
    for bsp in "$item_dir"maps/*.bsp; do
      [[ -f "$bsp" ]] || continue
      map=$(basename "$bsp" .bsp)
      res_file="${SERVER_DIR}/zp/maps/${map}.res"
      for wad in "${wads[@]}"; do
        grep -qxF "$wad" "$res_file" 2>/dev/null || echo "$wad" >> "$res_file"
      done
    done
  fi
done

# Add all the maps to the rotation and maplist
for map in $(find ${SERVER_DIR}/zp/maps -name "*.bsp" -exec basename {} .bsp \;); do
  grep -qxF "$map" ${AMXMODX_DIR}/configs/maps.ini || echo "$map" >> ${AMXMODX_DIR}/configs/maps.ini
done

popd
