# zpds — Zombie Panic! Dedicated Server

Docker setup for running a [Zombie Panic!](https://store.steampowered.com/app/3825360/) dedicated server via SteamCMD.

## Requirements

- Docker
- A Steam account with HL1 and Zombie Panic! required — anonymous login does NOT work!

## Setup

Copy `.env.sample` to `.env` and fill in your values:

```bash
cp .env.sample .env
```

| Variable         | Description                           | Default   |
|------------------|---------------------------------------|-----------|
| `STEAM_USERNAME` | Steam username                        |           |
| `STEAM_PASSWORD` | Steam password                        |           |
| `GAME`           | Game mod directory name               | `zp`      |
| `APP_ID`         | Steam App ID for the dedicated server | `3825360` |

## Usage

Build the image:

```bash
docker build -t zp-server .
```

Start the server:

```bash
# Windows
run.bat

# Linux/macOS
bash run.sh
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
