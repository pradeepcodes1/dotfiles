#!/usr/bin/env bash
# zsh_loader.bash - Load and execute zsh functions for testing

# Path to zsh config files
ZSH_CONFIG_DIR="${PROJECT_ROOT}/dot_config/zsh"

# Internal: Build environment exports for zsh subshell
_build_zsh_env() {
  cat <<EOF
export DEBUG_DOTFILES='${DEBUG_DOTFILES:-0}'
export DOTFILES_LOG_FILE='${DOTFILES_LOG_FILE:-}'
export HOME='${HOME}'
export XDG_STATE_HOME='${XDG_STATE_HOME:-}'
export XDG_CONFIG_HOME='${XDG_CONFIG_HOME:-}'
export NIX_PROFILES_FILE='${NIX_PROFILES_FILE:-}'
export NIX_HOMES_DIR='${NIX_HOMES_DIR:-}'
export FLAKES_DIR='${FLAKES_DIR:-}'
EOF
}

# Execute a zsh function and capture output
# Usage: run_zsh_function "source_file" "function_name" "arg1" "arg2"
run_zsh_function() {
  local source_file="$1"
  local func_name="$2"
  shift 2
  local args=("$@")

  local full_path="${ZSH_CONFIG_DIR}/${source_file}"
  local logging_path="${ZSH_CONFIG_DIR}/00-logging.zsh"

  if [[ ! -f "$full_path" ]]; then
    echo "ERROR: ZSH file not found: $full_path" >&2
    return 1
  fi

  local args_str=""
  if [[ ${#args[@]} -gt 0 ]]; then
    args_str=$(printf '%q ' "${args[@]}")
  fi

  # Always source logging first (unless we're testing logging itself)
  local source_cmd=""
  if [[ "$source_file" != "00-logging.zsh" && -f "$logging_path" ]]; then
    source_cmd="source '$logging_path'; "
  fi

  zsh -c "$(_build_zsh_env)
${source_cmd}source '$full_path'
$func_name $args_str"
}

# Execute zsh code directly (for more complex scenarios)
# Usage: run_zsh_code "source_file" "code to execute"
run_zsh_code() {
  local source_file="$1"
  local code="$2"

  local full_path="${ZSH_CONFIG_DIR}/${source_file}"
  local logging_path="${ZSH_CONFIG_DIR}/00-logging.zsh"

  if [[ ! -f "$full_path" ]]; then
    echo "ERROR: ZSH file not found: $full_path" >&2
    return 1
  fi

  # Always source logging first (unless we're testing logging itself)
  local source_cmd=""
  if [[ "$source_file" != "00-logging.zsh" && -f "$logging_path" ]]; then
    source_cmd="source '$logging_path'; "
  fi

  zsh -c "$(_build_zsh_env)
${source_cmd}source '$full_path'
$code"
}

# Helper to check if a zsh function exists in a file
zsh_function_exists() {
  local source_file="$1"
  local func_name="$2"

  local full_path="${ZSH_CONFIG_DIR}/${source_file}"

  zsh -c "source '$full_path'; typeset -f '$func_name' >/dev/null 2>&1"
}
