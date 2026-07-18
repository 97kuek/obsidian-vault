## Agent Guide

このファイルは、Codex、Claude Code、Hermes Agentに共通する作業入口である。各製品固有の入口は、ルートの `AGENTS.md`、`CLAUDE.md`、`HERMES.md` とする。

## 読む順序

1. `VAULT_INDEX.md` で対象領域と正本を特定する。
2. 配置・命名は `docs/standards/vault-structure.md`、本文・frontmatterは `docs/standards/note-format.md` を読む。
3. 定型作業は `docs/workflows/README.md` から該当手順を選ぶ。
4. 外部連携や公開処理は `docs/integrations/`、`docs/operations/` の該当文書を読む。
5. 必要な対象ファイルだけを読み、探索は `rg` または `rg --files` で絞る。

## 共通作業規約

- ノートは、だ・である調、箇条書き中心とし、元情報を削らない。
- 既存の未コミット変更はユーザーまたは別作業の変更として保護する。
- 読み取り以外では `docs/agents/coordination.md` に従い、編集前にロックを取得する。
- 移動・削除・統合・公開設定の変更は、各ワークフローが定める承認境界に従う。
- `.obsidian/` は原則編集せず、例外は `.obsidian/snippets/vault-custom.css` のみとする。
- `99_Templates/` はユーザーが明示した場合だけ編集する。
- ファイルを追加・削除・リネームしたら、関連リンクと `VAULT_INDEX.md` またはリンク先の詳細索引を更新する。
- 複数ファイルを大きく整理する場合は、作業前スナップショットを提案する。
- 作業完了時に差分とリンクを検証し、取得したロックを解放する。

## ドキュメント命名規則

- ディレクトリ名は役割を表す複数形の英単語とする。
- 規約・仕様のファイル名は内容を表す英語の名詞句をkebab-caseで記述する。
- `docs/workflows/` のファイル名は、呼び出し名と一致するkebab-caseのIDとする。
- `README.md`、`AGENTS.md`、`CLAUDE.md`、`HERMES.md` はツールや配置上の固定名として例外扱いにする。
- AIエージェント向けMarkdownは1ファイル200行以下とし、超える場合は責務で分割する。
- 同じ規則を複製せず、入口文書には要約と正本へのリンクだけを置く。
