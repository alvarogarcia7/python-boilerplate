# Include modular makefiles organized by responsibility
include makefiles/uv.mk
include makefiles/python.mk
include makefiles/docker.mk
include makefiles/bash-colors.mk

install-githooks: check-uv ## Install git hooks
	uv run pre-commit install
.PHONY: install-githooks

test: check-uv typecheck test-python ## Execute all tests
.PHONY: test

pre-commit: test ## Git hook for pre-commit
.PHONY: pre-commit

init: ## Initialize this project in this folder (or git worktree) after clone
	${MAKE} install-dev
	${MAKE} install-githooks
	${MAKE} test
.PHONY: init
