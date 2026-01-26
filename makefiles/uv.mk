# This Makefile provides targets for uv package and environment management
# uv is a fast Python package installer and resolver (https://astral.sh/uv)

# Ensure uv is installed
check-uv:
	@command -v uv >/dev/null 2>&1 || (echo "uv is not installed. Please install it from https://astral.sh/uv" && exit 1)
.PHONY: check-uv

# Sync dependencies and create virtual environment
sync: check-uv ## Sync dependencies and create virtual environment
	uv sync
.PHONY: sync

install: check-uv ## Install only production dependencies (no dev deps)
	uv sync --no-dev
.PHONY: install

install-dev: check-uv ## Install production and dev dependencies
	uv sync
.PHONY: install-dev

upgrade: check-uv ## Upgrade all dependencies
	uv sync --upgrade
.PHONY: upgrade
