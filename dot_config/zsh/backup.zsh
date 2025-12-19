restic_backup() {
  export RESTIC_REPOSITORY="$RESTIC_REPO"

  if (( $# == 0 )); then
    echo "Usage: restic_backup <path> [path ...]"
    return 2
  fi

  local SOURCES=("$@")

 echo "===== Backup started at $(date) ====="
 echo "Sources: ${SOURCES[*]}"

 for src in "${SOURCES[@]}"; do
   if [[ ! -e "$src" ]]; then
     echo "ERROR: Source does not exist: $src"
     return 1
   fi
 done

 if [[ ! -d "$RESTIC_REPO" ]]; then
   echo "Initializing restic repository..."
   restic init --insecure-no-password
 fi

 # ---- BACKUP ----
 echo "Running restic backup..."
 restic backup "${SOURCES[@]}" \
 --insecure-no-password \
   --exclude ".DS_Store" \
   --exclude ".Spotlight-V100" \
   --exclude ".Trashes"

 # ---- RETENTION ----
 echo "Applying retention policy..."
 restic forget \
     --insecure-no-password \
   --keep-daily 7 \
   --keep-weekly 4 \
   --keep-monthly 6 \
   --prune

 # ---- CHECK ----
 echo "Running restic check..."
 restic check --insecure-no-password

 echo "===== Backup finished at $(date) ====="
}
