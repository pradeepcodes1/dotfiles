#!/bin/sh
set -e

# Check if nix is already installed
if command -v nix >/dev/null 2>&1; then
  echo "Nix is already installed"
  exit 0
fi

echo "Installing Nix..."

OS="$(uname -s)"

case "$OS" in
  Darwin)
    echo "macOS detected → installing Nix"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
      | sh -s -- install --no-confirm
    ;;
  Linux)
    # Detect systemd (Docker / CI do NOT have it)
    if [ -d /run/systemd/system ]; then
      echo "Linux with systemd detected → installing Nix with daemon"
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
    else
      echo "Linux without systemd detected → installing Nix without daemon"
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install linux --init none --no-confirm
    fi
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "Nix installed successfully"
echo "Please restart your shell or run: . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
