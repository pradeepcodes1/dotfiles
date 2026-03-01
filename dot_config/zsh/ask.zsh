# Ask Claude a question and render the markdown output with glow
ask() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: ask <question without quotes>"
    return 1
  fi
  claude -p "$*" | glow
}
