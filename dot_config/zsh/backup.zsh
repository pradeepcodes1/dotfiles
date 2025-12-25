# Function to run system backups using restic and pass
function backup-system() {
  # Check dependencies
  if ! command -v restic >/dev/null; then
    echo "❌ restic not found in PATH"
    return 1
  fi
  if ! command -v pass >/dev/null; then
    echo "❌ pass not found in PATH"
    return 1
  fi

  echo "🔑 Fetching configuration from pass..."

  # Fetch configuration from pass
  export RESTIC_REPOSITORY="$(pass backups/restic-repo)"
  local obsidian_path="$(pass backups/obsidian)"
  local yamtrack_path="$(pass backups/yamtrack-db)"

  local sources=($obsidian_path $yamtrack_path)

  # Check if repo is initialized
  if ! restic snapshots --insecure-no-password >/dev/null 2>&1; then
    echo "✨ Initializing restic repository..."
    if ! restic init --insecure-no-password; then
      echo "❌ Failed to initialize repository."
      return 1
    fi
  fi

  echo "===== Backup started at $(date) ====="
  echo "Sources: ${sources[*]}"

  for src in "${sources[@]}"; do
    if [[ ! -e "$src" ]]; then
      echo "⚠️  Source does not exist: $src"
      # We don't return here to allow partial backups if one source is missing,
      # but you can change this to 'return 1' if you want strict failure.
    fi
  done

  # Backup
  echo "🚀 Running restic backup..."
  restic backup "${sources[@]}" \
    --insecure-no-password \
    --exclude ".DS_Store" \
    --exclude ".Spotlight-V100" \
    --exclude ".Trashes"

  # Retention
  echo "🧹 Applying retention policy..."
  restic forget \
    --insecure-no-password \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 \
    --prune

  # Check
  echo "🔍 Running restic check..."
  restic check --insecure-no-password

  echo "===== Backup finished at $(date) ====="
}
