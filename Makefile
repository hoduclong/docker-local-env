DOCKER_COMPOSE = docker compose

# Common services (shared between all versions)
COMMON_SERVICES = nginx mysql mailhog elasticsearch redis

# PHP version–specific services
SERVICES_81C2 = $(COMMON_SERVICES) php81-c2
SERVICES_82   = $(COMMON_SERVICES) php82
SERVICES_83   = $(COMMON_SERVICES) php83
SERVICES_84   = $(COMMON_SERVICES) php84

.PHONY: up81-c2 up82 up83 up84 down ps logs restart81-c2 restart82 restart83 bash plato hanleys npm-run-watch

# ======= UP COMMANDS =======
up81-c2:
	$(DOCKER_COMPOSE) up -d $(SERVICES_81C2)

up82:
	$(DOCKER_COMPOSE) up -d $(SERVICES_82)

up83:
	$(DOCKER_COMPOSE) up -d $(SERVICES_83)

up84:
	$(DOCKER_COMPOSE) up -d $(SERVICES_84)

# ======= RESTART COMMANDS =======
restart81-c2: down up81-c2
restart82: down up82
restart83: down up83
restart84: down up84

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

plato:
	@$(MAKE) bash V=82 D=plato

hanleys:
	@$(MAKE) bash V=83 D=hanleys

npm-run-watch:
	@$(MAKE) bash V=82 D=plato
	cd app/design/frontend/Webqem/myplates/web/tailwind
	npm run watch