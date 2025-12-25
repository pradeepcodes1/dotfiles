#!/bin/bash
set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
assert_equals() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local expected="$1"
    local actual="$2"
    local message="$3"

    if [[ "$expected" == "$actual" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  Expected: $expected"
        echo -e "  Got: $actual"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_file_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local file="$1"
    local message="$2"

    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  File not found: $file"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_dir_exists() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local dir="$1"
    local message="$2"

    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  Directory not found: $dir"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

assert_contains() {
    TESTS_RUN=$((TESTS_RUN + 1))
    local haystack="$1"
    local needle="$2"
    local message="$3"

    if [[ "$haystack" == *"$needle"* ]]; then
        echo -e "${GREEN}✓${NC} $message"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗${NC} $message"
        echo -e "  Expected to contain: $needle"
        echo -e "  In: $haystack"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Setup test environment
TEMP_DIR=$(mktemp -d)
export NIX_PROFILES_FILE="${TEMP_DIR}/.config/nix-profiles.json"
export NIX_HOMES_DIR="${TEMP_DIR}/.nix-homes"
export FLAKES_DIR="${TEMP_DIR}/nix"

echo -e "${YELLOW}=== Flake Function Test Suite ===${NC}"
echo "Test directory: $TEMP_DIR"
echo ""

# Source the nix.zsh file to load functions
if [[ -f "$HOME/.config/zsh/nix.zsh" ]]; then
    source "$HOME/.config/zsh/nix.zsh"
else
    echo -e "${RED}ERROR: nix.zsh not found at $HOME/.config/zsh/nix.zsh${NC}"
    echo "Make sure bootstrap.sh has been run first"
    exit 1
fi

# Test 1: _nix_ensure_profiles creates profiles file
echo -e "${YELLOW}Test: Profile file initialization${NC}"
_nix_ensure_profiles
assert_file_exists "$NIX_PROFILES_FILE" "Profile file should be created"
assert_equals "[]" "$(cat "$NIX_PROFILES_FILE")" "Profile file should contain empty JSON array"
echo ""

# Test 2: _nix_add_profile adds a profile
echo -e "${YELLOW}Test: Adding a profile${NC}"
_nix_add_profile "${NIX_HOMES_DIR}/test-home" "test-profile" "basic" "dev"
profiles_content=$(cat "$NIX_PROFILES_FILE")
assert_contains "$profiles_content" "test-profile" "Profile name should be in JSON"
assert_contains "$profiles_content" "test-home" "Home path should be in JSON"
assert_contains "$profiles_content" "basic" "First flake should be in JSON"
assert_contains "$profiles_content" "dev" "Second flake should be in JSON"
echo ""

# Test 3: _nix_list_flakes lists available flakes
echo -e "${YELLOW}Test: Listing flakes${NC}"
mkdir -p "$FLAKES_DIR/test-flake-1"
mkdir -p "$FLAKES_DIR/test-flake-2"
mkdir -p "$FLAKES_DIR/not-a-flake"
touch "$FLAKES_DIR/test-flake-1/flake.nix"
touch "$FLAKES_DIR/test-flake-2/flake.nix"

flakes_list=$(_nix_list_flakes)
assert_contains "$flakes_list" "test-flake-1" "Should list first flake"
assert_contains "$flakes_list" "test-flake-2" "Should list second flake"

if [[ "$flakes_list" == *"not-a-flake"* ]]; then
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗${NC} Should not list directory without flake.nix"
else
    TESTS_RUN=$((TESTS_RUN + 1))
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓${NC} Should not list directory without flake.nix"
fi
echo ""

# Test 4: _nix_setup_home creates symlinks
echo -e "${YELLOW}Test: Home directory setup${NC}"
TEST_HOME="${TEMP_DIR}/test-setup-home"
REAL_HOME="${TEMP_DIR}/real-home"
mkdir -p "$TEST_HOME"
mkdir -p "$REAL_HOME/.config"
touch "$REAL_HOME/.zshrc"

# Mock NIX_CONFIG_SYMLINKS with minimal set for testing
NIX_CONFIG_SYMLINKS=(".config" ".zshrc")

_nix_setup_home "$TEST_HOME" "$REAL_HOME"
setup_result=$?

assert_equals "0" "$setup_result" "Setup should return 0 on first run"
assert_file_exists "$TEST_HOME/.zshrc" "Should create .zshrc symlink"
assert_dir_exists "$TEST_HOME/.config" "Should create .config symlink"

# Run setup again on non-empty home (use || true to prevent set -e from exiting)
_nix_setup_home "$TEST_HOME" "$REAL_HOME" || setup_result_2=$?
setup_result_2=${setup_result_2:-0}
assert_equals "1" "$setup_result_2" "Setup should return 1 when home is not empty"
echo ""

# Test 5: Profile JSON structure
echo -e "${YELLOW}Test: Profile JSON structure validation${NC}"
if command -v jq &>/dev/null; then
    # Validate JSON structure
    profile_count=$(jq 'length' "$NIX_PROFILES_FILE")
    assert_equals "1" "$profile_count" "Should have one profile"

    profile_name=$(jq -r '.[0].name' "$NIX_PROFILES_FILE")
    assert_equals "test-profile" "$profile_name" "Profile name should match"

    flakes_count=$(jq '.[0].flakes | length' "$NIX_PROFILES_FILE")
    assert_equals "2" "$flakes_count" "Should have two flakes"

    first_flake=$(jq -r '.[0].flakes[0]' "$NIX_PROFILES_FILE")
    assert_equals "basic" "$first_flake" "First flake should be 'basic'"
else
    echo -e "${YELLOW}⊘${NC} Skipping JSON validation tests (jq not installed)"
fi
echo ""

# Cleanup
rm -rf "$TEMP_DIR"

# Summary
echo -e "${YELLOW}=== Test Summary ===${NC}"
echo "Tests run: $TESTS_RUN"
echo -e "Tests passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -gt 0 ]]; then
    echo -e "${RED}FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}SUCCESS${NC}"
    exit 0
fi
