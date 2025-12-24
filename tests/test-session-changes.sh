#!/usr/bin/env bash
# Test cases for session changes
# Tests all modifications made during the improvement session

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHEZMOI_DIR="$(dirname "$SCRIPT_DIR")"

echo "🧪 Testing session changes..."
echo "Working directory: $CHEZMOI_DIR"
echo

FAILED=0
PASSED=0

# Helper functions
pass() {
    echo "✅ PASS: $1"
    ((PASSED++))
}

fail() {
    echo "❌ FAIL: $1"
    ((FAILED++))
}

test_file_exists() {
    if [[ -f "$1" ]]; then
        pass "File exists: $1"
    else
        fail "File missing: $1"
    fi
}

test_file_contains() {
    if grep -q "$2" "$1" 2>/dev/null; then
        pass "File $1 contains: $2"
    else
        fail "File $1 missing content: $2"
    fi
}

test_not_contains() {
    if ! grep -q "$2" "$1" 2>/dev/null; then
        pass "File $1 correctly doesn't contain: $2"
    else
        fail "File $1 should not contain: $2"
    fi
}

echo "📋 Test 1: Eza aliases (Task #7)"
echo "================================"
test_file_exists "$CHEZMOI_DIR/dot_config/zsh/basics.zsh.tmpl"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/basics.zsh.tmpl" "alias ls='eza --icons'"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/basics.zsh.tmpl" "alias ll='eza --icons -l'"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/basics.zsh.tmpl" "alias la='eza --icons -la'"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/basics.zsh.tmpl" "alias lt='eza --icons --tree'"
test_file_contains "$CHEZMOI_DIR/nix/basic/flake.nix" "eza"
echo

echo "📋 Test 2: Removed debug print (Task #2)"
echo "========================================"
test_file_exists "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua"
test_not_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua" 'print("TESTING:'
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua" "vim.notify"
echo

echo "📋 Test 3: Zsh autosuggestions styling (Task #10)"
echo "================================================="
test_file_exists "$CHEZMOI_DIR/dot_config/zsh/plugins.zsh"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/plugins.zsh" 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"'
echo

echo "📋 Test 4: LSP servers (Task #12)"
echo "================================="
test_file_exists "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua" "pyright"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua" "jsonls"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua" "yamlls"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua" "marksman"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/masonlsp.lua" "tailwindcss"
echo

echo "📋 Test 5: Formatters (Task #13)"
echo "================================"
test_file_exists "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/conform.lua"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/conform.lua" 'go = { "gofmt" }'
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/conform.lua" 'rust = { "rustfmt" }'
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/conform.lua" 'json = { "prettier" }'
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/conform.lua" 'yaml = { "prettier" }'
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/conform.lua" 'markdown = { "prettier" }'
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/conform.lua" 'toml = { "taplo" }'
echo

echo "📋 Test 6: Git config (Task #11)"
echo "================================"
test_file_exists "$CHEZMOI_DIR/dot_gitconfig.tmpl"
test_file_contains "$CHEZMOI_DIR/dot_gitconfig.tmpl" "pager = delta"
test_file_contains "$CHEZMOI_DIR/dot_gitconfig.tmpl" "excludesfile = ~/.gitignore_global"
test_file_contains "$CHEZMOI_DIR/dot_gitconfig.tmpl" "[delta]"
test_file_contains "$CHEZMOI_DIR/dot_gitconfig.tmpl" "side-by-side = true"
test_file_contains "$CHEZMOI_DIR/dot_gitconfig.tmpl" "[alias]"
test_file_contains "$CHEZMOI_DIR/dot_gitconfig.tmpl" "st = status"
echo

echo "📋 Test 7: Keybindings documentation (Task #20)"
echo "==============================================="
test_file_exists "$CHEZMOI_DIR/KEYBINDINGS.md"
test_file_contains "$CHEZMOI_DIR/KEYBINDINGS.md" "Neovim"
test_file_contains "$CHEZMOI_DIR/KEYBINDINGS.md" "Tmux"
test_file_contains "$CHEZMOI_DIR/KEYBINDINGS.md" "Aerospace"
test_file_contains "$CHEZMOI_DIR/KEYBINDINGS.md" "<leader>ff"
test_file_contains "$CHEZMOI_DIR/KEYBINDINGS.md" "ROpt+"
echo

echo "📋 Test 8: Todo-comments plugin (Task #21)"
echo "=========================================="
test_file_exists "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/todo-comments.lua"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/todo-comments.lua" "folke/todo-comments.nvim"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/todo-comments.lua" "TodoTelescope"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/todo-comments.lua" "FIX"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/todo-comments.lua" "TODO"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/todo-comments.lua" "HACK"
echo

