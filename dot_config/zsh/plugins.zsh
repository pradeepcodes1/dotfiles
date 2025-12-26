# Plugin initialization
# Note: zsh-autosuggestions is configured in .zshrc before oh-my-zsh loads

# Initialize zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
# Initialize atuin
command -v atuin &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"

# Carapace configuration
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
if command -v carapace &>/dev/null; then
  source <(carapace _carapace zsh)
fi

# Standard Zsh matching rules - helps with prefix handling and fuzzy matching
# This allows fzf-tab to correctly identify path prefixes (like 'dir/') vs search queries
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# fzf-tab configuration
# Source fzf-tab from Nix profile
if [ -f "$HOME/.nix-profile/share/fzf-tab/fzf-tab.plugin.zsh" ]; then
  source "$HOME/.nix-profile/share/fzf-tab/fzf-tab.plugin.zsh"
elif [ -f "/nix/var/nix/profiles/default/share/fzf-tab/fzf-tab.plugin.zsh" ]; then
  source "/nix/var/nix/profiles/default/share/fzf-tab/fzf-tab.plugin.zsh"
fi

# Configure fzf-tab query-string to use only 'prefix' (fixes carapace subdirectory issue)
# Default is 'prefix input first', but 'input' causes 'folder/' to be used as search query
# With carapace, using only 'prefix' prevents the typed path from filtering results
zstyle ':fzf-tab:*' query-string prefix

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# Smart preview: only show for file/directory groups
zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ "$group" == *"files"* || "$group" == *"directories"* || "$group" == *"directory"* ]] && {
  local target=${realpath:-$word}
  target="${target% }"

  if [[ -d "$target" ]]; then
    eza -1 --icons --color=always "$target" 2>/dev/null
  elif [[ -f "$target" ]]; then
    if file --mime "$target" 2>/dev/null | grep -q "charset=binary"; then
      echo "📦 Binary file: $(file -b "$target")"
    else
      bat --paging=never --color=always --style=numbers "$target" 2>/dev/null
    fi
  fi
} || :'

# Hide preview window border when no content (threshold < 1 line)
# Set overall completion window size to 60% of screen height
zstyle ':fzf-tab:complete:*:*' fzf-flags --height=60% --preview-window=down:30%:wrap:border-top:~0

# switch group using < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

# zsh-autosuggestions configuration
if [ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]; then
  source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
elif [ -f "/nix/var/nix/profiles/default/share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh" ]; then
  source "/nix/var/nix/profiles/default/share/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
fi

# zsh-syntax-highlighting configuration (must be last)
if [ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [ -f "/nix/var/nix/profiles/default/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
  source "/nix/var/nix/profiles/default/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
