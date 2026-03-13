#!/bin/bash
# Preview helper for flake fzf picker
# Usage: nix-flake-preview.sh <flakes_dir> <nix_system> <sel_file> <hovered>

FLAKES_DIR="$1"
NIX_SYSTEM="$2"
SEL_FILE="$3"
HOVERED="$4"

GREEN=$'\033[32m'
DIM=$'\033[2m'
BOLD=$'\033[1m'
RST=$'\033[0m'

_pkgs() {
  nix derivation show "$FLAKES_DIR/$1#packages.$NIX_SYSTEM.default" 2>/dev/null \
    | jq -r '.derivations[].env.pkgs' \
    | jq -r '.[].paths[]' \
    | sed 's|.*/||; s|^[a-z0-9]\{32\}-||; s|-man$||; s|-bin$||' \
    | sort -u
}

# Side-by-side formatter using arrays (handles ANSI codes and unequal lengths)
_side_by_side() {
  local half=$((${FZF_PREVIEW_COLUMNS:-80} / 2 - 1))

  local left_arr=() right_arr=()
  while IFS= read -r line; do left_arr+=("$line"); done <"$1"
  while IFS= read -r line; do right_arr+=("$line"); done <"$2"

  local max=${#left_arr[@]}
  ((${#right_arr[@]} > max)) && max=${#right_arr[@]}

  for ((i = 0; i < max; i++)); do
    local l="${left_arr[$i]:-}"
    local r="${right_arr[$i]:-}"
    local visible
    visible=$(printf '%s' "$l" | sed $'s/\033\\[[0-9;]*m//g')
    local pad=$((half - ${#visible}))
    ((pad < 0)) && pad=0
    printf '%s%*s  %s\n' "$l" "$pad" "" "$r"
  done
}

# Read selected items from tracking file
selected_items=()
if [ -s "$SEL_FILE" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && selected_items+=("$line")
  done <"$SEL_FILE"
fi

hovered_pkgs=$(_pkgs "$HOVERED")

if [ ${#selected_items[@]} -gt 0 ]; then
  selected_pkgs=$(for f in "${selected_items[@]}"; do _pkgs "$f"; done | sort -u)

  # Color hovered list: green = new, dim = already in selected
  colored_left=$(echo "$hovered_pkgs" | while read -r pkg; do
    if echo "$selected_pkgs" | grep -qxF "$pkg"; then
      printf '%s%s%s\n' "$DIM" "$pkg" "$RST"
    else
      printf '%s%s%s\n' "$GREEN" "$pkg" "$RST"
    fi
  done)

  left_file=$(mktemp)
  right_file=$(mktemp)
  trap "rm -f '$left_file' '$right_file'" EXIT

  {
    echo "${BOLD}── $HOVERED ──${RST}"
    echo "$colored_left"
  } >"$left_file"
  {
    echo "${BOLD}── selected ──${RST}"
    echo "$selected_pkgs"
  } >"$right_file"

  _side_by_side "$left_file" "$right_file"
else
  # No selection — all packages shown in green (all new)
  echo "${BOLD}── $HOVERED ──${RST}"
  echo "$hovered_pkgs" | while read -r pkg; do
    printf '%s%s%s\n' "$GREEN" "$pkg" "$RST"
  done
fi
