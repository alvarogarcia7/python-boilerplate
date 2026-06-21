# This Makefile provides targets for Hypothesis property-based testing
# Hypothesis generates test inputs to find edge cases (https://hypothesis.readthedocs.io)

HYPOTHESIS_TESTS := tests/property_tests

test-hypothesis: check-uv ## Run Hypothesis property-based tests
	uv run pytest $(HYPOTHESIS_TESTS)
.PHONY: test-hypothesis

test-hypothesis-verbose: check-uv ## Run Hypothesis property tests verbosely
	uv run pytest $(HYPOTHESIS_TESTS) -v
.PHONY: test-hypothesis-verbose

hypothesis-stats: check-uv ## Run Hypothesis property tests and show generation statistics
	uv run pytest $(HYPOTHESIS_TESTS) --hypothesis-show-statistics
.PHONY: hypothesis-stats

typecheck-hypothesis: check-uv ## Typecheck the Hypothesis property tests with mypy (strict)
	uv run mypy $(HYPOTHESIS_TESTS) --strict --warn-unreachable --warn-return-any --disallow-untyped-calls
.PHONY: typecheck-hypothesis
