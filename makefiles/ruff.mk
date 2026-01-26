# This Makefile provides targets for ruff code formatter and linter
# ruff is a fast Python linter and formatter (https://docs.astral.sh/ruff)

format: check-uv ## Format code with ruff
	uv run ruff format .
.PHONY: format

format-check: check-uv ## Check code formatting with ruff (no modifications)
	uv run ruff format . --check
.PHONY: format-check

lint: check-uv ## Lint code with ruff
	uv run ruff check .
.PHONY: lint

lint-fix: check-uv ## Fix linting issues with ruff
	uv run ruff check . --fix
.PHONY: lint-fix
