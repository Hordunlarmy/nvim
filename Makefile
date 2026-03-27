# Neovim Config Test Runner
# Uses custom in-process runner (no subprocess spawning issues with lazy.nvim)

NVIM := nvim
INIT := tests/minimal_init.lua
RUNNER := tests/run_tests.lua

# Run all tests
.PHONY: test
test:
	@$(NVIM) --headless -u $(INIT) -c "luafile $(RUNNER)" 2>&1 | grep -v "deprecated"

# Run a single suite (usage: make test-suite SUITE=plugins)
.PHONY: test-suite
test-suite:
	@TEST_SUITE=$(SUITE) $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='$(SUITE)'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

# Individual test suites
.PHONY: test-plugins
test-plugins:
	@TEST_SUITE=plugins $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='plugins'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

.PHONY: test-lsp
test-lsp:
	@TEST_SUITE=lsp $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='lsp'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

.PHONY: test-treesitter
test-treesitter:
	@TEST_SUITE=treesitter $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='treesitter'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

.PHONY: test-formatter
test-formatter:
	@TEST_SUITE=formatter $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='formatter'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

.PHONY: test-clojure
test-clojure:
	@TEST_SUITE=clojure $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='clojure'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

.PHONY: test-keymaps
test-keymaps:
	@TEST_SUITE=keymaps $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='keymaps'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

.PHONY: test-settings
test-settings:
	@TEST_SUITE=settings $(NVIM) --headless -u $(INIT) -c "lua vim.env.TEST_SUITE='settings'; dofile('$(RUNNER)')" 2>&1 | grep -v "deprecated"

# List available test targets
.PHONY: help
help:
	@echo "Neovim Config Test Targets:"
	@echo "  make test              - Run ALL tests"
	@echo "  make test-plugins      - Plugin loading tests (all 81 plugins)"
	@echo "  make test-lsp          - LSP configuration tests"
	@echo "  make test-treesitter   - Treesitter parser tests"
	@echo "  make test-formatter    - Formatter and linter tests"
	@echo "  make test-clojure      - Clojure-specific tests"
	@echo "  make test-keymaps      - Keymap tests"
	@echo "  make test-settings     - Core settings tests"
	@echo "  make test-suite SUITE=<name> - Run a single suite by name"
