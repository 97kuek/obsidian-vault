## Codex Vault Guide

このファイルはCodex固有の入口である。全エージェント共通の規約は `docs/agents/README.md`、文書の案内図は `docs/README.md` にある。

## 作業開始時

1. `docs/agents/README.md` を読む。
2. `VAULT_INDEX.md` で対象ファイルを特定する。
3. 配置・命名は `docs/standards/vault-structure.md`、本文・frontmatterは `docs/standards/note-format.md` を確認する。
4. 定型作業は `docs/workflows/README.md` から該当手順を読む。
5. `git status --short` を確認し、既存の未コミット変更を保護する。
6. 編集する場合は `tools/agent-lock.sh acquire codex "作業内容"` でロックを取得する。

## Codexでの読み替え

スラッシュコマンドが使えない場合も、同名の自然言語依頼として `docs/workflows/` の手順を実行する。

| ユーザー依頼 | 手順 |
|---|---|
| `/inbox`、Inbox整理、ノート整理 | `docs/workflows/inbox.md` |
| `/vault-review`、週次レビュー、軽い点検 | `docs/workflows/vault-review.md` |
| `/vault-gc`、月次棚卸し、重複整理 | `docs/workflows/vault-gc.md` |
| `/paper`、論文メモ作成 | `docs/workflows/paper.md` |
| `/permanent`、永続ノート作成 | `docs/workflows/permanent.md` |
| `/publish`、公開候補・追加・停止・監査 | `docs/workflows/publish.md` |
| `/proofread`、文章添削 | `docs/workflows/proofread.md` |
| 今日のタスク、朝のタスク報告 | `docs/workflows/daily-task-report.md` |
| Slack収集、Hermesログ、Calendar連携 | `docs/integrations/slack-hermes.md` |

Claude Code専用のMCP表現は、通常のファイル操作へ読み替える。

| Claude Code/MCPの表現 | Codexでの読み替え |
|---|---|
| `get_vault_file` | 対象Markdownを直接読む |
| `create_vault_file` | ファイルを作成・更新する |
| `search_vault_simple` | `rg` でファイル名・本文を検索する |
| `search_vault_smart` | 関連語で検索し、必要なファイルを読んで判断する |
| `list_vault_files` | `rg --files` または対象フォルダの一覧を見る |

## Codex固有の注意

- `.obsidian/` は原則編集しない。例外は `.obsidian/snippets/vault-custom.css` のCSS編集のみである。
- `99_Templates/` はユーザーが明示した場合だけ編集する。
- ロックを取得できなければ編集しない。
- 完了時に差分・リンク・行数を検証し、`tools/agent-lock.sh release codex` でロックを解放する。
