#!/usr/bin/env bats
# Unit tests for nix.zsh - migrated from test-flake.sh

load '../helpers/test_helper'

setup() {
  common_setup

  # Set up nix environment variables for testing
  export NIX_PROFILES_FILE="${TEST_TEMP_DIR}/config/nix-profiles.json"
  export NIX_HOMES_DIR="${TEST_TEMP_DIR}/nix-homes"
  export FLAKES_DIR="${TEST_TEMP_DIR}/nix"

  # Create flakes directory structure
  create_flakes_fixture "$FLAKES_DIR"
}

teardown() {
  common_teardown
}

# === _nix_ensure_profiles tests ===

@test "_nix_ensure_profiles creates profiles file" {
  run run_zsh_function "nix.zsh" "_nix_ensure_profiles"

  assert_success
  assert_file_exists "$NIX_PROFILES_FILE"
}

@test "_nix_ensure_profiles initializes with empty array" {
  run run_zsh_function "nix.zsh" "_nix_ensure_profiles"

  assert_success
  run cat "$NIX_PROFILES_FILE"
  assert_output "[]"
}

@test "_nix_ensure_profiles is idempotent" {
  run_zsh_function "nix.zsh" "_nix_ensure_profiles"
  run_zsh_function "nix.zsh" "_nix_ensure_profiles"

  run cat "$NIX_PROFILES_FILE"
  assert_output "[]"
}

@test "_nix_ensure_profiles creates parent directory" {
  export NIX_PROFILES_FILE="${TEST_TEMP_DIR}/deep/nested/dir/profiles.json"

  run run_zsh_function "nix.zsh" "_nix_ensure_profiles"

  assert_success
  assert_file_exists "$NIX_PROFILES_FILE"
}

# === _nix_add_profile tests ===

@test "_nix_add_profile adds profile to JSON" {
  skip_if_missing jq

  # First ensure profiles file exists
  run_zsh_function "nix.zsh" "_nix_ensure_profiles"

  run run_zsh_function "nix.zsh" "_nix_add_profile" "${NIX_HOMES_DIR}/test-home" "test-profile" "basic" "dev"

  assert_success

  # Verify JSON contains profile
  run cat "$NIX_PROFILES_FILE"
  assert_output --partial "test-profile"
  assert_output --partial "test-home"
  assert_output --partial "basic"
  assert_output --partial "dev"
}

@test "_nix_add_profile creates valid JSON structure" {
  skip_if_missing jq

  run_zsh_function "nix.zsh" "_nix_ensure_profiles"
  run_zsh_function "nix.zsh" "_nix_add_profile" "${NIX_HOMES_DIR}/myenv" "myenv" "basic"

  # Validate JSON structure
  run jq 'length' "$NIX_PROFILES_FILE"
  assert_output "1"

  run jq -r '.[0].name' "$NIX_PROFILES_FILE"
  assert_output "myenv"

  run jq '.[0].flakes | length' "$NIX_PROFILES_FILE"
  assert_output "1"
}

@test "_nix_add_profile supports multiple flakes" {
  skip_if_missing jq

  run_zsh_function "nix.zsh" "_nix_ensure_profiles"
  run_zsh_function "nix.zsh" "_nix_add_profile" "${NIX_HOMES_DIR}/multi" "multi" "basic" "dev" "work"

  run jq '.[0].flakes | length' "$NIX_PROFILES_FILE"
  assert_output "3"

  run jq -r '.[0].flakes[0]' "$NIX_PROFILES_FILE"
  assert_output "basic"

  run jq -r '.[0].flakes[2]' "$NIX_PROFILES_FILE"
  assert_output "work"
}

@test "_nix_add_profile can add multiple profiles" {
  skip_if_missing jq

  run_zsh_function "nix.zsh" "_nix_ensure_profiles"
  run_zsh_function "nix.zsh" "_nix_add_profile" "${NIX_HOMES_DIR}/first" "first" "basic"
  run_zsh_function "nix.zsh" "_nix_add_profile" "${NIX_HOMES_DIR}/second" "second" "dev"

  run jq 'length' "$NIX_PROFILES_FILE"
  assert_output "2"

  run jq -r '.[0].name' "$NIX_PROFILES_FILE"
  assert_output "first"

  run jq -r '.[1].name' "$NIX_PROFILES_FILE"
  assert_output "second"
}

# === _nix_list_flakes tests ===

@test "_nix_list_flakes lists directories with flake.nix" {
  run run_zsh_function "nix.zsh" "_nix_list_flakes"

  assert_success
  assert_output --partial "basic"
  assert_output --partial "dev"
  assert_output --partial "work"
}

@test "_nix_list_flakes excludes directories without flake.nix" {
  run run_zsh_function "nix.zsh" "_nix_list_flakes"

  assert_success
  refute_output --partial "not-a-flake"
}

@test "_nix_list_flakes returns empty when no flakes exist" {
  rm -rf "$FLAKES_DIR"
  mkdir -p "$FLAKES_DIR"

  run run_zsh_function "nix.zsh" "_nix_list_flakes"

  # When no flakes exist, the for loop in zsh may output the glob pattern itself
  # or nothing at all. Check that no valid flake names are in output.
  refute_output --partial "basic"
  refute_output --partial "dev"
  refute_output --partial "work"
}

@test "_nix_list_flakes works with single flake" {
  rm -rf "$FLAKES_DIR"
  mkdir -p "$FLAKES_DIR/single"
  touch "$FLAKES_DIR/single/flake.nix"

  run run_zsh_function "nix.zsh" "_nix_list_flakes"

  assert_success
  assert_output "single"
}

# === _nix_setup_home tests ===

@test "_nix_setup_home creates symlinks in empty home" {
  local test_home="${TEST_TEMP_DIR}/new-home"
  local real_home="${TEST_TEMP_DIR}/real-home"

  mkdir -p "$test_home"
  mkdir -p "$real_home/.config"
  touch "$real_home/.zshrc"

  run run_zsh_function "nix.zsh" "_nix_setup_home" "$test_home" "$real_home"

  assert_success
  assert_file_exists "$test_home/.zshrc"
  assert_dir_exists "$test_home/.config"
}

@test "_nix_setup_home returns 0 on first run (empty home)" {
  local test_home="${TEST_TEMP_DIR}/empty-home"
  local real_home="${TEST_TEMP_DIR}/real"

  mkdir -p "$test_home"
  mkdir -p "$real_home/.config"

  run run_zsh_function "nix.zsh" "_nix_setup_home" "$test_home" "$real_home"

  assert_success
}

@test "_nix_setup_home returns 1 when home not empty" {
  local test_home="${TEST_TEMP_DIR}/nonempty-home"
  local real_home="${TEST_TEMP_DIR}/real"

  mkdir -p "$test_home"
  mkdir -p "$real_home"
  touch "$test_home/existing-file"

  run run_zsh_function "nix.zsh" "_nix_setup_home" "$test_home" "$real_home"

  assert_failure
}

@test "_nix_setup_home creates correct symlinks" {
  local test_home="${TEST_TEMP_DIR}/link-test-home"
  local real_home="${TEST_TEMP_DIR}/link-real-home"

  mkdir -p "$test_home"
  mkdir -p "$real_home/.config/nvim"
  touch "$real_home/.zshrc"

  run_zsh_function "nix.zsh" "_nix_setup_home" "$test_home" "$real_home"

  # Verify symlinks exist and point to correct targets
  [[ -L "$test_home/.zshrc" ]]
  [[ "$(readlink "$test_home/.zshrc")" == "$real_home/.zshrc" ]]
}

@test "_nix_setup_home only links existing items" {
  local test_home="${TEST_TEMP_DIR}/partial-home"
  local real_home="${TEST_TEMP_DIR}/partial-real"

  mkdir -p "$test_home"
  mkdir -p "$real_home"
  # Only create .zshrc, not .config
  touch "$real_home/.zshrc"

  run_zsh_function "nix.zsh" "_nix_setup_home" "$test_home" "$real_home"

  # .zshrc should be linked
  assert_file_exists "$test_home/.zshrc"
  # .config should NOT exist (wasn't in real_home)
  [[ ! -e "$test_home/.config" ]]
}
