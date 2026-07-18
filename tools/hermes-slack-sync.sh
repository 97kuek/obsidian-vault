#!/bin/bash

set -u

VAULT="/Users/keitaro/Documents/obsidian-vault"
STATE_DIR="$VAULT/.agent-state"
LOG="$STATE_DIR/hermes-slack-sync.log"

mkdir -p "$STATE_DIR"
chmod 700 "$STATE_DIR"

{
  printf '[%s] sync start\n' "$(date '+%Y-%m-%d %H:%M:%S')"
  ruby "$VAULT/tools/sync-slack-history.rb"
  ruby "$VAULT/tools/capture-slack-message.rb" flush
  printf '[%s] sync complete\n' "$(date '+%Y-%m-%d %H:%M:%S')"
} >>"$LOG" 2>&1
