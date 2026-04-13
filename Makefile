DOCKER_COMPOSE = docker compose

# Common services (shared between all versions)
COMMON_SERVICES = nginx mysql mailhog elasticsearch8 redis
COMMON_SERVICES_O = nginx mysql mailhog opensearch redis
COMMON_SERVICES_7 = nginx mysql mailhog elasticsearch redis

# Magento 2.3.5-p1 stack: PHP 7.3 + MySQL 5.7 (no Elasticsearch required)
SERVICES_235 = nginx mysql57 mailhog redis php73

# PHP version–specific services
SERVICES_81C2 = $(COMMON_SERVICES) php81-c2
SERVICES_82   = $(COMMON_SERVICES) php82
SERVICES_83   = $(COMMON_SERVICES) php83
SERVICES   = $(COMMON_SERVICES) php81-c2 php83 php82 php84 php73
SERVICES_O   = $(COMMON_SERVICES_O) php81-c2 php83 php82 php73
SERVICES_7   = $(COMMON_SERVICES_7) php81-c2 php83 php82 php73

.PHONY: up81-c2 up82 up83 up84 up235 down ps logs restart81-c2 restart82 restart83 restart235 bash plato hanleys npm-run-watch create-db import-db setup-db ssl create-vhost init-site

# ======= UP COMMANDS =======
up81-c2:
	$(DOCKER_COMPOSE) up -d $(SERVICES_81C2)

up82:
	$(DOCKER_COMPOSE) up -d $(SERVICES_82)

up83:
	$(DOCKER_COMPOSE) up -d $(SERVICES_83)

up:
	$(DOCKER_COMPOSE) up -d $(SERVICES)

up-o:
	$(DOCKER_COMPOSE) up -d $(SERVICES_O)

up-7:
	$(DOCKER_COMPOSE) up -d $(SERVICES_7)

# Magento 2.3.5-p1: PHP 7.3 + MySQL 5.7
up235:
	$(DOCKER_COMPOSE) up -d $(SERVICES_235)


# ======= RESTART COMMANDS =======
restart81-c2: down up81-c2
restart82: down up82
restart83: down up83
restart: down up
restart235: down up235

# ======= COMMON TASKS =======
down:
	$(DOCKER_COMPOSE) down

ps:
	$(DOCKER_COMPOSE) ps

logs:
	$(DOCKER_COMPOSE) logs -f

# ======= SHELL / UTILS =======
bash:
	./scripts/shell php$(V) bash -c "cd /home/public_html/local.$(D).com && bash"

bash/src:
	./scripts/shell php$(V) bash -c "cd /home/public_html/local.$(D).com/src && bash"

plato:
	@$(MAKE) bash V=82 D=plato

hanleys:
	@$(MAKE) bash V=82 D=hanleys

rowe:
	@$(MAKE) bash V=82 D=rowe

five-senses:
	@$(MAKE) bash V=81-c2 D=five-senses

mycar:
	@$(MAKE) bash V=83 D=mycar

mycar-api:
	@$(MAKE) bash V=81-c2 D=mycar-api

jllennard:
	@$(MAKE) bash V=81-c2 D=jllennard

jll-legacy:
	@$(MAKE) bash V=73 D=jll-legacy

rv-express:
	@$(MAKE) bash V=83 D=rv-express

m235:
	@$(MAKE) bash V=72 D=$(D)

maxcare:
	@$(MAKE) bash/src V=83 D=maxcare

npm-run-watch:
	@$(MAKE) bash V=82 D=plato
	cd app/design/frontend/Webqem/myplates/web/tailwind
	npm run watch

# ======= SITE MANAGEMENT =======
site-start:
	./scripts/site start $(DOMAIN)

site-stop:
	./scripts/site stop $(DOMAIN)

site-list:
	./scripts/site list

create-db:
	./scripts/database create --database-name=$(DB)

import-db:
	./scripts/database import --source=$(D).sql --target=$(D)

setup-db:
	@echo "▶ Setup database: $(D)"
	./scripts/database create --database-name=$(D)

	@if echo "$(S)" | grep -q '\.gz$$'; then \
		echo "▶ Detected .gz file, extracting..."; \
		gunzip -c $(S) > /tmp/db_import.sql; \
		./scripts/database import --source=/tmp/db_import.sql --target=$(D); \
		rm -f /tmp/db_import.sql; \
	else \
		echo "▶ Importing SQL file..."; \
		./scripts/database import --source=$(D).sql --target=$(D); \
	fi

	@echo "✅ Database setup completed"

ssl:
	./scripts/ssl --domain=$(D)

create-vhost:
	./scripts/create-vhost \
		--domain=$(D) \
		--app=magento2 \
		--root-dir=$(D)/public \
		--php-version=$(P)

init-site: create-vhost ssl
	@echo "✅ Site $(D) and version $(P) is ready"