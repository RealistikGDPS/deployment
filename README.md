# Poltergeist deployment

Runs a Poltergeist server on one Linux host with Docker Compose.

## Components

- **nginx** - the only container with a published port. Sends `/database` and `GAME_PATH` to the app (with `GAME_PATH` rewritten to the app's `/database`), `/songs` to object storage, `/files` to the client builds in `DATA_PATH/files`, and everything else, `/admin` included, to the website.
- **app** - the game server, `ghcr.io/realistikgdps/poltergeist`.
- **web** - the public website (downloads, leaderboards, profiles, accounts) and the admin area under `/admin`, `ghcr.io/realistikgdps/rgdps-web`. It needs the game's icon sprites in `DATA_PATH/assets`; see its README.
- **discord** - optional: posts the events the app and website publish to Discord webhooks, `ghcr.io/realistikgdps/poltergeist-discord`. Only started when `configuration/discord.env` names at least one webhook.
- **warp** - optional: Cloudflare WARP as an HTTP proxy for the official servers, for hosts whose provider they refuse. Built locally; only started when `configuration/warp.json` exists.
- **migrations** - applies the SQL in `migrations/` and exits. The app and website wait for it. Built locally.
- **mysql** and **redis** - on an internal network with no access from outside the stack.

Cloudflare is expected in front, terminating TLS and connecting to `HTTP_PORT` over HTTP.

## Files

```
compose.yaml        the stack
compose.dev.yaml    builds the app and website from the sibling checkouts
.env.example        ports, image tags, paths, memory limits
configuration/      app.env, mysql.env, mysql-root.env, web.env, discord.env, warp.json
nginx/              router template and Cloudflare IP ranges
migrations/         migration image and SQL files
warp/               egress proxy image
scripts/            backup and Cloudflare range refresh
systemd/            nightly backup timer
```

## Setup

```bash
git clone https://github.com/RealistikGDPS/deployment ~/poltergeist
cd ~/poltergeist
make setup      # creates .env and configuration/*.env from the examples
```

Edit `.env` (image tags, `GAME_PATH`, `DATA_PATH`) and `configuration/*.env` (public URL, database passwords, Turnstile keys), copy the game's `Resources/icons` directory and the robot and spider `AnimDesc` plists into `DATA_PATH/assets`, then:

```bash
make deploy
```

Grant the first administrator by hand (`INSERT INTO user_roles (user_id, role_id) VALUES (<id>, 5);`), log into the website with that account and open `/admin`. Download links, registration and the other live switches are set there.

To announce events on Discord, put webhook URLs into `configuration/discord.env`
(one variable per event kind, see the comments there) and run `make deploy`
again; the relay container only exists while at least one is set. Clearing them
all and running `make down` then `make deploy` removes it.

## Official servers

The app fetches Newgrounds song metadata from the official servers, which
refuse whole hosting providers (Cloudflare error 1005). If the Boomlings probe
on the admin status page reports them down from your host, route those requests
through Cloudflare WARP: on any machine run `usque register -a -n poltergeist`
([usque](https://github.com/Diniboy1123/usque), a userspace WARP client), copy
the resulting `config.json` to `configuration/warp.json` with mode 600 and run
`make deploy` again. The `warp` container is built locally, only the app and
website use it, and while it is down they answer as if the song did not exist.

The egress address is shared with other WARP users and the official servers
rate limit it, so after a refusal lookups pause for a minute; this suits
on-demand traffic, not crawling. WARP is a consumer service reached through an
unofficial client and can stop working without notice. Removing the file and
running `make down` then `make deploy` returns to direct egress.

## Commands

```
make deploy               pull images, build migrations, start or update the stack, rebuild the rankings
make ps                   container status
make logs                 follow app, web and nginx logs
make migrate              run pending migrations by hand
make rebuild-leaderboards recompute the Redis rankings from MySQL
make backup               dump MySQL and archive object storage
make cloudflare-ips       refresh nginx/cloudflare.conf
make down                 stop the stack
make dev                  run with local builds of the app and website
```

To update, change the tags in `.env` and run `make deploy`. To roll back, put the old tags back and run it again.

## Cloudflare

- Add a WAF skip rule for `/database/*`. The game client sends no User-Agent and gets blocked otherwise.
- Bypass the cache for `/database/*` and `/admin/*`. `/icons/*` and `/static/*` may be cached; HTML pages set cookies and are not cached by default.
- Enable HSTS at the edge (SSL/TLS, Edge Certificates). TLS ends at Cloudflare, so the header belongs there rather than on the origin.
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
