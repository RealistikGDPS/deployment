# Poltergeist deployment

Runs a Poltergeist server on one Linux host with Docker Compose.

## Components

- **nginx** - the only container with a published port. Sends `/panel` to the panel and everything else to the app, with `GAME_PATH` rewritten to the app's `/database`.
- **app** - the game server, `ghcr.io/realistikgdps/poltergeist`.
- **panel** - the admin panel, `ghcr.io/realistikgdps/poltergeist-panel`.
- **migrations** - applies the SQL in `migrations/` and exits. The app and panel wait for it. Built locally.
- **mysql** and **redis** - on an internal network with no access from outside the stack.

Cloudflare is expected in front, terminating TLS and connecting to `HTTP_PORT` over HTTP.

## Files

```
compose.yaml        the stack
compose.dev.yaml    builds the app and panel from ../poltergeist and ../poltergeist-panel
.env.example        ports, image tags, paths, memory limits
configuration/      app.env, mysql.env, mysql-root.env
nginx/              router template and Cloudflare IP ranges
migrations/         migration image and SQL files
scripts/            backup and Cloudflare range refresh
systemd/            nightly backup timer
```

## Setup

```bash
git clone https://github.com/RealistikGDPS/deployment ~/poltergeist
cd ~/poltergeist
make setup      # creates .env and configuration/*.env from the examples
```

Edit `.env` (image tags, `GAME_PATH`, `DATA_PATH`) and `configuration/*.env` (public URL, admin API key, database passwords), then:

```bash
make deploy
```

## Commands

```
make deploy               pull images, build migrations, start or update the stack
make ps                   container status
make logs                 follow app, panel and nginx logs
make migrate              run pending migrations by hand
make rebuild-leaderboards recompute the Redis rankings from MySQL
make backup               dump MySQL and archive object storage
make cloudflare-ips       refresh nginx/cloudflare.conf
make down                 stop the stack
make dev                  run with local builds of the app and panel
```

To update, change the tags in `.env` and run `make deploy`. To roll back, put the old tags back and run it again.

## Cloudflare

- Add a WAF skip rule for `/database/*`. The game client sends no User-Agent and gets blocked otherwise.
- Bypass the cache for `/database/*`, `/api/*` and `/panel/*`.
- Firewall `HTTP_PORT` to Cloudflare's IP ranges so the origin cannot be reached directly.

## Backups

`make backup` writes to `BACKUP_PATH` and prunes files older than `BACKUP_RETENTION_DAYS`. Redis is not backed up; it only holds rebuildable data. For a nightly run:

```bash
cp systemd/poltergeist-backup.* ~/.config/systemd/user/
systemctl --user enable --now poltergeist-backup.timer
loginctl enable-linger "$USER"
```

Copy `BACKUP_PATH` off the host with whatever you already use.

## Sizing

The defaults in `.env.example` suit a 6 CPU, 12 GB VPS on SSD. `APP_WORKERS` sets the number of app processes; each has its own MySQL pool, so keep `APP_WORKERS * MYSQL_POOL_MAX` below `MYSQL_MAX_CONNECTIONS`. Halve the memory limits for a 6 GB box.

## Podman

Set `NGINX_RESOLVER` in `.env` to the gateway of the `deployment_proxy` network and run with `COMPOSE="podman compose"`.
