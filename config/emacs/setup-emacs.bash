#!/bin/bash
sudo apt update
sudo apt install -y emacs python3 python3-pip python3-venv git curl
pip3 -U pip
pip3 install black isort flake8 pylint mypy pyright jedi
