#!/usr/bin/env bash
# test_helper.bash - Common test setup for all bats tests

# Determine test root directory
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "$TESTS_DIR/.." && pwd)"

# Load bats libraries
load "${TESTS_DIR}/bats/bats-support/load"
load "${TESTS_DIR}/bats/bats-assert/load"
load "${TESTS_DIR}/bats/bats-file/load"

# Load custom helpers
load "${TESTS_DIR}/helpers/zsh_loader"
load "${TESTS_DIR}/helpers/fixtures"

# Standard setup function - called before each test
common_setup() {
  TEST_TEMP_DIR="$(mktemp -d)"
  export TEST_TEMP_DIR

  # Create standard test directories
  mkdir -p "${TEST_TEMP_DIR}"/{home,config,state,logs}

  # Override HOME and XDG directories for isolation
  export ORIGINAL_HOME="${HOME}"
  export HOME="${TEST_TEMP_DIR}/home"
  export XDG_STATE_HOME="${TEST_TEMP_DIR}/state"
  export XDG_CONFIG_HOME="${TEST_TEMP_DIR}/config"

  # Disable debug output by default
  export DEBUG_DOTFILES=0
  unset DOTFILES_LOG_FILE
}

# Standard teardown function - called after each test
common_teardown() {
  export HOME="${ORIGINAL_HOME}"
  [[ -d "${TEST_TEMP_DIR}" ]] && rm -rf "${TEST_TEMP_DIR}"
}

# Helper: Skip if command not available
skip_if_missing() {
  command -v "$1" &>/dev/null || skip "$1 not available"
}

# Helper: Assert file contains text
assert_file_contains() {
  assert_file_exists "$1"
  run grep -q "$2" "$1"
  assert_success
}

# Helper: Assert directory exists
assert_dir_exists() {
  [[ -d "$1" ]] || fail "Directory does not exist: $1"
}
