SHELL := /bin/bash -i

help: 
	@grep -E '(^[0-9a-zA-Z_-]+:.*?##.*$$)' Makefile | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'


conda-install: ## Install using conda env MyEnvToSet.
conda-install:
	-(. $${HOME}/activate/miniconda3 \
	&& (conda env list | egrep '^MyEnvToSet\s+/' && conda activate MyEnvToSet || conda create --name MyEnvToSet python=3.9 -y) \
	)

conda-clean: ## Clean conda env MyEnvToSet.
conda-clean:
	-(. $${HOME}/activate/miniconda3 \
	&& conda env remove --name MyEnvToSet \
	)	
