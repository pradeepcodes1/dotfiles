#!/usr/bin/env bash
# Launch window picker popup with height sized to current window count.

set -euo pipefail

source_client_tty="${1:-}"
source_session_name="${2:-}"

if [[ -z "${source_client_tty}" || -z "${source_session_name}" ]]; then
  exit 0
fi

count="$(tmux list-windows -t "${source_session_name}" 2>/dev/null | wc -l | tr -d ' ')"
if [[ -z "${count}" || "${count}" -lt 1 ]]; then
  count=1
fi

# One line per window + fzf overhead, capped so it doesn't get huge.
height=$((count + 4))
if [[ "${height}" -lt 5 ]]; then
  height=5
fi
if [[ "${height}" -gt 18 ]]; then
  height=18
fi

tmux display-popup -B -E -w 8 -h "${height}" \
  "$(dirname "$0")/window-picker.sh" \
  "${source_client_tty}" "${source_session_name}"
