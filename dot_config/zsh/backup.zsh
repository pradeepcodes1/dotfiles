# Function to run system backups using restic and pass
function backup-system() {
  # Check dependencies
  if ! command -v restic >/dev/null; then
    error_log "backup" "restic not found in PATH"
    return 1
  fi
  if ! command -v pass >/dev/null; then
    error_log "backup" "pass not found in PATH"
    return 1
  fi

  info_log "backup" "Fetching configuration from pass..."

  # Fetch configuration from pass
  export RESTIC_REPOSITORY="$(pass backups/restic-repo)"
  local obsidian_path="$(pass backups/obsidian)"
  local yamtrack_path="$(pass backups/yamtrack-db)"

  local sources=($obsidian_path $yamtrack_path)

  # Check if repo is initialized
  if ! restic snapshots --insecure-no-password >/dev/null 2>&1; then
    info_log "backup" "Initializing restic repository..."
    if ! restic init --insecure-no-password; then
      error_log "backup" "Failed to initialize repository."
      return 1
    fi
  fi

  info_log "backup" "Backup started at $(date)"
  info_log "backup" "Sources: ${sources[*]}"

  for src in "${sources[@]}"; do
    if [[ ! -e "$src" ]]; then
      warn_log "backup" "Source does not exist: $src"
      # We don't return here to allow partial backups if one source is missing,
      # but you can change this to 'return 1' if you want strict failure.
    fi
  done

  # Backup
  info_log "backup" "Running restic backup..."
  restic backup "${sources[@]}" \
    --insecure-no-password \
    --exclude ".DS_Store" \
    --exclude ".Spotlight-V100" \
    --exclude ".Trashes"

  # Retention
  info_log "backup" "Applying retention policy..."
  restic forget \
    --insecure-no-password \
    --keep-daily 7 \
    --keep-weekly 4 \
    --keep-monthly 6 \
    --prune

  # Check
  info_log "backup" "Running restic check..."
  restic check --insecure-no-password

  info_log "backup" "Backup finished at $(date)"
}
