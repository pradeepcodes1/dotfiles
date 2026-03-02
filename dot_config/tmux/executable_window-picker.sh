#!/usr/bin/env bash
# Popup window picker: static vertical list, current window highlighted.
# Press a number key to switch directly, q/Esc to quit.

set -u

source_client_tty="${1:-}"
source_session_name="${2:-}"
current_window_index="${3:-}"

if command -v tput >/dev/null 2>&1; then
  tput civis >/dev/null 2>&1 || true
fi
printf '\033[?25l' || true
trap 'tput cnorm >/dev/null 2>&1 || true; printf "\033[?25h" || true' EXIT

if [[ -z "${source_client_tty}" || -z "${source_session_name}" ]]; then
  tmux display-message "window-picker: missing client/session"
  exit 0
fi

window_rows="$(tmux list-windows -t "${source_session_name}" -F '#{window_index}' 2>/dev/null)"
if [[ -z "${window_rows}" ]]; then
  printf "No windows found.\n"
  sleep 0.8
  exit 0
fi

if [[ -z "${current_window_index}" ]]; then
  current_window_index="$(
    tmux list-clients -F '#{client_tty} #{window_index}' 2>/dev/null \
      | awk -v tty="${source_client_tty}" '$1 == tty { print $2; exit }'
  )"
fi

row=0
selected_row=1
while IFS= read -r idx; do
  row=$((row + 1))
  if [[ "${idx}" == "${current_window_index}" ]]; then
    selected_row="${row}"
    printf "\033[1m> %s\033[0m\n" "${idx}"
  else
    printf "  %s\n" "${idx}"
  fi
done <<<"${window_rows}"

# Keep the input cursor on the highlighted row instead of an empty trailing line.
printf '\033[%s;1H' "${selected_row}" || true

IFS= read -rsn1 key || exit 0
if [[ "${key}" == $'\e' || "${key}" == "q" ]]; then
  exit 0
fi

if [[ "${key}" =~ ^[0-9]$ ]]; then
  target_window_index="${key}"
  tmux switch-client -c "${source_client_tty}" -t "${source_session_name}:${target_window_index}" >/dev/null 2>&1 \
    || tmux select-window -t "${source_session_name}:${target_window_index}" >/dev/null 2>&1 \
    || true
fi

exit 0
