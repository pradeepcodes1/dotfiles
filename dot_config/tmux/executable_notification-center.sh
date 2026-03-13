#!/bin/bash
# Notification center — shows windows with unread bells via display-menu

bell_windows=$(tmux list-windows -a -f '#{window_bell_flag}' -F '#{session_name}:#{window_index}')

if [ -z "$bell_windows" ]; then
  tmux display-message "No notifications"
  exit 0
fi

args=(-T "Notifications (bells)")
i=1
while IFS= read -r target; do
  if [ $i -le 9 ]; then
    shortcut="$i"
  else
    shortcut=""
  fi
  # Show pane title if it's not a default/hostname
  win_label=""
  title=$(tmux display-message -t "$target" -p '#{pane_title}')
  case "$title" in
    zsh | bash | fish | "" | *.[Ll]ocal | *-[Mm]ac[Bb]ook*) ;;
    *) win_label=" $title" ;;
  esac
  args+=("${shortcut}  ${target}${win_label}" "$shortcut" "switch-client -t '${target}'")
  i=$((i + 1))
done <<<"$bell_windows"

tmux display-menu "${args[@]}"
