#!/bin/bash

set -u

VAULT="/Users/keitaro/Documents/obsidian-vault"
STATE_DIR="$VAULT/.agent-state"
LOG="$STATE_DIR/hermes-slack-sync.log"

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

status=0

{
  printf '[%s] sync start\n' "$(date '+%Y-%m-%d %H:%M:%S')"

  ruby "$VAULT/tools/sync-slack-history.rb" || status=$?

  flush_status=0
  ruby "$VAULT/tools/capture-slack-message.rb" flush || flush_status=$?
  if [ "$status" -eq 0 ] && [ "$flush_status" -ne 0 ]; then
    status=$flush_status
  fi

  if [ "$status" -eq 0 ]; then
    printf '[%s] sync complete\n' "$(date '+%Y-%m-%d %H:%M:%S')"
  else
    printf '[%s] sync failed (exit=%s); next run will retry from saved Slack timestamp\n' \
      "$(date '+%Y-%m-%d %H:%M:%S')" "$status"
  fi
} >>"$LOG" 2>&1

exit "$status"
