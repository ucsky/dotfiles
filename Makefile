SHELL := /bin/bash -i # Bourne-Again SHell is a widly used command-line interpreter on Linux.
LEMPY_PYTHONPATH := ../../nbdev/
CODENAME := $(shell echo "`lsb_release --id --short | tr '[:upper:]' '[:lower:]'`-`lsb_release --release --short`")
### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

### venv-setup-main
venv-setup-main: ## Create Python virtualenv for MAIN.
venv-setup-main:
	-(test -d venv/main || python3 -m venv venv/main)
	-(. venv/main/bin/activate \
	&& pip install -U pip \
	&& pip install -r requirements/main.txt \
	)

venv-start-lab-main: ## Start jupyter lab with MAIN.
venv-start-lab-main:
	(export PYTHONPATH="$${PYTHONPATH}:$(LEMPY_PYTHONPATH)" \
	&& . venv/main/bin/activate \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
venv-start-nb-main: ## Start jupyter notebook with MAIN.
venv-start-nb-main:
	(export PYTHONPATH="${PYTHONPATH}:$(LEMPY_PYTHONPATH)" \
	&& . venv/main/bin/activate \
	&& jupyter notebook --no-browser \
	)

venv-clean-main: ## Clean venv MAIN.
venv-clean-main:
	@(rm -rf venv/main)

### Cleaning
nbs-clear-output: ## Clear all notebooks.
nbs-clear-output:
	@for i in notebooks/*.ipynb;do \
	jupyter nbconvert --ClearOutputPreprocessor.enabled=True --clear-output --inplace $$i; \
	done

.PHONY: setup
setup:  ## Setup dotfiles
setup: setup/linux/$(CODENAME)/setup.bash
	(./$<)

clean: ## Cleaning part of this directory.
clean:



