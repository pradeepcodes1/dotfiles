#!/usr/bin/env zsh
# Centralized logging utility for all dotfiles scripts
#
# USAGE:
#   Set DEBUG_DOTFILES=1 to enable debug logging
#   Set DEBUG_DOTFILES=2 to enable verbose debug logging (includes timestamps)
#   Set DOTFILES_LOG_FILE=/path/to/file.log to also write logs to a file
#
# FUNCTIONS:
#   debug_log "component" "message"  - Only shows if DEBUG_DOTFILES >= 1
#   info_log "component" "message"   - Only shows if DEBUG_DOTFILES >= 1
#   warn_log "component" "message"   - Always shows (warnings)
#   error_log "component" "message"  - Always shows (errors)
#   log_command "component" "description" command args...  - Logs command execution with timing
#
# EXAMPLES:
#   debug_log "backup" "Starting backup process..."
#   info_log "theme" "Theme switched to dark mode"
#   warn_log "brew" "Package not found in Brewfile"
#   error_log "nvim" "Failed to load plugin"
#   log_command "backup" "Creating backup" restic backup /home/user
#
#   # With file logging
#   export DOTFILES_LOG_FILE="$HOME/.local/state/dotfiles/debug.log"
#   debug_log "theme" "This goes to both console and file"
#
# This file is sourced first (alphabetically) to ensure logging is available
# to all other zsh configuration files.

# Color codes for different log levels
typeset -A LOG_COLORS
LOG_COLORS=(
  DEBUG "\033[0;36m" # Cyan
  INFO "\033[0;32m"  # Green
  WARN "\033[0;33m"  # Yellow
  ERROR "\033[0;31m" # Red
  RESET "\033[0m"    # Reset
)

# Log level prefix mapping
typeset -A LOG_PREFIX
LOG_PREFIX=(
  DEBUG "🔍"
  INFO "ℹ️ "
  WARN "⚠️ "
  ERROR "❌"
)

# Internal logging function
_log() {
  local level="$1"
  local component="$2"
  shift 2
  local message="$*"

  local color="${LOG_COLORS[$level]}"
  local reset="${LOG_COLORS[RESET]}"
  local prefix="${LOG_PREFIX[$level]}"

  # Build console output with colors
  local console_output=""
  local file_output=""
  local timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

  # Add timestamp if verbose mode (DEBUG_DOTFILES=2)
  if [[ "${DEBUG_DOTFILES:-0}" -ge 2 ]]; then
    console_output="[$(date '+%H:%M:%S')] "
  fi

  # Console output with colors
  console_output="${console_output}${color}${prefix} [${component}]${reset} ${message}"

  # File output without colors (plain text with full timestamp)
  file_output="[${timestamp}] [${level}] [${component}] ${message}"

  # Print to console (stderr for errors/warnings, stdout otherwise)
  if [[ "$level" == "ERROR" || "$level" == "WARN" ]]; then
    echo "$console_output" >&2
  else
    echo "$console_output"
  fi

  # Write to log file if DOTFILES_LOG_FILE is set
  if [[ -n "$DOTFILES_LOG_FILE" ]]; then
    local log_dir="$(dirname "$DOTFILES_LOG_FILE")"

    # Create log directory if it doesn't exist
    if [[ ! -d "$log_dir" ]]; then
      mkdir -p "$log_dir" 2>/dev/null || return 0
    fi

    # Append to log file
    echo "$file_output" >>"$DOTFILES_LOG_FILE" 2>/dev/null || true

    # Rotate log if it exceeds 10MB
    if [[ -f "$DOTFILES_LOG_FILE" ]] && [[ $(stat -f%z "$DOTFILES_LOG_FILE" 2>/dev/null || echo 0) -gt 10485760 ]]; then
      mv "$DOTFILES_LOG_FILE" "${DOTFILES_LOG_FILE}.old" 2>/dev/null || true
    fi
  fi
}

# Debug log - only shows if DEBUG_DOTFILES is set
debug_log() {
  [[ "${DEBUG_DOTFILES:-0}" -ge 1 ]] || return 0
  _log "DEBUG" "$@"
}

# Info log - only shows if DEBUG_DOTFILES is set
info_log() {
  [[ "${DEBUG_DOTFILES:-0}" -ge 1 ]] || return 0
  _log "INFO" "$@"
}

# Warning log - always shows
warn_log() {
  _log "WARN" "$@"
}

# Error log - always shows
error_log() {
  _log "ERROR" "$@"
}

# Utility to log command execution with timing
# Usage: log_command "component" "description" command args...
log_command() {
  local component="$1"
  local description="$2"
  shift 2

  debug_log "$component" "Running: $description"

  if [[ "${DEBUG_DOTFILES:-0}" -ge 2 ]]; then
    local start_time=$(date +%s)
    "$@"
    local exit_code=$?
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    if [[ $exit_code -eq 0 ]]; then
      debug_log "$component" "✓ $description (${duration}s)"
    else
      error_log "$component" "✗ $description failed with exit code $exit_code (${duration}s)"
    fi

    return $exit_code
  else
    "$@"
  fi
}

# Note: In zsh, functions are automatically available throughout the shell session.
# Unlike bash, zsh doesn't need 'export -f' and doesn't support it.
# Functions defined here are available to all zsh configuration files.

# Log that logging system is initialized (only in verbose mode)
debug_log "logging" "Logging system initialized (DEBUG_DOTFILES=${DEBUG_DOTFILES:-0})"
