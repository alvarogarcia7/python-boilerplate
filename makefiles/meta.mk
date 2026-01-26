# This Makefile provides meta targets for verifying the integrity and structure
# of the build system itself

MAKEFILES_DIR := makefiles
# Dynamically discover all .mk files in makefiles directory (excluding meta.mk itself)
MAKEFILES := $(filter-out $(MAKEFILES_DIR)/meta.mk, $(wildcard $(MAKEFILES_DIR)/*.mk))
# Also include the top-level Makefile for verification
ALL_MAKEFILES := Makefile $(MAKEFILES)

# Check that all expected makefiles exist
verify-makefiles-exist: ## Verify all expected makefiles exist
	@for file in $(MAKEFILES); do \
		if [ ! -f "$$file" ]; then \
			echo "ERROR: Missing makefile: $$file"; \
			exit 1; \
		fi; \
	done
	@echo "✓ All expected makefiles exist"
.PHONY: verify-makefiles-exist

# Check that makefiles are readable and contain valid make syntax
verify-makefiles-readable: verify-makefiles-exist ## Verify makefiles are readable
	@for file in $(MAKEFILES); do \
		if ! grep -q . "$$file" 2>/dev/null; then \
			echo "ERROR: Cannot read makefile: $$file"; \
			exit 1; \
		fi; \
	done
	@echo "✓ All makefiles are readable"
.PHONY: verify-makefiles-readable

# Check that main Makefile includes all expected makefiles
verify-main-includes: verify-makefiles-exist ## Verify main Makefile includes all modules
	@for file in $(MAKEFILES); do \
		if ! grep -q "include $$file" Makefile; then \
			echo "ERROR: Main Makefile does not include: $$file"; \
			exit 1; \
		fi; \
	done
	@echo "✓ Main Makefile includes all modular makefiles"
.PHONY: verify-main-includes

# Check that all .PHONY declarations exist
verify-phony-declarations: verify-makefiles-readable ## Verify .PHONY declarations
	@for file in $(MAKEFILES); do \
		if grep -q "^[a-zA-Z0-9_-]*:" "$$file"; then \
			grep "^[a-zA-Z0-9_-]*:" "$$file" | cut -d: -f1 | while read target; do \
				if ! grep -q "\.PHONY: .*$$target" "$$file"; then \
					echo "WARNING: Target '$$target' in $$file not declared as .PHONY"; \
				fi; \
			done; \
		fi; \
	done
	@echo "✓ .PHONY declarations verified"
.PHONY: verify-phony-declarations

# Verify that no duplicate targets exist across makefiles
verify-no-duplicates: verify-makefiles-readable ## Verify no duplicate targets
	@targets=""; \
	for file in $(MAKEFILES); do \
		if [ -f "$$file" ]; then \
			targets="$$targets $$(grep '^[a-zA-Z0-9_-]*:' $$file | cut -d: -f1)"; \
		fi; \
	done; \
	duplicates=$$(printf '%s\n' $$targets | sort | uniq -d); \
	if [ -n "$$duplicates" ]; then \
		echo "ERROR: Duplicate targets found: $$duplicates"; \
		exit 1; \
	fi
	@echo "✓ No duplicate targets across makefiles"
.PHONY: verify-no-duplicates

# Test that all targets from modular makefiles are accessible
verify-targets-accessible: verify-main-includes ## Verify targets are accessible from root
	@targets=$$(grep -h "^[a-zA-Z0-9_-]*:" $(MAKEFILES) | grep -v "^[A-Z_]*:=" | cut -d: -f1 | sort -u); \
	for target in $$targets; do \
		if ! make -n $$target >/dev/null 2>&1; then \
			echo "ERROR: Target '$$target' not accessible from repository root"; \
			exit 1; \
		fi; \
	done; \
	echo "✓ All targets from modular makefiles are accessible"
.PHONY: verify-targets-accessible

# List all available targets with their help text
list-targets: ## List all available make targets
	@echo "Available targets:"; \
	echo ""; \
	grep -h "##" $(ALL_MAKEFILES) 2>/dev/null | \
		grep -E "^[a-zA-Z0-9_-]+:" | \
		sed 's/:.*##\s*/:/' | \
		sed 's/:/ /'
.PHONY: list-targets

# Run all verification checks
verify-all: verify-makefiles-exist verify-makefiles-readable verify-main-includes verify-phony-declarations verify-no-duplicates verify-targets-accessible ## Run all makefile verification checks
	@echo "✓ All makefile verifications passed"
.PHONY: verify-all
