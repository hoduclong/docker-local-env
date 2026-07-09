DOCKER_COMPOSE := DOCKER_CLI_HINTS=false docker compose

# ======= Service Groups =======
COMMON_SERVICES := nginx mysql mailhog elasticsearch8 redis
COMMON_SERVICES_O := nginx mysql mailhog opensearch redis
COMMON_SERVICES_7 := nginx mysql mailhog elasticsearch redis

SERVICES_81C2 := $(COMMON_SERVICES_7) php81-c2
SERVICES_82 := $(COMMON_SERVICES) php82
SERVICES_83 := $(COMMON_SERVICES) php83
SERVICES_235 := nginx mysql57 mailhog redis php73
SERVICES_ALL := $(COMMON_SERVICES) php81-c2 php83 php82 php84 php73
SERVICES_OPEN_SEARCH := $(COMMON_SERVICES_O) php81-c2 php83 php82 php73
SERVICES_ES7 := $(COMMON_SERVICES_7) php81-c2 php83 php82 php73

# ======= Input Helpers =======
# Accept both P=81-c2 and P=php81-c2 for vhost creation.
PHP_VERSION := $(if $(filter php%,$(P)),$(P),php$(P))
ROOT_DIR := $(if $(R),$(R),$(D))
IMPORT_SOURCE := $(if $(S),$(S),$(D).sql)

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show available make targets
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make <target> [VAR=value]\n\nTargets:\n"} /^[[:alnum:]_.\/%-]+:.*##/ {printf "  %-22s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

# ======= Project Profile Commands =======

.PHONY: project-list maxcare stop-maxcare maxcare-shell mycar stop-mycar mycar-shell rowe stop-rowe rowe-shell
project-list: ## List configured project profiles
	./scripts/project list

rowe: ## Start rowe project profile (run its containers)
	./scripts/project start rowe

stop-rowe: ## Stop rowe project profile
	./scripts/project stop rowe

rowe-shell: ## Open php shell inside rowe project container
	@$(MAKE) bash V=82 D=rowe

maxcare: ## Start maxcare project profile
	./scripts/project start maxcare

stop-maxcare: ## Stop maxcare project profile
	./scripts/project stop maxcare

mycar: ## Start mycar project profile
	./scripts/project start mycar

stop-mycar: ## Stop mycar project profile
	./scripts/project stop mycar

init-%: ## Initialize/check a project profile, vhost, and SSL. Usage: make init-myproject
	./scripts/project init $*

run-%: ## Start a project profile. Usage: make run-myproject
	./scripts/project start $*

stop-%: ## Stop a project profile. Usage: make stop-myproject
	./scripts/project stop $*

# ======= Compose Stack Commands =======

.PHONY: up81-c2 up82 up83 up up-o up-7 up235 down ps logs
up81-c2: ## Start shared services + php81-c2 + Elasticsearch 7
	$(DOCKER_COMPOSE) up -d $(SERVICES_81C2)

up82: ## Start shared services + php82 + Elasticsearch 8
	$(DOCKER_COMPOSE) up -d $(SERVICES_82)

up83: ## Start shared services + php83 + Elasticsearch 8
	$(DOCKER_COMPOSE) up -d $(SERVICES_83)

up: ## Start default full stack
	$(DOCKER_COMPOSE) up -d $(SERVICES_ALL)

up-o: ## Start OpenSearch stack
	$(DOCKER_COMPOSE) up -d $(SERVICES_OPEN_SEARCH)

up-7: ## Start Elasticsearch 7 stack
	$(DOCKER_COMPOSE) up -d $(SERVICES_ES7)

up235: ## Start Magento 2.3.5-p1 stack: PHP 7.3 + MySQL 5.7
	$(DOCKER_COMPOSE) up -d $(SERVICES_235)

down: ## Stop and remove this compose stack
	$(DOCKER_COMPOSE) down

ps: ## Show compose services
	$(DOCKER_COMPOSE) ps

logs: ## Follow compose logs
	$(DOCKER_COMPOSE) logs -f

.PHONY: restart81-c2 restart82 restart83 restart restart235
restart81-c2: down up81-c2 ## Recreate php81-c2 stack
restart82: down up82 ## Recreate php82 stack
restart83: down up83 ## Recreate php83 stack
restart: down up ## Recreate default full stack
restart235: down up235 ## Recreate Magento 2.3.5-p1 stack

