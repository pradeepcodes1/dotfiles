# Log viewing utilities for dotfiles JSON logs
# Requires: jq

# Default log file
_DOTFILES_JSONL="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/logs/dotfiles.jsonl"

# Pretty print JSON logs
# Usage: dotlog [options]
#   -n NUM    Show last NUM entries (default: 50)
#   -l LEVEL  Filter by level (DEBUG, INFO, WARN, ERROR)
#   -c COMP   Filter by component
#   -s SOURCE Filter by source (shell, go, nvim)
#   -f        Follow mode (tail -f)
#   --errors  Show only errors
#   --today   Show only today's logs
dotlog() {
  local num=50 level="" component="" source="" follow=false
  local errors_only=false today_only=false
  local log_file="$_DOTFILES_JSONL"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n) num="$2"; shift 2 ;;
      -l) level="${2:u}"; shift 2 ;;
      -c) component="$2"; shift 2 ;;
      -s) source="$2"; shift 2 ;;
      -f) follow=true; shift ;;
      --errors) errors_only=true; shift ;;
      --today) today_only=true; shift ;;
      --file) log_file="$2"; shift 2 ;;
      -h|--help)
        echo "Usage: dotlog [options]"
        echo "  -n NUM     Last N entries (default: 50)"
        echo "  -l LEVEL   Filter: DEBUG, INFO, WARN, ERROR"
        echo "  -c COMP    Filter by component"
        echo "  -s SOURCE  Filter: shell, go, nvim"
        echo "  -f         Follow mode"
        echo "  --errors   Only errors"
        echo "  --today    Today only"
        return 0 ;;
      *) echo "Unknown: $1"; return 1 ;;
    esac
  done

  if [[ ! -f "$log_file" ]]; then
    echo "Log file not found: $log_file"
    return 1
  fi

  if ! command -v jq &>/dev/null; then
    echo "jq required. Install: brew install jq"
    return 1
  fi

  # Build jq filter
  local conditions=()
  [[ -n "$level" ]] && conditions+=(".level == \"$level\"")
  [[ -n "$component" ]] && conditions+=("(.component | test(\"$component\"; \"i\"))")
  [[ -n "$source" ]] && conditions+=(".source == \"$source\"")
  [[ "$errors_only" == true ]] && conditions+=(".level == \"ERROR\"")
  [[ "$today_only" == true ]] && conditions+=("(.ts | startswith(\"$(date +%Y-%m-%d)\"))")

  local jq_filter="."
  if [[ ${#conditions[@]} -gt 0 ]]; then
    jq_filter="select($(IFS=" and "; echo "${conditions[*]}"))"
  fi

  # Format output with colors
  local format_jq='
    def c(n): "\u001b[\(n)m";
    def lc: if .level == "DEBUG" then c("36")
      elif .level == "INFO" then c("32")
      elif .level == "WARN" then c("33")
      elif .level == "ERROR" then c("31")
      else "" end;
    "\(lc)[\(.ts | split("T")[1] | split(".")[0])] \(.level | .[0:1]) [\(.component)]\(c("0")) \(.msg)" +
    (if .duration_ms then " (\(.duration_ms)ms)" else "" end) +
    (if .exit_code and .exit_code != 0 then " [exit: \(.exit_code)]" else "" end) +
    (if .error then "\n  \(c("31"))Error: \(.error)\(c("0"))" else "" end)
  '

  if [[ "$follow" == true ]]; then
    tail -f "$log_file" | while read -r line; do
      echo "$line" | jq -r "$jq_filter | $format_jq" 2>/dev/null
    done
  else
    tail -n "$num" "$log_file" | jq -r "$jq_filter | $format_jq" 2>/dev/null
  fi
}

# Show log statistics
dotlog-stats() {
  local log_file="${1:-$_DOTFILES_JSONL}"

  if [[ ! -f "$log_file" ]]; then
    echo "Log file not found: $log_file"
    return 1
  fi

  echo "=== Log Statistics ==="
  echo ""

  echo "By Level:"
  jq -r '.level' "$log_file" 2>/dev/null | sort | uniq -c | sort -rn
  echo ""

  echo "By Component (top 10):"
  jq -r '.component' "$log_file" 2>/dev/null | sort | uniq -c | sort -rn | head -10
  echo ""

  echo "By Source:"
  jq -r '.source // "unknown"' "$log_file" 2>/dev/null | sort | uniq -c | sort -rn
  echo ""

  echo "Recent Errors:"
  jq -r 'select(.level == "ERROR") | "[\(.ts | split("T")[1] | split(".")[0])] [\(.component)] \(.msg)"' "$log_file" 2>/dev/null | tail -5
}

# Search logs by pattern
dotlog-search() {
  local pattern="$1"
  local log_file="${2:-$_DOTFILES_JSONL}"

  if [[ -z "$pattern" ]]; then
    echo "Usage: dotlog-search <pattern> [log_file]"
    return 1
  fi

  jq -r "select(.msg | test(\"$pattern\"; \"i\")) | \"[\(.ts | split(\"T\")[1] | split(\".\")[0])] \(.level) [\(.component)] \(.msg)\"" "$log_file" 2>/dev/null
}

# Clean old logs
dotlog-clean() {
  local log_dir="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/logs"
  local days="${1:-30}"

  echo "Cleaning logs older than $days days..."
  find "$log_dir" -name "*.jsonl*" -mtime +"$days" -delete -print 2>/dev/null
  echo "Done."
}

# Export to CSV
dotlog-export() {
  local log_file="${1:-$_DOTFILES_JSONL}"
  local output="${2:-dotfiles-logs.csv}"

  echo "timestamp,level,component,source,message" > "$output"
  jq -r '[.ts, .level, .component, (.source // "unknown"), .msg] | @csv' "$log_file" >> "$output" 2>/dev/null
  echo "Exported to: $output"
}

# Aliases
alias dlog='dotlog'
alias dlog-f='dotlog -f'
alias dlog-e='dotlog --errors'
