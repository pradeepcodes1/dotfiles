#!/usr/bin/env bash
# Test runner script for bats tests

set -e

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$TESTS_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Default options
VERBOSE=false
FILTER=""
JOBS=""

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS] [FILTER]

Run bats tests for the chezmoi dotfiles repository.

Options:
    -v, --verbose       Verbose output (show each test)
    -j, --jobs N        Run N tests in parallel
    -h, --help          Show this help

Filter:
    Optional test file or pattern (e.g., "logging", "navigation.bats")

Examples:
    $(basename "$0")                    # Run all tests
    $(basename "$0") logging            # Run logging tests
    $(basename "$0") -v navigation      # Run navigation tests verbosely
    $(basename "$0") -j 4               # Run tests with 4 parallel jobs

EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v | --verbose)
      VERBOSE=true
      shift
      ;;
    -j | --jobs)
      JOBS="$2"
      shift 2
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${NC}"
      usage
      exit 1
      ;;
    *)
      FILTER="$1"
      shift
      ;;
  esac
done

# Find bats binary
BATS_CMD="${TESTS_DIR}/bats/bats-core/bin/bats"

if [[ ! -x "$BATS_CMD" ]]; then
  echo -e "${RED}ERROR: bats not found at $BATS_CMD${NC}"
  echo ""
  echo "Please initialize git submodules:"
  echo "  git submodule update --init --recursive"
  exit 1
fi

# Build bats options
BATS_OPTS=("--timing")

if $VERBOSE; then
  BATS_OPTS+=("--verbose-run")
fi

if [[ -n "$JOBS" ]]; then
  BATS_OPTS+=("--jobs" "$JOBS")
fi

# Collect test files
TEST_FILES=()

if [[ -n "$FILTER" ]]; then
  # Find matching test files
  for f in "${TESTS_DIR}/unit/"*"${FILTER}"*.bats; do
    [[ -f "$f" ]] && TEST_FILES+=("$f")
  done
else
  # Run all unit tests
  for f in "${TESTS_DIR}/unit/"*.bats; do
    [[ -f "$f" ]] && TEST_FILES+=("$f")
  done
fi

if [[ ${#TEST_FILES[@]} -eq 0 ]]; then
  echo -e "${RED}No test files found${NC}"
  if [[ -n "$FILTER" ]]; then
    echo "Filter: $FILTER"
  fi
  exit 1
fi

# Print header
echo -e "${CYAN}======================================${NC}"
echo -e "${CYAN}  Bats Test Runner${NC}"
echo -e "${CYAN}======================================${NC}"
echo ""
echo -e "${YELLOW}Running ${#TEST_FILES[@]} test file(s):${NC}"
for f in "${TEST_FILES[@]}"; do
  echo "  - $(basename "$f")"
done
echo ""

# Check for required tools
echo -e "${YELLOW}Tool availability:${NC}"
for tool in zoxide fzf fd jq; do
  if command -v "$tool" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} $tool"
  else
    echo -e "  ${YELLOW}○${NC} $tool (tests requiring this will be skipped)"
  fi
done
echo ""

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
echo ""

"$BATS_CMD" "${BATS_OPTS[@]}" "${TEST_FILES[@]}"
exit_code=$?

echo ""
if [[ $exit_code -eq 0 ]]; then
  echo -e "${GREEN}All tests passed!${NC}"
else
  echo -e "${RED}Some tests failed${NC}"
fi

exit $exit_code
