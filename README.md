# zpds — Zombie Panic! Dedicated Server

Docker setup for running a [Zombie Panic!](https://store.steampowered.com/app/3825360/) dedicated server via SteamCMD.

## Requirements

- Docker

## Setup / Installation

```sh
git clone https://github.com/ty-porter/zpds-docker.git

docker compose --build

./populate-host.sh
```

## Start the Server

```sh
docker compose up -d
```

### Tailing Logs

```sh
# Server logs
docker logs -tf zpds-docker-zp-server-1

# FastDL nginx logs
docker logs -tf zpds-docker-fastdl-1
```

## Plugins

### Metamod-P / AMX Mod X

The server installs Metamod-P by default and runs AMX Mod X as a plugin.

See https://www.amxmodx.org/ for details.

## Networking

The server runs on the following ports:

| Port  | Protocol | Purpose         |
|-------|----------|-----------------|
| 27016 | UDP      | Game            |
| 27015 | TCP      | RCON / queries  |
| 27005 | UDP      | Steam           |
| 26900 | UDP      | Steam           |
| 8080  | TCP      | FastDL (HTTP)   |

## Configuration

Edit `server.cfg` to change server name, passwords, map rotation, and other settings before building the image.

## FastDL

A FastDL service (nginx) is included and starts alongside the game server. It serves the game content directory over HTTP on port 8080, allowing clients to download custom maps, models, and sounds without impacting server performance.

To enable it, set `sv_downloadurl` in `server.cfg` before building:

```
sv_downloadurl "http://YOUR_SERVER_IP:8080/"
```

The trailing slash is required.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

## Contact

Ty Porter — tyler.b.porter@gmail.com
