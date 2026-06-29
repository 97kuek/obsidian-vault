# Codex Vault Guide

このファイルは Codex がこの Obsidian vault で作業する際の入口である。
詳細な運用規約は `docs/vault-rules.md`、共通作業手順は `docs/agent-commands/` にある。Codex はまずこのファイルを読み、必要に応じて `VAULT_INDEX.md` と各詳細ドキュメントを参照する。

---

## 基本方針

- この vault は PARA メソッドで管理する研究・学習用ナレッジベースである。
- 人間は `00_Inbox/` に殴り書きするだけでよい。分類・整形・移動・命名・タグ・リンク更新は AI エージェントが提案し、承認後に実行する。
- ノート作成・整形は **だ・である調**、箇条書き中心、元情報を削らないことを既定とする。
- `.obsidian/` は原則編集しない。例外は `.obsidian/snippets/vault-custom.css` の CSS 編集のみ。
- `99_Templates/` はテンプレート置き場なので、ユーザーが明示した場合だけ編集する。
- 公開は `20_Areas/` が既定、`00_Inbox/`・`10_Projects/`・`30_Resources/`・`40_Archives/` は非公開が既定である。例外は `docs/agent-commands/publish.md` に従う。

---

## 作業開始時

1. `VAULT_INDEX.md` を読んで目的のファイルを特定する。
2. `docs/vault-rules.md` で命名規則・frontmatter・MOC・タグ規約を確認する。
3. 必要なファイルだけを読む。全探索は必要最小限にする。
4. 編集前に `git status --short` で作業ツリーを確認する。
5. 既存の未コミット変更はユーザーの変更として扱い、勝手に戻さない。

---

## Claude Code 手順の Codex での読み替え

この vault には `docs/agent-commands/` に共通手順がある。Codex ではスラッシュコマンドが使えない場合でも、同じ名前の自然言語依頼として扱い、該当ファイルの手順を読んで実行する。

| ユーザー依頼 | Codex が読む手順 |
|---|---|
| `/inbox`、Inbox整理、ノート整理 | `docs/agent-commands/inbox.md` |
| `/vault-review`、週次レビュー、軽い点検 | `docs/agent-commands/vault-review.md` |
| `/vault-gc`、月次棚卸し、重複整理 | `docs/agent-commands/vault-gc.md` |
| `/paper`、論文メモ作成 | `docs/agent-commands/paper.md` |
| `/permanent`、永続ノート作成 | `docs/agent-commands/permanent.md` |
| `/publish`、公開候補・公開追加・公開停止・公開監査 | `docs/agent-commands/publish.md` |

Claude Code 専用の MCP ツール名が出てきた場合、Codex では通常のファイル操作・検索に読み替える。

| Claude Code/MCP の表現 | Codex での読み替え |
|---|---|
| `get_vault_file` | 対象 Markdown を直接読む |
| `create_vault_file` | ファイルを作成・更新する |
| `search_vault_simple` | `rg` でファイル名・本文を検索する |
| `search_vault_smart` | 関連語で検索し、必要なファイルを読んで判断する |
| `list_vault_files` | `rg --files` または対象フォルダの一覧を見る |

---

## よくある作業

| 依頼 | 手順 |
|---|---|
| Inbox を整理して | `docs/agent-commands/inbox.md` を読んで、分類・整形・移動・命名・タグ・MOC/索引更新を提案または実行する |
| 新規ノート作成 | `docs/vault-rules.md` の命名規則・frontmatter 規約・テンプレートを確認して作る |
| MOC 更新 | 対象 MOC と関連ノートを読み、リンクを追加・整理する |
| 論文メモ作成 | `99_Templates/論文ノート用.md` の型に合わせ、`30_Resources/` に置く |
| 永続ノート作成 | 横断概念だけを `20_Areas/永続ノート/` に作り、`【MOC】永続ノート.md` を更新する |
| 公開ノート管理 | `docs/agent-commands/publish.md` を読み、候補とリスクを提示し、承認後に `publish: true` を付け外しする |

---

## 更新ルール

- ファイルを追加・削除・リネームしたら `VAULT_INDEX.md` を更新する。
- ルートの運用ドキュメントを変えたら、`README.md` と `VAULT_INDEX.md` の説明も必要に応じて同期する。
- 複数ファイルの作成・削除・リネームを行う大きな整理では、作業前スナップショットのコミットをユーザーに提案する。
- `.obsidian/` 直下を編集しない。必要なら `tools/protect-obsidian.ps1` で保護チェックする。
