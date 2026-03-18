#!/bin/bash
# Extracts server files from the Docker image to ./server/ on the host.
# Run once after building the image, before starting the server.

set -e

DEST=./server

echo "Extracting server files to '${DEST}'..."
mkdir -p "${DEST}"
CONTAINER=$(docker create zpds-docker-zp-server)
docker cp "${CONTAINER}:/opt/steam/server/." "${DEST}"
docker rm "${CONTAINER}"

echo "Done."
