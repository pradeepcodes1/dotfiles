#!/usr/bin/env bash
# fixtures.bash - Test fixture generators

# Create a flakes directory fixture with test flakes
create_flakes_fixture() {
  local flakes_dir="${1:-${TEST_TEMP_DIR}/nix}"

  mkdir -p "${flakes_dir}"/{basic,dev,work,not-a-flake}
  touch "${flakes_dir}/basic/flake.nix"
  touch "${flakes_dir}/dev/flake.nix"
  touch "${flakes_dir}/work/flake.nix"
  # not-a-flake has no flake.nix, should be ignored

  echo "$flakes_dir"
}

# Create directory structure for navigation tests
create_navigation_fixture() {
  local base_dir="${1:-${TEST_TEMP_DIR}/project}"

  mkdir -p "${base_dir}/a/b/c/d"
  mkdir -p "${base_dir}/src/components"
  mkdir -p "${base_dir}/tests/unit"

  touch "${base_dir}/README.md"
  touch "${base_dir}/src/index.js"
  touch "${base_dir}/tests/unit/test.js"

  echo "$base_dir"
}