# ======= Shell Shortcuts =======

.PHONY: bash bash/src plato hanleys five-senses mycar-api jllennard jll-legacy rv-express m235
bash: ## Open bash in /home/public_html/local.<D>.com. Usage: make bash V=82 D=plato
	./scripts/shell php$(V) bash -c "cd /home/public_html/local.$(D).com && bash"

bash/src: ## Open bash in /home/public_html/local.<D>.com/src. Usage: make bash/src V=81-c2 D=maxcare
	./scripts/shell php$(V) bash -c "cd /home/public_html/local.$(D).com/src && bash"

plato: ## Open Plato shell
	@$(MAKE) bash V=82 D=plato

hanleys: ## Open Hanleys shell
	@$(MAKE) bash V=82 D=hanleys

five-senses: ## Open Five Senses shell
	@$(MAKE) bash V=81-c2 D=five-senses

mycar-shell: ## Open Mycar shell
	@$(MAKE) bash V=84 D=mycar

mycar-api: ## Open Mycar API shell
	@$(MAKE) bash V=81-c2 D=mycar-api

jllennard: ## Open JLLennard shell
	@$(MAKE) bash V=81-c2 D=jllennard

jll-legacy: ## Open JLL legacy shell
	@$(MAKE) bash V=73 D=jll-legacy

rv-express: ## Open RV Express shell
	@$(MAKE) bash V=83 D=rv-express

m235: ## Open Magento 2.3.5 shell. Usage: make m235 D=<domain-short-name>
	@$(MAKE) bash V=72 D=$(D)

maxcare-shell: ## Open Maxcare source shell
	@$(MAKE) bash/src V=81-c2 D=maxcare

# ======= Frontend Utilities =======

.PHONY: npm-run-watch
npm-run-watch: ## Run Plato frontend watch command inside php82 container
	./scripts/shell php82 bash -lc "cd /home/public_html/local.plato.com/app/design/frontend/Webqem/myplates/web/tailwind && npm run watch"

# ======= Database Commands =======

.PHONY: create-db import-db setup-db
create-db: ## Create database. Usage: make create-db DB=<database>
	./scripts/database create --database-name=$(DB)

import-db: ## Import databases/import/<D>.sql into database <D>. Usage: make import-db D=<database>
	./scripts/database import --source=$(D).sql --target=$(D)

setup-db: ## Create database and import SQL/GZ. Usage: make setup-db D=<database> S=<file.sql|file.sql.gz>
	@echo "▶ Setup database: $(D)"
	./scripts/database create --database-name=$(D)
	@mkdir -p databases/import
	@if echo "$(IMPORT_SOURCE)" | grep -q '\.gz$$'; then \
		echo "▶ Detected .gz file, extracting..."; \
		tmp_file="$(D)-import.sql"; \
		gunzip -c "$(IMPORT_SOURCE)" > "databases/import/$$tmp_file"; \
		./scripts/database import --source="$$tmp_file" --target=$(D); \
		rm -f "databases/import/$$tmp_file"; \
	else \
		source_file="$$(basename "$(IMPORT_SOURCE)")"; \
		if [ -f "$(IMPORT_SOURCE)" ] && [ "$(IMPORT_SOURCE)" != "databases/import/$$source_file" ]; then \
			cp "$(IMPORT_SOURCE)" "databases/import/$$source_file"; \
		fi; \
		echo "▶ Importing SQL file..."; \
		./scripts/database import --source="$$source_file" --target=$(D); \
	fi
	@echo "✅ Database setup completed"

# ======= Site/Vhost Commands =======

.PHONY: ssl create-vhost init-site
ssl: ## Create SSL for domain. Usage: make ssl D=local.example.com
	./scripts/ssl --domain=$(D)

create-vhost: ## Create nginx vhost. Usage: make create-vhost D=local.example.com P=81-c2 R=local.example.com/src
	./scripts/create-vhost \
		--domain=$(D) \
		--app=magento2 \
		--root-dir=$(ROOT_DIR) \
		--php-version=$(PHP_VERSION)

init-site: create-vhost ssl ## Create vhost and SSL. Usage: make init-site D=local.example.com P=81-c2 R=local.example.com/src
	@echo "✅ Site $(D) and version $(P) is ready"
