COMPOSE ?= docker compose
DEV := $(COMPOSE) -f compose.yaml -f compose.dev.yaml

# The optional containers are enabled by their configuration alone: the
# Discord relay when at least one webhook is set, the WARP egress proxy when a
# registered identity is in place. A stack without them never starts them.
export COMPOSE_PROFILES := $(shell { grep -qsE '^DISCORD_WEBHOOK_[A-Z_]+=.+' configuration/discord.env && echo discord; test -s configuration/warp.json && echo warp; } | paste -sd,)
# The app and website reach the official servers through the proxy when it runs.
export BOOMLINGS_PROXY_URL := $(if $(findstring warp,$(COMPOSE_PROFILES)),http://warp:8000,)

.PHONY: setup config up down deploy restart ps logs migrate rebuild-leaderboards backup cloudflare-ips dev dev-down

# First run on a fresh host: copies the example configuration into place.
setup:
	@test -f .env || { cp .env.example .env && sed -i "s/^APP_UID=.*/APP_UID=$$(id -u)/; s/^APP_GID=.*/APP_GID=$$(id -g)/" .env; }
	@test -f configuration/app.env || cp configuration/app.env.example configuration/app.env
	@test -f configuration/mysql.env || cp configuration/mysql.env.example configuration/mysql.env
	@test -f configuration/mysql-root.env || cp configuration/mysql-root.env.example configuration/mysql-root.env
	@test -f configuration/web.env || cp configuration/web.env.example configuration/web.env
	@test -f configuration/discord.env || cp configuration/discord.env.example configuration/discord.env
	@mkdir -p "$$(sed -n 's/^DATA_PATH=//p' .env)/storage/songs" "$$(sed -n 's/^DATA_PATH=//p' .env)/assets" "$$(sed -n 's/^DATA_PATH=//p' .env)/files"
	@echo "Edit .env and configuration/*.env, then run: make deploy"

config:
	$(COMPOSE) config --quiet && echo "compose.yaml is valid"

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

# Pull the tags pinned in .env, build the migrations image and roll the stack.
# Migrations run before the app and website come up; a failed migration
# leaves the old containers stopped. The Redis rankings are rebuilt afterwards
# so a migration that rewrites the counters is reflected at once.
deploy:
	$(COMPOSE) pull --ignore-buildable
	$(COMPOSE) up -d --build --remove-orphans
	$(COMPOSE) run --rm rebuild-leaderboards

restart:
	$(COMPOSE) restart app web

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=200 app web nginx

migrate:
	$(COMPOSE) run --rm --build migrations

rebuild-leaderboards:
	$(COMPOSE) run --rm rebuild-leaderboards

backup:
	COMPOSE="$(COMPOSE)" scripts/backup.sh

cloudflare-ips:
	scripts/cloudflare_ips.sh

dev:
	$(DEV) up --build

dev-down:
	$(DEV) down
