SHELL := /bin/bash # Bourne-Again SHell is a widely used command-line interpreter on Linux.
CODENAME := $(shell echo "`lsb_release --id --short | tr '[:upper:]' '[:lower:]'`-`lsb_release --release --short`")
PATH_PYTHON_VENV_ROOT := $(HOME)/.venv
PATH_PYTHON_VIRTUALENV := $(HOME)/.virtualenvs
NAME_PYTHON_VENV := dotfiles51
PATH_PYTHON_VENV := $(PATH_PYTHON_VENV_ROOT)/$(NAME_PYTHON_VENV)
.SHELLFLAGS := -e -c
OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')

PYTHONPATH := $(PWD)/scripts/python3
export
#---------------------------------------------
# Hack for displaying help message in Makefile
#---------------------------------------------
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'


#---------------------------------------------
# Show
#---------------------------------------------
show-vars: ## Show variables.
show-vars:
	-@(echo "CODENAME=$(CODENAME)")
	-@(echo "PATH_PYTHON_VENV=$(PATH_PYTHON_VENV)")
	-@(echo "PATH_PYTHON_VENV_ROOT=$(PATH_PYTHON_VENV_ROOT)")
	-@(echo "PATH_PYTHON_VIRTUALENV=$(PATH_PYTHON_VIRTUALENV)")
	-@(echo "SHELL=$(SHELL)")

show-workflows:  ## Show GitHub workflows (requires yq).
show-workflows:
	-@(yq . .github/workflows/workflows.yml)

#---------------------------------------------
# Format
#---------------------------------------------
format-req: ## Format requirements
format-req:
	-@(for i in requirements.txt;do \
	echo "Processing $$i";\
	sort $$i -o $$i;\
	uniq $$i > temp-format-req.txt && mv temp-format-req.txt $$i;\
	done)

#---------------------------------------------
# Setup is handled by 'make install' (idempotent).
.PHONY: setup
setup: ## Deprecated: use install
	@$(MAKE) install

.PHONY: install uninstall
install: ## Install dotfiles (OS-aware)
	@bash make/install.bash

uninstall: ## Uninstall dotfiles integration (safe)
	@bash make/uninstall.bash

#---------------------------------------------
# Start Jupyter Notebook and Lab
#---------------------------------------------
## Jupyter notebook and lab
startlab: ## Start JupyterLab (DOTFILES_PY_ENV=venv|workon|conda)
startlab:
	@(ENV_TYPE=$${DOTFILES_PY_ENV:-venv}; \
	echo "Starting JupyterLab (DOTFILES_PY_ENV=$$ENV_TYPE)"; \
	case "$$ENV_TYPE" in \
		venv) \
			test -d "$(PATH_PYTHON_VENV)" || (echo "ERROR: venv not found at $(PATH_PYTHON_VENV). Run: make install" 1>&2; exit 1); \
			. "$(PATH_PYTHON_VENV)/bin/activate"; \
			;; \
		workon) \
			command -v workon >/dev/null 2>&1 || (echo "ERROR: workon not available. Run: make install (with admin) to set it up." 1>&2; exit 1); \
			export WORKON_HOME="$(PATH_PYTHON_VIRTUALENV)"; \
			(source /usr/share/virtualenvwrapper/virtualenvwrapper.sh 2>/dev/null \
				|| source /usr/local/bin/virtualenvwrapper.sh 2>/dev/null \
				|| source $$HOME/.local/bin/virtualenvwrapper.sh 2>/dev/null); \
			workon $(NAME_PYTHON_VENV); \
			;; \
		conda) \
			if command -v conda >/dev/null 2>&1; then \
				CONDA_BASE=$$(conda info --base); \
				source "$$CONDA_BASE/etc/profile.d/conda.sh" 2>/dev/null || true; \
			elif [ -f "$$HOME/.miniconda3/etc/profile.d/conda.sh" ]; then \
				source "$$HOME/.miniconda3/etc/profile.d/conda.sh" 2>/dev/null || true; \
			else \
				echo "ERROR: conda not available. Run: make install (after installing miniconda)." 1>&2; \
				exit 1; \
			fi; \
			conda activate $(NAME_PYTHON_VENV) || (echo "ERROR: conda env $(NAME_PYTHON_VENV) not found. Run: make install" 1>&2; exit 1); \
			;; \
		*) \
			echo "ERROR: invalid DOTFILES_PY_ENV=$$ENV_TYPE (use venv|workon|conda)" 1>&2; \
			exit 1; \
			;; \
	esac; \
	jupyter lab --no-browser; \
	)

