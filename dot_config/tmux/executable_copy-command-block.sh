#!/usr/bin/env bash
# Copy a numbered command block from scrollback to clipboard
# Parses the zsh-prompt format: number + path, > command, output, timer
#
# Usage:
#   copy-command-block.sh <pane_id>          - Check for entries, open popup if any
#   copy-command-block.sh --pick <tmpfile> <entries_file>  - Run fzf picker (called inside popup)

set -euo pipefail

LOGFILE="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/logs/dotfiles.jsonl"
_log() {
  local level="$1" msg="$2"
  printf '{"ts":"%s","level":"%s","component":"copy-block","msg":"%s","source":"shell","pid":%d}\n' \
    "$(date -u +%Y-%m-%dT%H:%M:%S.000Z)" "$level" "$msg" $$ >>"$LOGFILE" 2>/dev/null
}

# --- Picker mode: run inside popup ---
if [[ "${1:-}" == "--pick" ]]; then
  tmpfile="$2"
  entries_file="$3"
  # Clean up temp files on exit
  trap 'rm -f "$tmpfile" "$entries_file"' EXIT

  selected=$(fzf --tac --no-sort \
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
    <"$entries_file" 2>/dev/null) || {
    _log "DEBUG" "fzf cancelled"
    exit 0
  }

  cmd_num="${selected%% *}"
  _log "DEBUG" "Selected command #$cmd_num"

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

  printf '%s' "$block" | pbcopy
  _log "INFO" "Copied command #$cmd_num to clipboard"
  exit 0
fi

# --- Main mode: check for entries, open popup if found ---
target_pane="${1:?Pane ID required}"
_log "DEBUG" "Started with pane=$target_pane"

tmpfile=$(mktemp)
if ! tmux capture-pane -t "$target_pane" -p -J -S - -E - >"$tmpfile" 2>/dev/null; then
  _log "ERROR" "capture-pane failed for $target_pane"
  rm -f "$tmpfile"
  exit 1
fi

line_count=$(wc -l <"$tmpfile")
_log "DEBUG" "Captured $line_count lines"

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
  rm -f "$tmpfile"
  exit 0
fi

entry_count=$(printf '%s\n' "$entries" | wc -l)
_log "DEBUG" "Found $entry_count entries"

# Write entries to temp file for the popup picker
entries_file=$(mktemp)
printf '%s\n' "$entries" >"$entries_file"

# Get the path to this script
script_dir="$(cd "$(dirname "$0")" && pwd)"
script_name="$(basename "$0")"

# Open popup with fzf picker (temp files cleaned up by --pick mode)
tmux display-popup -E -w 80% -h 80% "$script_dir/$script_name --pick '$tmpfile' '$entries_file'"
