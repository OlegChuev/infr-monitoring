# Variables
DOCKER_COMPOSE = docker-compose.yaml
SERVICE_NAME = web

# Targets

# Default target
all: build bundle_install seed start stop restart logs clean help

.PHONY: build bundle_install seed start stop restart logs clean help shell

##@ Build and Setup

build: ## Build the Docker images
	@docker compose -f $(DOCKER_COMPOSE) build

bundle_install: ## Run bundle install inside the container
	@docker compose -f $(DOCKER_COMPOSE) run --rm $(SERVICE_NAME) bundle install

seed: ## Seed the database with initial data
	@docker compose -f $(DOCKER_COMPOSE) run --rm $(SERVICE_NAME) bin/rails db:create db:migrate db:seed

##@ Service Management

start: ## Start the services in detached mode
	@docker compose -f $(DOCKER_COMPOSE) up -d

stop: ## Stop and remove the services
	@docker compose -f $(DOCKER_COMPOSE) down

restart: ## Restart the services
	@$(MAKE) stop
	@$(MAKE) start

logs: ## View container logs
	@docker compose -f $(DOCKER_COMPOSE) logs -f

clean: ## Clean up containers, volumes, and networks
	@docker compose -f $(DOCKER_COMPOSE) down --volumes --remove-orphans

shell: ## Open terminal in docker
	@docker compose run --rm web /bin/bash

##@ Other

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