echo "📋 Test 9: Global gitignore (Task #23)"
echo "======================================"
test_file_exists "$CHEZMOI_DIR/dot_gitignore_global"
test_file_contains "$CHEZMOI_DIR/dot_gitignore_global" ".DS_Store"
test_file_contains "$CHEZMOI_DIR/dot_gitignore_global" "node_modules/"
test_file_contains "$CHEZMOI_DIR/dot_gitignore_global" ".idea/"
test_file_contains "$CHEZMOI_DIR/dot_gitignore_global" ".vscode/"
test_file_contains "$CHEZMOI_DIR/dot_gitignore_global" "*.pyc"
test_file_contains "$CHEZMOI_DIR/dot_gitignore_global" ".env"
echo

echo "📋 Test 10: Navigation helpers (Task #24)"
echo "========================================="
test_file_exists "$CHEZMOI_DIR/dot_config/zsh/navigation.zsh"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/navigation.zsh" "function cd()"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/navigation.zsh" "function zi()"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/navigation.zsh" "function mkcd()"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/navigation.zsh" "function up()"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/navigation.zsh" "function bd()"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/navigation.zsh" "function fcd()"
echo

echo "📋 Test 11: Yazi flavor warning fix (Task #34)"
echo "=============================================="
test_file_exists "$CHEZMOI_DIR/dot_config/zsh/theme.zsh"
test_file_contains "$CHEZMOI_DIR/dot_config/zsh/theme.zsh" "warn_log \"theme\" \"Yazi flavor"
test_not_contains "$CHEZMOI_DIR/dot_config/zsh/theme.zsh" "echo \"Note: yazi flavor"
echo

echo "📋 Test 12: Telescope ignore patterns (Task #35)"
echo "================================================"
test_file_exists "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/init.lua"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/init.lua" "file_ignore_patterns"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/init.lua" "node_modules/"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/init.lua" "%.log"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/init.lua" "__pycache__/"
test_file_contains "$CHEZMOI_DIR/dot_config/nvim/lua/plugins/init.lua" "coverage/"
echo

echo "📋 Test 13: Yazi keybindings doc (Task #68)"
echo "==========================================="
test_file_exists "$CHEZMOI_DIR/dot_config/yazi/KEYBINDINGS.md"
test_file_contains "$CHEZMOI_DIR/dot_config/yazi/KEYBINDINGS.md" "Navigation"
test_file_contains "$CHEZMOI_DIR/dot_config/yazi/KEYBINDINGS.md" "File Operations"
test_file_contains "$CHEZMOI_DIR/dot_config/yazi/KEYBINDINGS.md" "Selection"
test_file_contains "$CHEZMOI_DIR/dot_config/yazi/KEYBINDINGS.md" "Tabs"
echo

echo "📋 Test 14: Alacritty removal (Task #73)"
echo "========================================"
test_file_exists "$CHEZMOI_DIR/dot_config/zsh/theme.zsh"
test_not_contains "$CHEZMOI_DIR/dot_config/zsh/theme.zsh" "_update_alacritty_theme"
test_not_contains "$CHEZMOI_DIR/dot_config/zsh/theme.zsh" "alacritty.toml"
echo

echo "📋 Test 15: File syntax validation"
echo "==================================="
# Check Lua syntax
if command -v lua &>/dev/null; then
    for file in "$CHEZMOI_DIR"/dot_config/nvim/lua/plugins/*.lua; do
        if lua -e "dofile('$file')" 2>/dev/null; then
            pass "Valid Lua syntax: $(basename "$file")"
        else
            fail "Invalid Lua syntax: $(basename "$file")"
        fi
    done
else
    echo "⚠️  Skipping Lua syntax checks (lua not found)"
fi

# Check shell syntax
for file in "$CHEZMOI_DIR"/dot_config/zsh/*.zsh "$CHEZMOI_DIR"/dot_config/zsh/*.zsh.tmpl; do
    if [[ -f "$file" ]]; then
        if zsh -n "$file" 2>/dev/null; then
            pass "Valid zsh syntax: $(basename "$file")"
        else
            fail "Invalid zsh syntax: $(basename "$file")"
        fi
    fi
done
echo

echo "📋 Test 16: Markdown formatting"
echo "==============================="
for md in "$CHEZMOI_DIR"/*.md "$CHEZMOI_DIR"/dot_config/yazi/*.md; do
    if [[ -f "$md" ]]; then
        # Check for proper headers
        if grep -q "^# " "$md"; then
            pass "Has proper headers: $(basename "$md")"
        else
            fail "Missing headers: $(basename "$md")"
        fi

        # Check for proper table formatting
        if grep -q "|" "$md"; then
            pass "Has tables: $(basename "$md")"
        fi
    fi
done
echo

echo "📊 Test Summary"
echo "==============="
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo

if [[ $FAILED -eq 0 ]]; then
    echo "🎉 All tests passed!"
    exit 0
else
    echo "💥 Some tests failed!"
    exit 1
fi
