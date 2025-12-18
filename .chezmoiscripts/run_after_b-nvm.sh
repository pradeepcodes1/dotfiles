#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

uv tool install --force --python python3.12 --with pip aider-chat@latest
uv tool update-shell

brew upgrade

# Yazi theming
ya pkg add gosxrgxx/flexoki-dark
