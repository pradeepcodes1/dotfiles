# zsh-autosuggestions (Nix)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"
ZSH_AUTOSUGGESTIONS_DIR="$(dirname "$(readlink -f "$(command -v zsh-autosuggestions 2>/dev/null)")")"

if [ -f "$ZSH_AUTOSUGGESTIONS_DIR/../share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
  source "$ZSH_AUTOSUGGESTIONS_DIR/../share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"
export PATH="$HOME/go/bin":$PATH
