#!/bin/sh
set -e

# Check if nix is already installed
if command -v nix >/dev/null 2>&1; then
  echo "Nix is already installed"
  exit 0
fi

echo "Installing Nix..."

# Use Determinate Systems installer (recommended for macOS)
# It handles daemon setup, creates /nix, and enables flakes by default
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm

echo "Nix installed successfully"
echo "Please restart your shell or run: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
