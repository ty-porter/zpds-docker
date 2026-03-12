# zpds — Zombie Panic! Dedicated Server

Docker setup for running a [Zombie Panic!](https://store.steampowered.com/app/3825360/) dedicated server via SteamCMD.

## Requirements

- Docker
- A Steam account with HL1 and Zombie Panic! required — anonymous login does NOT work!

## Setup

### Environment Variables

Copy `.env.sample` to `.env` and fill in your values:

```bash
cp .env.sample .env
```

| Variable         | Description                           | Default   | Secret?            |
|------------------|---------------------------------------|-----------|--------------------|
| `STEAM_USERNAME` | Steam username                        | REQUIRED  | :heavy_check_mark: |
| `STEAM_PASSWORD` | Steam password                        | REQUIRED  | :heavy_check_mark: |
| `SV_PASSWORD`    | Server password                       | `""`      | :heavy_check_mark: |
| `RCON_PASSWORD`  | RCON password (server administration) | `""`      | :heavy_check_mark: |
| `GAME`           | Game mod directory name               | `zp`      |                    |
| `APP_ID`         | Steam App ID for the dedicated server | `3825360` |                    |

### Server Config

Copy `server.cfg.sample` to `server.cfg` and fill in values:

```bash
cp server.cfg.sample server.cfg
```

### Metamod-P / AMX Mod X Config

The server installs Metamod-P by default and runs AMX Mod X as a plugin.

You can supply `.ini` or `.cfg` files (such as to enable server administrators) for AMX Mod X in `amxmodx/configs` which will be copied to the correct AMX Mod X directories.

See https://www.amxmodx.org/ for details.

## Usage

Credentials are passed as Docker build secrets and are never stored in the image. Docker Compose loads `.env` automatically.

```bash
docker compose up --build
```

The server runs on the following ports:

| Port  | Protocol | Purpose         |
|-------|----------|-----------------|
| 27016 | UDP      | Game            |
| 27015 | TCP      | RCON / queries  |
| 27005 | UDP      | Steam           |
| 26900 | UDP      | Steam           |

## Configuration

Edit `server.cfg` to change server name, passwords, map rotation, and other settings before building the image.

## Verify the server is running

```bash
python query-server.py
```

Sends an A2S_INFO query to `127.0.0.1:27015` and prints the response.
