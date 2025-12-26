#!/usr/bin/env bats
# Unit tests for navigation.zsh
# Note: All tests require zoxide because navigation.zsh returns early without it

load '../helpers/test_helper'

setup() {
  common_setup
  skip_if_missing zoxide

  # Create test directory structure
  PROJECT_DIR=$(create_navigation_fixture)
  export PROJECT_DIR
}

teardown() {
  common_teardown
}

# === mkcd function tests ===

@test "mkcd creates directory and changes to it" {
  local new_dir="${TEST_TEMP_DIR}/new/nested/dir"

  run run_zsh_code "navigation.zsh" "mkcd '$new_dir' && pwd"

  assert_success
  assert_output --partial "$new_dir"
  assert_dir_exists "$new_dir"
}

@test "mkcd with no args shows usage error" {
  run run_zsh_function "navigation.zsh" "mkcd"

  assert_failure
  assert_output --partial "Usage: mkcd"
}

@test "mkcd creates deeply nested directories" {
  local deep_dir="${TEST_TEMP_DIR}/a/b/c/d/e/f"

  run run_zsh_code "navigation.zsh" "mkcd '$deep_dir' && pwd"

  assert_success
  assert_dir_exists "$deep_dir"
}

# === up function tests ===

@test "up goes up one directory by default" {
  run run_zsh_code "navigation.zsh" "cd '${PROJECT_DIR}/a/b/c/d' && up && pwd"

  assert_success
  assert_output --partial "${PROJECT_DIR}/a/b/c"
}

@test "up 2 goes up two directories" {
  run run_zsh_code "navigation.zsh" "cd '${PROJECT_DIR}/a/b/c/d' && up 2 && pwd"

  assert_success
  assert_output --partial "${PROJECT_DIR}/a/b"
}

@test "up 3 goes up three directories" {
  run run_zsh_code "navigation.zsh" "cd '${PROJECT_DIR}/a/b/c/d' && up 3 && pwd"

  assert_success
  assert_output --partial "${PROJECT_DIR}/a"
}

# === cdf function tests ===

@test "cdf changes to directory containing file" {
  run run_zsh_code "navigation.zsh" "cdf '${PROJECT_DIR}/src/index.js' && pwd"

  assert_success
  assert_output --partial "${PROJECT_DIR}/src"
}

@test "cdf with directory argument shows error" {
  run run_zsh_function "navigation.zsh" "cdf" "${PROJECT_DIR}/src"

  assert_failure
  assert_output --partial "not a file"
}

@test "cdf with non-existent file shows error" {
  run run_zsh_function "navigation.zsh" "cdf" "/nonexistent/file.txt"

  assert_failure
}

# === bd function tests ===

@test "bd with no args shows usage" {
  run run_zsh_function "navigation.zsh" "bd"

  assert_failure
  assert_output --partial "Usage: bd"
}

@test "bd navigates to parent by name" {
  run run_zsh_code "navigation.zsh" "cd '${PROJECT_DIR}/a/b/c/d' && bd b && pwd"

  assert_success
  assert_output --partial "${PROJECT_DIR}/a/b"
}

@test "bd with non-matching parent shows error" {
  run run_zsh_code "navigation.zsh" "cd '${PROJECT_DIR}/a/b/c/d' && bd nonexistent"

  assert_failure
  assert_output --partial "No parent directory named"
}

# === cdls function tests ===

@test "cdls changes directory and lists contents" {
  run run_zsh_function "navigation.zsh" "cdls" "${PROJECT_DIR}"

  assert_success
  assert_output --partial "README.md"
}

# === cd override tests ===

@test "cd override works with valid directory" {
  run run_zsh_code "navigation.zsh" "cd '${PROJECT_DIR}/src' && pwd"

  assert_success
  assert_output --partial "${PROJECT_DIR}/src"
}

@test "cd with no args goes to HOME" {
  run run_zsh_code "navigation.zsh" "cd && pwd"

  assert_success
  assert_output --partial "${HOME}"
}

# === Function existence tests ===

@test "zi function exists" {
  run zsh_function_exists "navigation.zsh" "zi"

  assert_success
}

@test "fcd function exists" {
  run zsh_function_exists "navigation.zsh" "fcd"

  assert_success
}
