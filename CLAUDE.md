## Claude Code Vault Guide

このファイルはClaude Code固有の入口である。全エージェント共通の規約は `docs/agents/README.md`、文書の案内図は `docs/README.md` にある。

## 作業開始時

1. `docs/agents/README.md` を読む。
2. `VAULT_INDEX.md` で対象ファイルを特定する。
3. 配置・命名は `docs/standards/vault-structure.md`、本文・frontmatterは `docs/standards/note-format.md` を確認する。
4. 定型作業は `docs/workflows/README.md` から該当手順を読む。
5. `git status --short` を確認し、既存の未コミット変更を保護する。
6. 編集する場合は `tools/agent-lock.sh acquire claude "作業内容"` でロックを取得する。

## Claude Code固有の規約

- `.claude/commands/*.md` は `docs/workflows/` にある共通手順への薄い入口とする。
- MCPツールが使える場合も、最終的な配置・形式は `docs/standards/` の正本に従う。
- 重い探索だけをサブエージェントへ任せ、通常の検索は `rg` またはMCP検索を使う。
- `.claude/settings.json` のhookは `.obsidian/` 直下の編集保護に使う。

## 補助ツール

| 用途 | 優先手段 |
|---|---|
| ファイル名・本文検索 | `rg` またはMCP検索 |
| 切れリンク・命名・索引点検 | `tools/vault-review.rb` |
| 棚卸し候補抽出 | `tools/vault-gc.rb` |
| `.obsidian/` 保護確認 | `tools/protect-obsidian.sh` |

## 作業終了時

- 差分、リンク、対象文書の行数を確認する。
- ファイルを追加・削除・リネームした場合は `VAULT_INDEX.md` またはリンク先の詳細索引を更新する。
- `tools/agent-lock.sh release claude` でロックを解放する。
