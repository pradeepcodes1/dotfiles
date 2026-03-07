#!/bin/zsh

# Open a file in IINA on a dedicated Aerospace workspace
# Usage: play <file> [workspace]
#   file      - path to video file
#   workspace - aerospace workspace to open in (default: V)
play() {
  if [[ -z "$1" ]]; then
    echo "Usage: play <file> [workspace]"
    return 1
  fi

  local file="$1"
  local workspace="${2:-V}"

  if [[ ! -f "$file" ]]; then
    echo "File not found: $file"
    return 1
  fi

  # Resolve to absolute path
  file="${file:A}"

  # Switch to target workspace and open IINA
  aerospace workspace "$workspace"
  iina "$file"
}
