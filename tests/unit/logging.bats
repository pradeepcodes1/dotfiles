#!/usr/bin/env bats
# Unit tests for 00-logging.zsh

load '../helpers/test_helper'

setup() {
  common_setup
}

teardown() {
  common_teardown
}

# === debug_log tests ===

@test "debug_log is silent when DEBUG_DOTFILES=0" {
  export DEBUG_DOTFILES=0

  run run_zsh_function "00-logging.zsh" "debug_log" "test" "Should not appear"

  assert_success
  # Output should be empty (only the initialization message might appear)
  refute_output --partial "Should not appear"
}

@test "debug_log outputs when DEBUG_DOTFILES=1" {
  export DEBUG_DOTFILES=1

  run run_zsh_function "00-logging.zsh" "debug_log" "test-component" "Test message"

  assert_success
  assert_output --partial "test-component"
  assert_output --partial "Test message"
}

@test "debug_log outputs when DEBUG_DOTFILES=2" {
  export DEBUG_DOTFILES=2

  run run_zsh_function "00-logging.zsh" "debug_log" "verbose" "Verbose message"

  assert_success
  assert_output --partial "Verbose message"
}

@test "debug_log includes timestamp when DEBUG_DOTFILES=2" {
  export DEBUG_DOTFILES=2

  run run_zsh_function "00-logging.zsh" "debug_log" "timer" "Timed message"

  assert_success
  # Should include HH:MM:SS format
  assert_output --regexp '\[[0-9]{2}:[0-9]{2}:[0-9]{2}\]'
}

# === info_log tests ===

@test "info_log is silent when DEBUG_DOTFILES=0" {
  export DEBUG_DOTFILES=0

  run run_zsh_function "00-logging.zsh" "info_log" "info" "Info message"

  assert_success
  refute_output --partial "Info message"
}

@test "info_log outputs when DEBUG_DOTFILES>=1" {
  export DEBUG_DOTFILES=1

  run run_zsh_function "00-logging.zsh" "info_log" "info" "Info message"

  assert_success
  assert_output --partial "Info message"
}

# === warn_log tests ===

@test "warn_log always outputs regardless of DEBUG_DOTFILES" {
  export DEBUG_DOTFILES=0

  run run_zsh_function "00-logging.zsh" "warn_log" "warning" "Warning message"

  assert_success
  assert_output --partial "Warning message"
}

@test "warn_log includes component name" {
  export DEBUG_DOTFILES=0

  run run_zsh_function "00-logging.zsh" "warn_log" "my-component" "A warning"

  assert_success
  assert_output --partial "my-component"
  assert_output --partial "A warning"
}

# === error_log tests ===

@test "error_log always outputs regardless of DEBUG_DOTFILES" {
  export DEBUG_DOTFILES=0

  run run_zsh_function "00-logging.zsh" "error_log" "error" "Error message"

  assert_success
  assert_output --partial "Error message"
}

@test "error_log includes component name" {
  export DEBUG_DOTFILES=0

  run run_zsh_function "00-logging.zsh" "error_log" "my-module" "Something failed"

  assert_success
  assert_output --partial "my-module"
  assert_output --partial "Something failed"
}

# === File logging tests ===

@test "logs are written to DOTFILES_LOG_FILE when set" {
  export DEBUG_DOTFILES=1
  export DOTFILES_LOG_FILE="${TEST_TEMP_DIR}/logs/test.log"

  run run_zsh_function "00-logging.zsh" "info_log" "file" "Log to file"

  assert_success
  assert_file_exists "$DOTFILES_LOG_FILE"
  run cat "$DOTFILES_LOG_FILE"
  assert_output --partial "Log to file"
}

