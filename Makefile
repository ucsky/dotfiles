SHELL := /bin/bash # Bourne-Again SHell is a widly used command-line interpreter on Linux.
CODENAME := $(shell echo "`lsb_release --id --short | tr '[:upper:]' '[:lower:]'`-`lsb_release --release --short`")
PATH_PYTHON_VENV := $(HOME)/.venv
PATH_PYTHON_VIRTUALENV := $(HOME)/.virtualenvs
NAME_PYTHON_VENV := dotfiles51
.SHELLFLAGS := -e -c
OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')

ifeq ($(OS),linux)
SETUP_SCRIPT := make/install_bare-linux.bash
endif
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
	-@(echo "PATH_PYTHON_VIRTUALENV=$(PATH_PYTHON_VIRTUALENV)")
	-@(echo "SHELL=$(SHELL)")

show-workflows:  ## Check workflows for CI.
show-workflows:
	-@(cat .github/workflows/workflows.yml | yq)

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
# Setup
#---------------------------------------------

setup-venv: ## Create Python virtualenv for DOTFILES.
setup-venv:
	-(test -d $(PATH_PYTHON_VENV) || python3 -m venv $(PATH_PYTHON_VENV))
	-(. $(PATH_PYTHON_VENV)/bin/activate \
	&& pip install -U pip \
	&& pip install -r requirements.txt \
	)


setup-workon: ## Setup dotfiles project using virtualenv wrapper.
setup-workon:
	-@(if command -v workon &> /dev/null; then \
		export WORKON_HOME=$$HOME/.virtualenvs \
		&& export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3 \
		&& (source /usr/share/virtualenvwrapper/virtualenvwrapper.sh 2>/dev/null \
			|| source /usr/local/bin/virtualenvwrapper.sh 2>/dev/null \
			|| source $$HOME/.local/bin/virtualenvwrapper.sh 2>/dev/null) \
		&& echo "Using workon to install dotfiles." \
		&& (workon $(NAME_PYTHON_VENV) &> /dev/null \
			&& echo "Virtual env $(NAME_PYTHON_VENV) already created." \
			|| (echo "Creating $(NAME_PYTHON_VENV)" && mkvirtualenv $(NAME_PYTHON_VENV))) \
		&& workon $(NAME_PYTHON_VENV) \
		&& pip install -U pip \
		&& pip install -r requirements.txt; \
	else \
		echo "Note: Virtualenvwrapper not available. Run 'make install' with admin privileges to install it, or use 'make setup-venv'."; \
	fi)



setup-miniconda: ## Install using miniconda env dotfiles.
setup-miniconda:
	-@(command -v conda >> /dev/null && (\
	CONDA_BASE=$$(conda info --base) \
	&& source $$CONDA_BASE/etc/profile.d/conda.sh \
	&& conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true \
	&& conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true \
	&& (conda env list | egrep '^$(NAME_PYTHON_VENV)\s+/' > /dev/null \
		|| conda create --name $(NAME_PYTHON_VENV) python=3.10 -y) \
	&& conda activate $(NAME_PYTHON_VENV) \
	&& conda install anaconda::pip -y \
	&& pip install -r requirements.txt \
	) || true)

.PHONY: setup
setup:  ## Setup dotfiles
setup: $(SETUP_SCRIPT) setup-venv setup-workon setup-miniconda
	(./$<)

.PHONY: install uninstall
install: ## Install dotfiles (OS-aware)
	@bash make/install.bash

uninstall: ## Uninstall dotfiles integration (safe)
	@bash make/uninstall.bash

#---------------------------------------------
# Start Jupyter Notebook and Lab
#---------------------------------------------
## Jupyter notebook and lab
startlab-venv: ## Start jupyter lab with DOTFILES.
startlab-venv:
	(echo "Starting lab with venv dotfiles" \
	&& . $(PATH_PYTHON_VENV)/bin/activate \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
startnb-venv: ## Start jupyter notebook with DOTFILES.
startnb-venv:
	(echo "Staring nb with venv dotfiles" \
	&& . $(PATH_PYTHON_VENV)/bin/activate \
	&& jupyter notebook --no-browser \
	)

startlab-miniconda: ## Start jupyter lab with DOTFILES.
startlab-miniconda:
	(echo "Starting lab with miniconda dotfiles" \
	&& conda activate $(NAME_PYTHON_VENV) \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
startnb-miniconda: ## Start jupyter notebook with DOTFILES.
startnb-miniconda:
	(echo "Staring nb with miniconda dotfiles" \
	&& conda activate $(NAME_PYTHON_VENV) \
	&& jupyter notebook --no-browser \
	)

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
			rmvirtualenv dotfiles \
			) \
		) \
	|| \
		(\
		echo "ERROR: please install Virtualenv Wrapper." \
		) \
	)


clean-venv: ## Clean venv DOTFILES
clean-venv:
	@(rm -rf $(PATH_PYTHON_VENV))

clean-miniconda: ## Clean miniconda env dotfiles.
clean-miniconda:
	-@(conda env remove --name $(NAME_PYTHON_VENV))	

clean: ## Cleaning this directory
clean: clean-venv clean-miniconda



