# Workshop Scripts

These scripts are intended to be ran from within the Docker container.

Downloading from Steam Workshop requires a valid Steam username and password.

## Create `server/workshop`

Create the `server` directory if you haven't already:

```sh
./script/populate-host.sh

mkdir -p server/workshop
```

## Create a list of workshop items to install


```sh
# Use the defaults, or create your own
cp scripts/workshop/items.txt.sample server/workshop/items.txt
```

## Run Workshop Install

```sh
docker compose run --rm --entrypoint scripts/workshop/install-all.sh zpds-docker-zp-server-1 <username> <password>
```
