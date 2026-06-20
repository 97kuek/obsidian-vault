# Obsidian Vault Guide

Claude Code がこの vault で作業する際の入口である。Codex は `AGENTS.md` を入口にする。共通の詳細規約は `docs/vault-rules.md`、共通コマンド手順は `docs/agent-commands/` にある。

---

## 最初に読む

1. `VAULT_INDEX.md` で目的のファイルを特定する。
2. `docs/vault-rules.md` で命名規則・frontmatter・MOC・タグ規約を確認する。
3. `/inbox` などの作業では `docs/agent-commands/<command>.md` を読む。
4. 編集前に `git status` を確認し、既存の未コミット変更は勝手に戻さない。

---

## 大方針

- 人間は `00_Inbox/` に殴り書きするだけでよい。
- AI エージェントは分類・整形・移動・命名・タグ・リンク/MOC/索引更新を提案し、承認後に実行する。
- ノートは、だ・である調、箇条書き中心、元情報を削らないことを既定とする。
- 破壊的操作や複数ファイルの作成・削除・リネーム前には作業前コミットを提案する。

---

## よくある依頼

| 依頼 | 読む手順 |
|---|---|
| `/inbox`、Inbox整理 | `docs/agent-commands/inbox.md` |
| `/vault-review`、週次点検 | `docs/agent-commands/vault-review.md` |
| `/vault-gc`、棚卸し | `docs/agent-commands/vault-gc.md` |
| `/paper`、論文メモ | `docs/agent-commands/paper.md` |
| `/permanent`、永続ノート | `docs/agent-commands/permanent.md` |

---

## Claude Code 固有メモ

- `.claude/commands/*.md` は共通手順への薄い入口である。
- `vault-explorer` サブエージェントは重い探索だけに使う。
- MCP ツールが使える場合でも、最終的な編集規約は `docs/vault-rules.md` に従う。
- `.claude/settings.json` の hook は `.obsidian/` 直下編集を保護する。

---

## ツール対応

| 用途 | 優先手段 |
|---|---|
| ファイル名・本文検索 | `rg` または MCP 検索 |
| 切れリンク・命名・索引点検 | `tools/vault-review.ps1` |
| 棚卸し候補抽出 | `tools/vault-gc.ps1` |
| `.obsidian/` 保護確認 | `tools/protect-obsidian.ps1` |

---

## 更新ルール

- ファイルを追加・削除・リネームしたら `VAULT_INDEX.md` を更新する。
- ルートの運用ドキュメントを変えたら `README.md`、`AGENTS.md`、`CLAUDE.md`、`VAULT_INDEX.md` の整合を確認する。
- センシティブ情報が必要になったら `99_Private/` を作り、`.gitignore` とこの入口に追記する。