@test "file logs have full timestamp format" {
  export DEBUG_DOTFILES=1
  export DOTFILES_LOG_FILE="${TEST_TEMP_DIR}/logs/timestamp.log"

  run run_zsh_function "00-logging.zsh" "info_log" "ts" "Timestamped"

  assert_file_exists "$DOTFILES_LOG_FILE"
  run cat "$DOTFILES_LOG_FILE"
  # Should have format: [YYYY-MM-DD HH:MM:SS] [LEVEL] [component] message
  assert_output --regexp '\[20[0-9]{2}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]'
  assert_output --partial "[INFO]"
  assert_output --partial "[ts]"
}

@test "file logs do not contain ANSI color codes" {
  export DEBUG_DOTFILES=1
  export DOTFILES_LOG_FILE="${TEST_TEMP_DIR}/logs/nocolor.log"

  run run_zsh_function "00-logging.zsh" "debug_log" "clean" "No colors here"

  assert_file_exists "$DOTFILES_LOG_FILE"
  # Check that file doesn't contain escape sequences
  run grep -c $'\033' "$DOTFILES_LOG_FILE" || true
  assert_output "0"
}

@test "log directory is created if it doesn't exist" {
  export DEBUG_DOTFILES=1
  export DOTFILES_LOG_FILE="${TEST_TEMP_DIR}/new/nested/dir/app.log"

  run run_zsh_function "00-logging.zsh" "info_log" "mkdir" "Creates parent dirs"

  assert_file_exists "$DOTFILES_LOG_FILE"
  assert_dir_exists "${TEST_TEMP_DIR}/new/nested/dir"
}

@test "warn_log is written to file even when DEBUG_DOTFILES=0" {
  export DEBUG_DOTFILES=0
  export DOTFILES_LOG_FILE="${TEST_TEMP_DIR}/logs/warn.log"

  run run_zsh_function "00-logging.zsh" "warn_log" "test" "Warning in file"

  assert_file_exists "$DOTFILES_LOG_FILE"
  run cat "$DOTFILES_LOG_FILE"
  assert_output --partial "Warning in file"
  assert_output --partial "[WARN]"
}

@test "error_log is written to file even when DEBUG_DOTFILES=0" {
  export DEBUG_DOTFILES=0
  export DOTFILES_LOG_FILE="${TEST_TEMP_DIR}/logs/error.log"

  run run_zsh_function "00-logging.zsh" "error_log" "test" "Error in file"

  assert_file_exists "$DOTFILES_LOG_FILE"
  run cat "$DOTFILES_LOG_FILE"
  assert_output --partial "Error in file"
  assert_output --partial "[ERROR]"
}

# === log_command tests ===

@test "log_command executes the command" {
  export DEBUG_DOTFILES=1

  run run_zsh_function "00-logging.zsh" "log_command" "exec" "echo test" "echo" "hello world"

  assert_success
  assert_output --partial "hello world"
}

@test "log_command logs the description" {
  export DEBUG_DOTFILES=1

  run run_zsh_function "00-logging.zsh" "log_command" "test" "Running echo" "echo" "output"

  assert_success
  assert_output --partial "Running echo"
}

@test "log_command shows timing when DEBUG_DOTFILES=2" {
  export DEBUG_DOTFILES=2

  run run_zsh_function "00-logging.zsh" "log_command" "timed" "echo test" "echo" "done"

  assert_success
  # Should show duration in seconds
  assert_output --regexp "[0-9]+s"
}

# === Component name in output ===

@test "all log levels include component name in brackets" {
  export DEBUG_DOTFILES=1
  export DOTFILES_LOG_FILE="${TEST_TEMP_DIR}/logs/components.log"

  run_zsh_function "00-logging.zsh" "debug_log" "comp1" "debug msg"
  run_zsh_function "00-logging.zsh" "info_log" "comp2" "info msg"
  run_zsh_function "00-logging.zsh" "warn_log" "comp3" "warn msg"
  run_zsh_function "00-logging.zsh" "error_log" "comp4" "error msg"

  run cat "$DOTFILES_LOG_FILE"
  assert_output --partial "[comp1]"
  assert_output --partial "[comp2]"
  assert_output --partial "[comp3]"
  assert_output --partial "[comp4]"
}
