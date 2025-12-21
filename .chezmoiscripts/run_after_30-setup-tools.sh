#!/bin/bash

#uv tool install --force  --with pip aider-chat@latest
uv tool update-shell

#brew upgrade

mise install
mise upgrade

# Yazi theming

if command -v ya >/dev/null 2>&1; then
  if ! ya pkg add gosxrgxx/flexoki-dark; then
    echo "yazi flavors already installed, skipping"
  fi
fi


