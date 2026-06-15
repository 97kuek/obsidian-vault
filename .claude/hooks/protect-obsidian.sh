#!/usr/bin/env bash
# PreToolUse(Write|Edit|MultiEdit) guard.
# Block edits under .obsidian/ — except .obsidian/snippets/vault-custom.css —
# per the CLAUDE.md rule "do not touch .obsidian/ (breaks Obsidian)".
# Only the tool_input.file_path is inspected (note CONTENT mentioning
# ".obsidian" must NOT trigger a block), so editing CLAUDE.md/README stays fine.

input=$(cat)

# Extract the first "file_path":"..." value (paths never contain a literal ").
fp=$(printf '%s' "$input" \
  | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
  | head -1 \
  | sed -E 's/.*:"//; s/"$//')

# Normalize Windows / JSON-escaped backslashes to forward slashes.
fp=$(printf '%s' "$fp" | sed 's#\\\\#/#g; s#\\#/#g')

case "$fp" in
  */.obsidian/snippets/vault-custom.css)
    exit 0 ;;
  */.obsidian/*|.obsidian/*)
    printf '%s\n' "Blocked: .obsidian/ は Obsidian 設定のため保護されています（CLAUDE.md）。編集してよいのは .obsidian/snippets/vault-custom.css のみです。" >&2
    exit 2 ;;
  *)
    exit 0 ;;
esac
