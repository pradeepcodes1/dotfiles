#!/bin/sh
# Sets up pre-commit hooks for development
# Usage: ./scripts/setup-hooks.sh
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

cd "$REPO_DIR"

# Check if pre-commit is available
if ! command -v pre-commit >/dev/null 2>&1; then
  echo "pre-commit not found. Install options:"
  echo "  1. nix shell ./nix/config_dev"
  echo "  2. pip install pre-commit"
  echo "  3. brew install pre-commit"
  exit 1
fi

echo "Installing pre-commit hooks..."
pre-commit install

echo "Running hooks on all files to verify setup..."
pre-commit run --all-files || true

echo ""
echo "✅ Pre-commit hooks installed!"
echo "   Hooks will run automatically on git commit."
echo "   Run manually: pre-commit run --all-files"
