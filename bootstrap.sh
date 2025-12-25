#!/bin/sh
# Prepares the environment and runs chezmoi apply in a nix shell
# Usage: ./bootstrap.sh [chezmoi args...]
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Install nix if not present ---
if ! command -v nix >/dev/null 2>&1; then
  echo "📦 Installing nix..."

  OS="$(uname -s)"
  case "$OS" in
    Darwin)
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
      ;;
    Linux)
      if [ -d /run/systemd/system ]; then
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
          | sh -s -- install --no-confirm
      else
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
          | sh -s -- install linux --init none --no-confirm
      fi
      ;;
    *)
      echo "Unsupported OS: $OS"
      exit 1
      ;;
  esac
fi

# --- Source nix ---
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
elif [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

# --- Run chezmoi apply in nix shell ---
echo "🚀 Running chezmoi apply in nix shell..."

# Construct a clean PATH including system dirs and nix, but excluding user profile
# This ensures isolation from the user's potentially conflicting nix profile
NIX_BIN="$(command -v nix)"
NIX_DIR="$(dirname "$NIX_BIN")"
CLEAN_PATH="/usr/bin:/bin:/usr/sbin:/sbin:$NIX_DIR"
export PATH="$CLEAN_PATH"
export CHEZMOI_BOOTSTRAP_MODE=1

exec nix shell --ignore-env \
  --keep-env-var PATH \
  --keep-env-var CHEZMOI_BOOTSTRAP_MODE \
  --keep-env-var HOME \
  --keep-env-var USER \
  --keep-env-var SHELL \
  --keep-env-var TERM \
  --keep-env-var SSH_AUTH_SOCK \
  --keep-env-var NIX_SSL_CERT_FILE \
  --keep-env-var LANG \
  --keep-env-var LC_ALL \
  --keep-env-var CI \
  "${SCRIPT_DIR}/nix/bootstrap" --command chezmoi apply --source="${SCRIPT_DIR}" "$@"
