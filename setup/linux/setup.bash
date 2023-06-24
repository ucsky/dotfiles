#!/bin/bash -e
cd $HOME && cat ~/.gitignore | grep '/.dotfiles' || echo '/.dotfiles' >> .gitignore
