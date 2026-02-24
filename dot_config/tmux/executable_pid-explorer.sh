#!/usr/bin/env bash
# Tmux Session Process Explorer
# Opens htop filtered to processes in the current tmux session.

set -euo pipefail

session=$(tmux display-message -p '#S' 2>/dev/null) || {
  echo "Error: not inside a tmux session"
  exit 1
}

# Collect all pane root PIDs for this session
pane_pids=$(tmux list-panes -s -t "$session" -F '#{pane_pid}' 2>/dev/null)

if [[ -z "$pane_pids" ]]; then
  echo "No panes found for session: $session"
  exit 1
fi

# Recursively collect all descendant PIDs from pane roots
collect_descendants() {
  local pid="$1"
  echo "$pid"
  for child in $(pgrep -P "$pid" 2>/dev/null); do
    collect_descendants "$child"
  done
}

all_pids=""
while IFS= read -r pid; do
  all_pids+="$(collect_descendants "$pid")"$'\n'
done <<<"$pane_pids"

# Deduplicate and join as comma-separated list
pid_list=$(echo "$all_pids" | tr -s '[:space:]' '\n' | sort -un | paste -sd, -)

if [[ -z "$pid_list" ]]; then
  echo "No processes found"
  exit 1
fi

exec htop -p "$pid_list" -t
