## Agent Guide

このファイルは全AIエージェント共通の作業入口である。Claude Code固有の差分は `CLAUDE.md`、役割分担・編集ロック・Hermesの自動化境界は `docs/agents/coordination.md`、文書の案内図は `docs/README.md` にある。

## 作業開始時

1. `VAULT_INDEX.md` で対象領域と正本を特定する。
2. 配置・命名は `docs/standards/vault-structure.md`、本文・frontmatterは `docs/standards/note-format.md` を読む。
3. 定型作業は `docs/workflows/README.md` から該当手順を選ぶ。スラッシュコマンドが使えないエージェントも、同名の自然言語依頼として同じ手順を実行する。
4. 外部連携や公開処理は `docs/integrations/`、`docs/operations/` の該当文書を読む。
5. `git status --short` を確認し、既存の未コミット変更を保護する。
6. 編集する場合は `tools/agent-lock.sh acquire <エージェント名> "作業内容"` でロックを取得する。

## 共通作業規約

- ノートは、だ・である調、箇条書き中心とし、元情報を削らない。
- 必要な対象ファイルだけを読み、探索は `rg` または `rg --files` で絞る。
- 既存の未コミット変更はユーザーまたは別作業の変更として保護する。
- 読み取り以外では `docs/agents/coordination.md` に従い、編集前にロックを取得する。
- 移動・削除・統合・公開設定の変更は、各ワークフローが定める承認境界に従う。
- `.obsidian/` は原則編集せず、例外は `.obsidian/snippets/vault-custom.css` のみとする。
- `99_Templates/` はユーザーが明示した場合だけ編集する。
- ファイルを追加・削除・リネームしたら、関連リンクと `VAULT_INDEX.md` またはリンク先の詳細索引を更新する。
- 複数ファイルを大きく整理する場合は、作業前スナップショットを提案する。
- 作業完了時に差分とリンクを検証し、取得したロックを解放する。

## MCPが使えない場合の読み替え

Obsidian MCPツールが使えないエージェントは、通常のファイル操作へ読み替える。

| MCPの表現 | 読み替え |
|---|---|
| `get_vault_file` | 対象Markdownを直接読む |
| `create_vault_file` | ファイルを作成・更新する |
| `search_vault_simple` | `rg` でファイル名・本文を検索する |
| `search_vault_smart` | 関連語で検索し、必要なファイルを読んで判断する |
| `list_vault_files` | `rg --files` または対象フォルダの一覧を見る |

## 補助ツール

| 用途 | 優先手段 |
|---|---|
| ファイル名・本文検索 | `rg` またはMCP検索 |
| 切れリンク・命名・索引点検 | `tools/vault-review.rb` |
| 棚卸し候補抽出 | `tools/vault-gc.rb` |
| `.obsidian/` 保護確認 | `tools/protect-obsidian.sh` |

## ドキュメント命名規則

- ディレクトリ名は役割を表す複数形の英単語とする。
- 規約・仕様のファイル名は内容を表す英語の名詞句をkebab-caseで記述する。
- `docs/workflows/` のファイル名は、呼び出し名と一致するkebab-caseのIDとする。
- `README.md`、`AGENTS.md`、`CLAUDE.md` はツールや配置上の固定名として例外扱いにする。
- AIエージェント向けMarkdownは1ファイル200行以下とし、超える場合は責務で分割する。
- 同じ規則を複製せず、入口文書には要約と正本へのリンクだけを置く。

## 作業終了時

- 差分、リンク、対象文書の行数を確認する。
- ファイルを追加・削除・リネームした場合は `VAULT_INDEX.md` またはリンク先の詳細索引を更新する。
- `tools/agent-lock.sh release <エージェント名>` でロックを解放する。
