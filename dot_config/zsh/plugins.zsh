# Plugin initialization
# Note: zsh-autosuggestions is configured in .zshrc before oh-my-zsh loads

# Initialize zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
# Initialize atuin
command -v atuin &>/dev/null && eval "$(atuin init zsh)"
export PATH="$HOME/go/bin":$PATH

# Carapace configuration
export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
command -v carapace &>/dev/null && source <(carapace _carapace)

# fzf-tab configuration
# Source fzf-tab from Nix profile
if [ -f "$HOME/.nix-profile/share/fzf-tab/fzf-tab.plugin.zsh" ]; then
  source "$HOME/.nix-profile/share/fzf-tab/fzf-tab.plugin.zsh"
elif [ -f "/nix/var/nix/profiles/default/share/fzf-tab/fzf-tab.plugin.zsh" ]; then
  source "/nix/var/nix/profiles/default/share/fzf-tab/fzf-tab.plugin.zsh"
fi

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using < and >
zstyle ':fzf-tab:*' switch-group '<' '>'