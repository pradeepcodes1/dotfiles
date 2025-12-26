#!/usr/bin/env zsh
# Centralized logging for dotfiles
#
# Console: Set DEBUG_DOTFILES=1 for debug output, =2 for timestamps
# JSON:    Set DOTFILES_JSON_LOG=1 to enable JSON file logging
#
# Functions:
#   debug_log "component" "message"
#   info_log "component" "message"
#   warn_log "component" "message"
#   error_log "component" "message"
#   log_command "component" "description" command args...

# Source shared config
_DOTFILES_LOG_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/dotfiles/logging.conf"
[[ -f "$_DOTFILES_LOG_CONF" ]] && source "$_DOTFILES_LOG_CONF"

# Defaults
: ${DOTFILES_LOG_DIR:="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/logs"}
: ${DOTFILES_LOG_FILE:="${DOTFILES_LOG_DIR}/dotfiles.jsonl"}
: ${DOTFILES_LOG_MAX_SIZE_MB:=10}
: ${DOTFILES_LOG_MAX_FILES:=5}
: ${DOTFILES_LOG_MAX_AGE_DAYS:=30}
: ${DOTFILES_JSON_LOG:=0}

# Colors for console
typeset -A LOG_COLORS
LOG_COLORS=(
  DEBUG "\033[0;36m"
  INFO "\033[0;32m"
  WARN "\033[0;33m"
  ERROR "\033[0;31m"
  RESET "\033[0m"
)

typeset -A LOG_PREFIX
LOG_PREFIX=(
  DEBUG "D"
  INFO "I"
  WARN "W"
  ERROR "E"
)

# ISO 8601 timestamp
_log_timestamp() {
  date -u '+%Y-%m-%dT%H:%M:%S.000Z'
}

# Escape string for JSON
_json_escape() {
  local str="$1"
  str="${str//\\/\\\\}"
  str="${str//\"/\\\"}"
  str="${str//$'\n'/\\n}"
  str="${str//$'\r'/\\r}"
  str="${str//$'\t'/\\t}"
  printf '%s' "$str"
}

# Build JSON log entry
_build_json_log() {
  local level="$1" component="$2" message="$3"
  shift 3

  local ts="$(_log_timestamp)"
  local escaped_msg="$(_json_escape "$message")"
  local escaped_comp="$(_json_escape "$component")"

  local json="{\"ts\":\"$ts\",\"level\":\"$level\",\"component\":\"$escaped_comp\",\"msg\":\"$escaped_msg\",\"source\":\"shell\",\"pid\":$$"

  # Add extra key=value fields
  for kv in "$@"; do
    local key="${kv%%=*}"
    local value="${kv#*=}"
    if [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
      json="$json,\"$key\":$value"
    else
      json="$json,\"$key\":\"$(_json_escape "$value")\""
    fi
  done

  printf '%s}' "$json"
}

# Rotate log files if needed
_rotate_logs() {
  [[ ! -f "$DOTFILES_LOG_FILE" ]] && return 0

  local size_bytes=$(stat -f%z "$DOTFILES_LOG_FILE" 2>/dev/null || echo 0)
  local max_bytes=$((DOTFILES_LOG_MAX_SIZE_MB * 1024 * 1024))

  if [[ $size_bytes -gt $max_bytes ]]; then
    for i in $(seq $((DOTFILES_LOG_MAX_FILES - 1)) -1 1); do
      [[ -f "${DOTFILES_LOG_FILE}.$i" ]] && mv "${DOTFILES_LOG_FILE}.$i" "${DOTFILES_LOG_FILE}.$((i+1))" 2>/dev/null
    done
    mv "$DOTFILES_LOG_FILE" "${DOTFILES_LOG_FILE}.1" 2>/dev/null || true
  fi
}

# Cleanup old rotated logs (runs on shell start)
_cleanup_old_logs() {
  [[ ! -d "$DOTFILES_LOG_DIR" ]] && return 0
  find "$DOTFILES_LOG_DIR" -name "*.jsonl.*" -mtime +"$DOTFILES_LOG_MAX_AGE_DAYS" -delete 2>/dev/null || true
}

# Write JSON to log file
_write_json_log() {
  [[ "${DOTFILES_JSON_LOG:-0}" != "1" ]] && return 0

  mkdir -p "$DOTFILES_LOG_DIR" 2>/dev/null || return 0
  _rotate_logs
  printf '%s\n' "$1" >> "$DOTFILES_LOG_FILE" 2>/dev/null || true
}

# Internal log function
_log() {
  local level="$1" component="$2"
  shift 2
  local message="$*"

  local color="${LOG_COLORS[$level]}"
  local reset="${LOG_COLORS[RESET]}"
  local prefix="${LOG_PREFIX[$level]}"

  # Console output
  local console=""
  [[ "${DEBUG_DOTFILES:-0}" -ge 2 ]] && console="[$(date '+%H:%M:%S')] "
  console="${console}${color}${prefix} [${component}]${reset} ${message}"

  if [[ "$level" == "ERROR" || "$level" == "WARN" ]]; then
    echo "$console" >&2
  else
    echo "$console"
  fi

  # JSON file output
  _write_json_log "$(_build_json_log "$level" "$component" "$message")"
}

# Debug log
debug_log() {
  if [[ "${DEBUG_DOTFILES:-0}" -ge 1 ]]; then
    _log "DEBUG" "$@"
  elif [[ "${DOTFILES_JSON_LOG:-0}" == "1" ]]; then
    _write_json_log "$(_build_json_log "DEBUG" "$1" "${@:2}")"
  fi
}

# Info log
info_log() {
  if [[ "${DEBUG_DOTFILES:-0}" -ge 1 ]]; then
    _log "INFO" "$@"
  elif [[ "${DOTFILES_JSON_LOG:-0}" == "1" ]]; then
    _write_json_log "$(_build_json_log "INFO" "$1" "${@:2}")"
  fi
}

# Warning log - always shows
warn_log() {
  _log "WARN" "$@"
}

# Error log - always shows
error_log() {
  _log "ERROR" "$@"
}

# Log command with timing
log_command() {
  local component="$1" description="$2"
  shift 2

  debug_log "$component" "Running: $description"

  local start_ms=$(($(date +%s) * 1000))
  "$@"
  local exit_code=$?
  local end_ms=$(($(date +%s) * 1000))
  local duration_ms=$((end_ms - start_ms))

  if [[ $exit_code -eq 0 ]]; then
    if [[ "${DOTFILES_JSON_LOG:-0}" == "1" ]]; then
      _write_json_log "$(_build_json_log "INFO" "$component" "$description completed" "duration_ms=$duration_ms" "exit_code=$exit_code")"
    fi
    [[ "${DEBUG_DOTFILES:-0}" -ge 2 ]] && debug_log "$component" "Completed: $description (${duration_ms}ms)"
  else
    if [[ "${DOTFILES_JSON_LOG:-0}" == "1" ]]; then
      _write_json_log "$(_build_json_log "ERROR" "$component" "$description failed" "duration_ms=$duration_ms" "exit_code=$exit_code")"
    fi
    error_log "$component" "Failed: $description (exit $exit_code, ${duration_ms}ms)"
  fi

  return $exit_code
}

# Run cleanup on shell start (lightweight)
_cleanup_old_logs

debug_log "logging" "Logging initialized (console=${DEBUG_DOTFILES:-0}, json=${DOTFILES_JSON_LOG:-0})"
