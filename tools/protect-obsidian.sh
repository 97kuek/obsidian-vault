#!/bin/sh

set -eu

root=$(git rev-parse --show-toplevel)
cd "$root"

violations=$(git status --short -- .obsidian ':!.obsidian/snippets/vault-custom.css' || true)
if [ -n "$violations" ]; then
  printf '%s\n' "OBSIDIAN_PROTECTION_FAILED" >&2
  printf '%s\n' "$violations" >&2
  exit 1
fi

printf '%s\n' "OBSIDIAN_PROTECTION_OK"
