#!/usr/bin/env bash
# Show centered window index using display-message (no popup/focus change).

set -euo pipefail

window_index="${1:-}"
client_width="${2:-80}"
delay_ms="${3:-700}"

[[ -z "${window_index}" ]] && exit 0
[[ "${client_width}" =~ ^[0-9]+$ ]] || client_width=80
[[ "${delay_ms}" =~ ^[0-9]+$ ]] || delay_ms=700

text=" ${window_index} "
text_len=${#text}
pad=$(((client_width - text_len) / 2))
if [[ "${pad}" -lt 0 ]]; then
  pad=0
fi

spaces="$(printf '%*s' "${pad}" '')"
tmux display-message -d "${delay_ms}" "#[bg=default,fg=white,bold]${spaces}${text}"
