# This Makefile provides targets for Python-related tasks
# Includes typecheck and testing

typecheck: ## Typecheck with mypy
	uv run mypy . --exclude .venv --strict --warn-unreachable --warn-return-any --disallow-untyped-calls
.PHONY: typecheck

test-python: ## Run Python tests with pytest
	uv run pytest .
.PHONY: test-python
