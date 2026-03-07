#!/usr/bin/env bash
# Copy a numbered command block from scrollback to clipboard
# Parses the zsh-prompt format: number + path, > command, output, timer

set -euo pipefail

LOGFILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/logs/dotfiles.jsonl"
_log() {
  local level="$1" msg="$2"
  printf '{"ts":"%s","level":"%s","component":"copy-block","msg":"%s","source":"shell","pid":%d}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" "$level" "$msg" $$ >>"$LOGFILE" 2>/dev/null
}

target_pane="${1:?Pane ID required}"
_log "DEBUG" "Started with pane=$target_pane"

# Capture full scrollback as plain text (no ANSI), join wrapped lines
tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT
if ! tmux capture-pane -t "$target_pane" -p -J -S - -E - >"$tmpfile" 2>/dev/null; then
  _log "ERROR" "capture-pane failed for $target_pane"
  exit 1
fi

line_count=$(wc -l <"$tmpfile")
_log "DEBUG" "Captured $line_count lines"

# Extract "N | command" entries for fzf using state machine
# Match: line starting with "N ~/path" immediately followed by "> command"
entries=$(awk '
  /^[0-9]+ [~\/]/ { num = $1; pending = 1; next }
  pending && /^> / {
    printf "%s | %s\n", num, substr($0, 3)
    pending = 0
    next
  }
  { pending = 0 }
' "$tmpfile")

if [[ -z "$entries" ]]; then
  _log "DEBUG" "No entries found"
  exit 0
fi

entry_count=$(printf '%s\n' "$entries" | wc -l)
_log "DEBUG" "Found $entry_count entries"

# Let user pick a command (most recent first; --tac replaces external tac)
selected=$(printf '%s\n' "$entries" | fzf --tac --no-sort \
  --prompt="Copy command block: " \
  --header="Select a command to copy (command + output)" \
  --preview="awk -v num={1} '
    BEGIN { found=0 }
    /^[0-9]+ [~\/]/ {
      if (\$1 == num) { found=1; next }
      else if (found) { exit }
    }
    found && /^⏱ / { exit }
    found && /^> / { print \"# \" substr(\$0, 3); next }
    found && !/^$/ { print }
  ' \"$tmpfile\" | head -50" \
  --preview-window=right:60%:wrap \
  --delimiter=' ' \
  2>/dev/null) || {
  _log "DEBUG" "fzf cancelled"
  exit 0
}

# Extract the command number
cmd_num="${selected%% *}"
_log "DEBUG" "Selected command #$cmd_num"

# Extract the full block: command (without "> ") + output (without timer)
block=$(awk -v num="$cmd_num" '
  BEGIN { found=0 }
  /^[0-9]+ [~\/]/ {
    if ($1 == num) { found=1; next }
    else if (found) { exit }
  }
  found && /^⏱ / { exit }
  found && /^> / { print "# " substr($0, 3); next }
  found && /^$/ { next }
  found { print }
' "$tmpfile")

# Copy to clipboard
printf '%s' "$block" | pbcopy
_log "INFO" "Copied command #$cmd_num to clipboard"
