#!/bin/bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

uv tool install --force --python python3.12 --with pip aider-chat@latest
uv tool update-shell

brew upgrade

# Yazi theming

if command -v ya >/dev/null 2>&1; then
  if ! ya pkg add gosxrgxx/flexoki-dark; then
    echo "yazi flavors already installed, skipping"
  fi
fi


# Backups
restic_backup $BACKUPS_YAMTRACK $BACKUPS_OBSIDIAN 

