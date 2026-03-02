#!/usr/bin/env bash

set -euo pipefail

client_tty="${1:-}"
window_index="${2:-?}"

tmux kill-pane >/dev/null 2>&1 || exit 0

message="closed window \"${window_index}\""
client_width=80
if [[ -n "${client_tty}" ]]; then
  client_width="$(tmux display-message -p -t "${client_tty}" '#{client_width}' 2>/dev/null || echo 80)"
fi
[[ "${client_width}" =~ ^[0-9]+$ ]] || client_width=80

pad=$(((client_width - ${#message}) / 2))
if [[ "${pad}" -lt 0 ]]; then
  pad=0
fi
spaces="$(printf '%*s' "${pad}" '')"

if [[ -n "${client_tty}" ]]; then
  tmux display-message -t "${client_tty}" -d 900 "#[fg=white,bold]${spaces}${message}" >/dev/null 2>&1 || true
else
  tmux display-message -d 900 "#[fg=white,bold]${spaces}${message}" >/dev/null 2>&1 || true
fi
