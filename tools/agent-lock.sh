#!/bin/sh

set -eu

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
lock_dir="$root/.agent-lock"
owner_file="$lock_dir/owner"
command=${1:-status}

show_status() {
  if [ -f "$owner_file" ]; then
    printf '%s\n' "LOCKED"
    sed -n '1,20p' "$owner_file"
  else
    printf '%s\n' "UNLOCKED"
  fi
}

case "$command" in
  acquire)
    agent=${2:-}
    scope=${3:-unspecified}
    if [ -z "$agent" ]; then
      printf '%s\n' "Usage: tools/agent-lock.sh acquire <agent> [work]" >&2
      exit 64
    fi
    if mkdir "$lock_dir" 2>/dev/null; then
      umask 077
      {
        printf 'agent=%s\n' "$agent"
        printf 'work=%s\n' "$scope"
        printf 'started_at=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
        printf 'host=%s\n' "$(hostname)"
      } > "$owner_file"
      printf 'LOCK_ACQUIRED: %s\n' "$agent"
    else
      printf '%s\n' "LOCK_BUSY" >&2
      show_status >&2
      exit 2
    fi
    ;;
  status)
    show_status
    ;;
  release)
    agent=${2:-}
    if [ ! -f "$owner_file" ]; then
      printf '%s\n' "UNLOCKED"
      exit 0
    fi
    current=$(sed -n 's/^agent=//p' "$owner_file")
    if [ -z "$agent" ] || [ "$agent" != "$current" ]; then
      printf 'LOCK_OWNED_BY: %s\n' "$current" >&2
      exit 3
    fi
    rm "$owner_file"
    rmdir "$lock_dir"
    printf 'LOCK_RELEASED: %s\n' "$agent"
    ;;
  *)
    printf '%s\n' "Usage: tools/agent-lock.sh {acquire <agent> [work]|status|release <agent>}" >&2
    exit 64
    ;;
esac
