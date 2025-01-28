SHELL := /bin/bash -i # Bourne-Again SHell is a widly used command-line interpreter on Linux.
CODENAME := $(shell echo "`lsb_release --id --short | tr '[:upper:]' '[:lower:]'`-`lsb_release --release --short`")
PATH_PYTHON_VENV := $(HOME)/.venv
PATH_PYTHON_VIRTUALENV := $(HOME)/.virtualenvs
NAME_PYTHON_VENV := dotfiles
.SHELLFLAGS := -e -c
OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')

ifeq ($(OS),linux)
	SETUP_SCRIPT := setup/$(OS)/setup.bash
endif

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
	-(test -d $(PATH_PYTHON_VENV)/$(NAME_PYTHON_ENV) || python3 -m venv $(PATH_PYTHON_VENV)/$(NAME_PYTHON_ENV))
	-(. $(PATH_PYTHON_VENV)/$(NAME_PYTHON_ENV)/bin/activate \
	&& pip install -U pip \
	&& pip install -r requirements.txt \
	)


setup-workon: ## Setup dotfiles project using virtualenv wrapper.
setup-workon:
	-@($(HOME)/.dotfiles/setup/linux/with_apt/virtualenvwrapper/setup.bash)
	-@(command -v workon &> /dev/null \
	&& \
		(\
		echo "Using workon for install the dotfiles." \
		&& \
			( \
			workon $(NAME_PYTHON_VENV) &> /dev/null \
			&& echo "Virutal env $(NAME_PYTHON_VENV) already created."\
			|| (echo "Creating $(NAME_PYTHON_VENV)" && mkvirtualenv $(NAME_PYTHON_VENV)) \
			) \
		&& \
			( \
			workon $(NAME_PYTHON_VENV) \
			&& pip install -U pip \
			&& pip install -r requirements.txt \
			) \
		) \
	|| \
		(\
		echo "ERROR: please install Virtualenv Wrapper." \
		) \
	)



setup-miniconda: ## Install using miniconda env dotfiles.
setup-miniconda:
	-@(\
	conda env list \
	| egrep '^$(NAME_PYTHON_VENV)\s+/' \
	&& conda activate $(NAME_PYTHON_VENV) \
	|| conda create --name $(NAME_PYTHON_VENV) python=3.10 -y \
	)
	-@(conda activate $(NAME_PYTHON_VENV) \
	&&  conda install anaconda::pip -y \
	&& pip install -r requirements.txt \
	)

.PHONY: setup
setup:  ## Setup dotfiles
setup: $(SETUP_SCRIPT) setup-venv setup-workon setup-miniconda
	(./$<)

#---------------------------------------------
# Start Jupyter Notebook and Lab
#---------------------------------------------
## Jupyter notebook and lab
startlab-venv: ## Start jupyter lab with DOTFILES.
startlab-venv:
	(echo "Starting lab with venv dotfiles" \
	&& . $(PATH_PYTHON_VENV)/$(NAME_PYTHON_ENV)/bin/activate \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
startnb-venv: ## Start jupyter notebook with DOTFILES.
startnb-venv:
	(echo "Staring nb with venv dotfiles" \
	&& . $(PATH_PYTHON_VENV)/$(NAME_PYTHON_ENV)/bin/activate \
	&& jupyter notebook --no-browser \
	)

startlab-miniconda: ## Start jupyter lab with DOTFILES.
startlab-miniconda:
	(echo "Starting lab with miniconda dotfiles" \
	&& conda activate dotfiles \
	&& jupyter lab --no-browser \
	)

# Because sometime Jupyter lab freeze when performing visualization.
startnb-miniconda: ## Start jupyter notebook with DOTFILES.
startnb-miniconda:
	(echo "Staring nb with miniconda dotfiles" \
	&& conda activate dotfiles \
	&& jupyter notebook --no-browser \
	)

#---------------------------------------------
# Testing
#---------------------------------------------
tests-emacs: ## Test emacs setup
tests-emacs:
	-@(echo "Testing emacs" \
	&& bash tests/tests-emacs.bash \
	)
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
	@(rm -rf $(PATH_PYTHON_VENV)/$(NAME_PYTHON_ENV))

clean-miniconda: ## Clean miniconda env dotfiles.
clean-miniconda:
	-@(conda env remove --name $(NAME_PYTHON_ENV))	

clean: ## Cleaning this directory
clean: clean-venv clean-miniconda



