# Zsh prompt theme integration

zstyle ':vcs_info:git:*' unstagedstr "%F{$prompt_unstaged}*%f"
zstyle ':vcs_info:git:*' stagedstr "%F{$prompt_staged}+%f"
zstyle ':vcs_info:git:*' formats " %F{$prompt_branch}(%b%u%c)%f"
zstyle ':vcs_info:git:*' actionformats " %F{$prompt_branch}(%b|%a%u%c)%f"

PROMPT="%F{$prompt_dir}%1~%f\${vcs_info_msg_0_} %F{$prompt_arrow}❯%f "
RPROMPT="%F{$prompt_path}%~%f"
