SHELL := /bin/bash -i # Bourne-Again SHell is a widly used command-line interpreter on Linux.

CODENAME := $(shell echo "`lsb_release --id --short | tr '[:upper:]' '[:lower:]'`-`lsb_release --release --short`")

### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'


show-codename: ## Show distribution codename.
show-codename:
	-@(echo "$(CODENAME)")

show-workflows:  ## Check workflows for CI.
show-workflows:
	-@(cat .github/workflows/workflows.yml | yq)

### venv-setup-main
venv-setup-main: ## Create Python virtualenv for MAIN.
venv-setup-main:
	-(test -d venv/main || python3 -m venv venv/main)
	-(. venv/main/bin/activate \
	&& pip install -U pip \
	&& pip install -r requirements/main.txt \
	)

venv-startlab-main: ## Start jupyter lab with MAIN.
venv-startlab-main:
	(echo "Starting lab with venv main" \
	&& . venv/main/bin/activate \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
venv-startnb-main: ## Start jupyter notebook with MAIN.
venv-startnb-main:
	(echo "Staring nb with venv main" \
	&& . venv/main/bin/activate \
	&& jupyter notebook --no-browser \
	)

venv-clean-main: ## Clean venv MAIN
venv-clean-main:
	@(rm -rf venv/main)


conda-setup-main: ## Install using conda env main.
conda-setup-main:
	-@(\
	conda env list \
	| egrep '^main\s+/' \
	&& conda activate main \
	|| conda create --name main python=3.10 -y \
	)
	-@(conda activate main \
	&&  conda install anaconda::pip -y \
	&& pip install -r requirements/main.txt \
	)

conda-clean-main: ## Clean conda env main.
conda-clean-main:
	-@(conda env remove --name main)	

conda-startlab-main: ## Start jupyter lab with MAIN.
conda-startlab-main:
	(echo "Starting lab with conda main" \
	&& conda activate main \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
conda-startnb-main: ## Start jupyter notebook with MAIN.
conda-startnb-main:
	(echo "Staring nb with conda main" \
	&& conda activate main \
	&& jupyter notebook --no-browser \
	)

### Cleaning
nbs-clear-output: ## Clear all notebooks
nbs-clear-output:
	@for i in notebooks/*.ipynb;do \
	jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output --inplace $$i; \
	done

.PHONY: setup
setup:  ## Setup dotfiles
setup: setup/linux/setup.bash
	(./$<)

clean: ## Cleaning this directory
clean: venv-clean-main



