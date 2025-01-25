SHELL := /bin/bash -i # Bourne-Again SHell is a widly used command-line interpreter on Linux.
CODENAME := $(shell echo "`lsb_release --id --short | tr '[:upper:]' '[:lower:]'`-`lsb_release --release --short`")
PATH_PYTHON_VENV := $(HOME)/.venv
PATH_PYTHON_VIRTUALENV := $(HOME)/.virtualenvs
.SHELLFLAGS := -e -c
TESTING ?= 0
### 

# Hack for displaying help message in Makefile
help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'



show-vars: ## Show variables.
show-vars:
	-@(echo "CODENAME=$(CODENAME)")
	-@(echo "PATH_PYTHON_VENV=$(PATH_PYTHON_VENV)")
	-@(echo "PATH_PYTHON_VIRTUALENV=$(PATH_PYTHON_VIRTUALENV)")
	-@(echo "SHELL=$(SHELL)")

show-workflows:  ## Check workflows for CI.
show-workflows:
	-@(cat .github/workflows/workflows.yml | yq)

### workon
setup-workon: ## Setup dotfiles project using virtualenv wrapper.
setup-workon:
	-@($(HOME)/.dotfiles/setup/linux/with_apt/virtualenvwrapper/setup.bash)
	-@(command -v workon &> /dev/null \
	&& \
		(\
		echo "Using workon for install the dotfiles." \
		&& \
			( \
			workon dotfiles &> /dev/null \
			&& echo "Virutal env dotfiles already created."\
			|| (echo "Creating dotfiles" && mkvirtualenv dotfiles) \
			) \
		&& \
			( \
			workon dotfiles \
			&& pip install -U pip \
			&& pip install -r requirements.txt \
			) \
		) \
	|| \
		(\
		echo "ERROR: please install Virtualenv Wrapper." \
		) \
	)

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

### venv-setup-dotfiles
venv-setup-dotfiles: ## Create Python virtualenv for DOTFILES.
venv-setup-dotfiles:
	-(test -d venv/dotfiles || python3 -m venv venv/dotfiles)
	-(. venv/dotfiles/bin/activate \
	&& pip install -U pip \
	&& pip install -r requirements.txt \
	)

venv-startlab-dotfiles: ## Start jupyter lab with DOTFILES.
venv-startlab-dotfiles:
	(echo "Starting lab with venv dotfiles" \
	&& . venv/dotfiles/bin/activate \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
venv-startnb-dotfiles: ## Start jupyter notebook with DOTFILES.
venv-startnb-dotfiles:
	(echo "Staring nb with venv dotfiles" \
	&& . venv/dotfiles/bin/activate \
	&& jupyter notebook --no-browser \
	)

venv-clean-dotfiles: ## Clean venv DOTFILES
venv-clean-dotfiles:
	@(rm -rf venv/dotfiles)


miniconda-setup-dotfiles: ## Install using miniconda env dotfiles.
miniconda-setup-dotfiles:
	-@(\
	conda env list \
	| egrep '^dotfiles\s+/' \
	&& conda activate dotfiles \
	|| conda create --name dotfiles python=3.10 -y \
	)
	-@(conda activate dotfiles \
	&&  conda install anaconda::pip -y \
	&& pip install -r requirements.txt \
	)

miniconda-clean-dotfiles: ## Clean miniconda env dotfiles.
miniconda-clean-dotfiles:
	-@(conda env remove --name dotfiles)	

miniconda-startlab-dotfiles: ## Start jupyter lab with DOTFILES.
miniconda-startlab-dotfiles:
	(echo "Starting lab with miniconda dotfiles" \
	&& conda activate dotfiles \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
miniconda-startnb-dotfiles: ## Start jupyter notebook with DOTFILES.
miniconda-startnb-dotfiles:
	(echo "Staring nb with miniconda dotfiles" \
	&& conda activate dotfiles \
	&& jupyter notebook --no-browser \
	)

format-req: ## Format requirements
format-req:
	-@(for i in requirements.txt;do \
	echo "Processing $$i";\
	sort $$i -o $$i;\
	uniq $$i > temp-format-req.txt && mv temp-format-req.txt $$i;\
	done)

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
clean: venv-clean-dotfiles