# Note: startnb targets were removed; use JupyterLab via startlab.

#---------------------------------------------
# Testing
#---------------------------------------------

# Create logs directory
LOGS_DIR := logs

test-config-emacs: ## Test emacs setup
test-config-emacs: tests/configs/emacs/test_emacs.bash
	@mkdir -p $(LOGS_DIR)
	@TIMESTAMP=$$(date +%Y%m%dT%H%M%S); \
	LOG_FILE="$(LOGS_DIR)/test-config-emacs_$$TIMESTAMP.log"; \
	echo "Testing emacs configuration (log: $$LOG_FILE)"; \
	(echo "Testing emacs configuration" && ./$<) 2>&1 | tee $$LOG_FILE

test-configs: ## Test all config files
test-configs:
	@mkdir -p $(LOGS_DIR)
	@TIMESTAMP=$$(date +%Y%m%dT%H%M%S); \
	LOG_FILE="$(LOGS_DIR)/test-configs_$$TIMESTAMP.log"; \
	echo "Testing configs (log: $$LOG_FILE)"; \
	(echo "Testing configs"; \
	if [ -d $(PATH_PYTHON_VENV) ]; then . $(PATH_PYTHON_VENV)/bin/activate; fi; \
	for i in tests/configs/*/*.*; do \
		echo "Testing $$i"; \
		./$$i; \
	done) 2>&1 | tee $$LOG_FILE

test-script-bash: ## Test bash scripts
test-script-bash:
	@mkdir -p $(LOGS_DIR)
	@TIMESTAMP=$$(date +%Y%m%dT%H%M%S); \
	LOG_FILE="$(LOGS_DIR)/test-script-bash_$$TIMESTAMP.log"; \
	echo "Testing bash script (log: $$LOG_FILE)"; \
	(echo "Testing bash script"; \
	if [ -d $(PATH_PYTHON_VENV) ]; then . $(PATH_PYTHON_VENV)/bin/activate; fi; \
	for i in tests/scripts/bash/*.*;do \
		echo "Testing $$i";\
		./$$i; \
	done) 2>&1 | tee $$LOG_FILE

test-script-python3: ## Test python3 scripts
test-script-python3:
	@mkdir -p $(LOGS_DIR)
	@TIMESTAMP=$$(date +%Y%m%dT%H%M%S); \
	LOG_FILE="$(LOGS_DIR)/test-script-python3_$$TIMESTAMP.log"; \
	echo "Testing python3 script (log: $$LOG_FILE)"; \
	(echo "Testing python3 script"; \
	if [ -d $(PATH_PYTHON_VENV) ]; then \
		. $(PATH_PYTHON_VENV)/bin/activate \
		&& for i in tests/scripts/python3/*.*;do \
			echo "Testing $$i";\
			./$$i; \
		done; \
	elif command -v workon &> /dev/null; then \
		export WORKON_HOME=$$HOME/.virtualenvs \
		&& export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 \
		&& (source /usr/share/virtualenvwrapper/virtualenvwrapper.sh 2>/dev/null \
			|| source /usr/local/bin/virtualenvwrapper.sh 2>/dev/null \
			|| source $$HOME/.local/bin/virtualenvwrapper.sh 2>/dev/null) \
		&& workon $(NAME_PYTHON_VENV) 2>/dev/null \
		&& for i in tests/scripts/python3/*.*;do \
			echo "Testing $$i";\
			./$$i; \
		done; \
	elif command -v conda &> /dev/null; then \
		CONDA_BASE=$$(conda info --base 2>/dev/null) \
		&& source $$CONDA_BASE/etc/profile.d/conda.sh 2>/dev/null \
		&& conda activate $(NAME_PYTHON_VENV) 2>/dev/null \
		&& for i in tests/scripts/python3/*.*;do \
			echo "Testing $$i";\
			./$$i; \
		done; \
	else \
		echo "Warning: No Python virtual environment found. Trying system Python."; \
		for i in tests/scripts/python3/*.*;do \
			echo "Testing $$i";\
			./$$i; \
		done; \
	fi) 2>&1 | tee $$LOG_FILE

test-hooks: ## Test git hooks
test-hooks:
	@mkdir -p $(LOGS_DIR)
	@TIMESTAMP=$$(date +%Y%m%dT%H%M%S); \
	LOG_FILE="$(LOGS_DIR)/test-hooks_$$TIMESTAMP.log"; \
	echo "Testing hooks (log: $$LOG_FILE)"; \
	(echo "Testing hooks"; \
	if [ -d $(PATH_PYTHON_VENV) ]; then . $(PATH_PYTHON_VENV)/bin/activate; fi; \
	for i in tests/hooks/*.*; do \
		echo "Testing $$i"; \
		./$$i; \
	done) 2>&1 | tee $$LOG_FILE

test-notebooks: ## Test notebooks
test-notebooks:
	@mkdir -p $(LOGS_DIR)
	@TIMESTAMP=$$(date +%Y%m%dT%H%M%S); \
	LOG_FILE="$(LOGS_DIR)/test-notebooks_$$TIMESTAMP.log"; \
	echo "Testing notebooks (log: $$LOG_FILE)"; \
	(echo "Testing notebooks"; \
	if [ -d $(PATH_PYTHON_VENV) ]; then . $(PATH_PYTHON_VENV)/bin/activate; fi; \
	for i in tests/notebooks/*.*; do \
		echo "Testing $$i"; \
		./$$i; \
	done) 2>&1 | tee $$LOG_FILE

test-infra: ## Test infra helpers
test-infra:
	@mkdir -p $(LOGS_DIR)
	@TIMESTAMP=$$(date +%Y%m%dT%H%M%S); \
	LOG_FILE="$(LOGS_DIR)/test-infra_$$TIMESTAMP.log"; \
	echo "Testing infra (log: $$LOG_FILE)"; \
	(echo "Testing infra"; \
	if [ -d $(PATH_PYTHON_VENV) ]; then . $(PATH_PYTHON_VENV)/bin/activate; fi; \
	for i in tests/infra/*.*; do \
		echo "Testing $$i"; \
		./$$i; \
	done) 2>&1 | tee $$LOG_FILE

.PHONY: tests
tests: ## Run all tests
tests: test-configs test-script-bash test-script-python3 test-hooks test-notebooks test-infra
	@echo ""
	@echo "All tests completed. Logs available in $(LOGS_DIR)/"

#---------------------------------------------
# Scripts (each script has a Makefile rule)
#---------------------------------------------

SCRIPTS_BASH := $(wildcard scripts/bash/*)
SCRIPTS_PY   := $(wildcard scripts/python3/*)
SCRIPTS_SH   := $(wildcard scripts/sh/*)

.PHONY: scripts-list
scripts-list: ## List available scripts
	@echo "Bash scripts:" && printf "  %s\n" $(SCRIPTS_BASH)
	@echo "Python scripts:" && printf "  %s\n" $(SCRIPTS_PY)
	@echo "SH scripts:" && printf "  %s\n" $(SCRIPTS_SH)

.PHONY: $(SCRIPTS_BASH) $(SCRIPTS_PY) $(SCRIPTS_SH)
$(SCRIPTS_BASH):
	@bash "$@"
$(SCRIPTS_PY):
	@python3 "$@"
$(SCRIPTS_SH):
	@sh "$@"

#---------------------------------------------
# Cleaning
#---------------------------------------------
clean-nb-output: ## Clear all notebooks
clean-nb-output:
	@for i in notebooks/*.ipynb;do \
	jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output --inplace $$i; \
	done

clean-workon: ## Clean dotfiles project using virtualenv wrapper.
clean-workon:
	-@(command -v workon &> /dev/null \
	&& \
		(\
		echo "Cleaning virtual env wrapper project dotfiles." \
		&& \
			( \
			rmvirtualenv $(NAME_PYTHON_VENV) \
			) \
		) \
	|| \
		(\
		echo "ERROR: please install Virtualenv Wrapper." \
		) \
	)




