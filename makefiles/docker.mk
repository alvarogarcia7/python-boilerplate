# This Makefile provides targets for Docker-related tasks

DOCKER_COMPOSE:=docker-compose
SERVICE_NAME:=app

up: ## Start Docker containers
	$(DOCKER_COMPOSE) up -d
.PHONY: up

down: ## Stop Docker containers
	$(DOCKER_COMPOSE) down
.PHONY: down

bash: ## Access bash shell in Docker container
	$(DOCKER_COMPOSE) exec $(SERVICE_NAME) bash
.PHONY: bash
