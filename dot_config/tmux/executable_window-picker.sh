#!/usr/bin/env bash
# Simple popup window picker (numbers only, no search typing).

set -u

source_client_tty="${1:-}"
source_session_name="${2:-}"

if [[ -z "${source_client_tty}" || -z "${source_session_name}" ]]; then
  tmux display-message "window-picker: missing client/session"
  exit 0
fi

if ! command -v fzf >/dev/null 2>&1; then
  tmux choose-window
  exit 0
fi

window_rows="$(tmux list-windows -t "${source_session_name}" -F '#{window_index}#{?window_active, * ,}' 2>/dev/null)"
if [[ -z "${window_rows}" ]]; then
  printf "No windows found.\n"
  sleep 0.8
  exit 0
fi

active_pos="$(
  tmux list-windows -t "${source_session_name}" -F '#{window_active}' 2>/dev/null \
    | awk '$1 == 1 { print NR; exit }'
)"
[[ -z "${active_pos}" ]] && active_pos=1

selection="$(
  printf '%s\n' "${window_rows}" | fzf \
    --layout=reverse \
    --height=100% \
    --no-input \
    --no-info \
    --disabled \
    --no-multi \
    --bind "start:pos(${active_pos})" \
    2>/dev/null || true
)"

target_window_index="$(printf '%s' "${selection}" | awk '{print $1}' | tr -cd '0-9')"
if [[ -n "${target_window_index}" ]] && [[ "${target_window_index}" =~ ^[0-9]+$ ]]; then
  tmux switch-client -c "${source_client_tty}" -t "${source_session_name}:${target_window_index}" >/dev/null 2>&1 \
    || tmux select-window -t "${source_session_name}:${target_window_index}" >/dev/null 2>&1 \
    || true
fi

exit 0
