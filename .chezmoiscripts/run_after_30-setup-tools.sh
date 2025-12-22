#!/bin/bash

#uv tool install --force  --with pip aider-chat@latest
uv tool update-shell

#brew upgrade

mise install
mise upgrade

# Yazi flavors for theme system
if command -v ya >/dev/null 2>&1; then
  echo "Installing yazi flavors..."
  ya pkg add yazi-rs/flavors:catppuccin-mocha 2>/dev/null || true
  ya pkg add yazi-rs/flavors:catppuccin-latte 2>/dev/null || true
  ya pkg add marcosvnmelo/kanagawa-dragon 2>/dev/null || true
  ya pkg add dangooddd/kanagawa 2>/dev/null || true
  ya pkg add muratoffalex/kanagawa-lotus 2>/dev/null || true
  ya pkg add bennyyip/gruvbox-dark 2>/dev/null || true
  ya pkg add Chromium-3-Oxide/everforest-medium 2>/dev/null || true
fi


