# zpds — Zombie Panic! Dedicated Server

![](https://img.shields.io/badge/platform-linux-blue) ![](https://img.shields.io/badge/Zombie_Panic!-1.1a-blue)

Docker setup for running a [Zombie Panic!](https://store.steampowered.com/app/3825360/) dedicated server via SteamCMD.

## Requirements

- Docker

## Setup / Installation

```sh
git clone https://github.com/ty-porter/zpds-docker.git

docker compose --build

./scripts/populate-host.sh
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

Metamod-P source code and documentation is available [here](https://github.com/Bots-United/metamod-p).

AMX Mod X documentation is available [here](https://www.amxmodx.org/).

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

Once you've built a container and run `./scripts/populate_host.sh`, the server files will be mounted on the host at `server/`. You can edit these files on the host and see changes propagate to your server after restart.

Full configuration guides are beyond what can be provided in this README.

Check out the [ZP! Dedicated Server setup guide](https://steamcommunity.com/sharedfiles/filedetails/?id=3670107945) for general guidance.

Some common configuration that is generally useful:

* `server/zp/server.cfg`:
  - Set an `rcon_password` for server administration
  - Set `sv_password` for a server password

* `server/zp/addons/amxmodx/configs/users.ini`
  - Set a server administrator via SteamID

### FastDL

A FastDL service (nginx) is included and starts alongside the game server. It serves the game content directory over HTTP on port 8080, allowing clients to download custom maps, models, and sounds without impacting server performance.

To enable it, set `sv_downloadurl` in `server/zp/server.cfg`:

```
sv_downloadurl "http://YOUR_SERVER_IP:8080/"
```

The trailing slash is required.

### Workshop Items

See [the Workshop README](/scripts/workshop/README.md) for details on how to install workshop items.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

## Contact

Ty Porter — tyler.b.porter@gmail.com
