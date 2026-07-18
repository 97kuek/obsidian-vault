## Documentation Index

このディレクトリは、Vaultの運用ドキュメントを責務ごとに管理する場所である。人間向けの概要はルートの `README.md`、AIエージェント共通の入口は `agents/README.md` とする。

## 正本

| 知りたいこと | 正本 |
|---|---|
| フォルダ分類・配置・命名・タスク | `standards/vault-structure.md` |
| 本文・frontmatter・テンプレート・MOC・タグ | `standards/note-format.md` |
| エージェント共通の開始・終了手順 | `agents/README.md` |
| エージェントの役割・編集ロック | `agents/coordination.md` |
| 依頼単位の実行手順 | `workflows/README.md` |
| Slack・Hermes・Calendar連携 | `integrations/slack-hermes.md` |
| 公開サイトの仕組み | `operations/publishing.md` |
| 画像・スクリーンショットの添付 | `operations/attachments.md` |
| 主要ファイルの所在 | `../VAULT_INDEX.md` |

同じ規則を複数ファイルへ詳しく複製しない。入口文書には要約と正本へのリンクだけを置く。

## ディレクトリ構成

```text
docs/
├── README.md       # この案内図
├── standards/      # Vault全体の規約
├── agents/         # AIエージェント共通規約と協調
├── workflows/      # 依頼単位の実行手順
├── integrations/   # 外部サービス連携
├── operations/     # 公開・保守などの運用仕様
└── indexes/        # VAULT_INDEX.mdから分割した詳細索引
```

## 配置・命名

- ディレクトリ名は役割を表す複数形の英単語とする。
- 規約・仕様は内容を表す英語の名詞句をkebab-caseで命名する。
- ワークフローは呼び出しIDと同じkebab-caseで命名する。
- ルートの `AGENTS.md`、`CLAUDE.md`、`HERMES.md` は製品固有の固定名として扱う。
- AIエージェント向けMarkdownは1ファイル200行以下とする。

## 更新ルール

- 規則を変える場合は、まず上表の正本を更新する。
- ファイルを追加・削除・移動・改名したら、関連リンクと `VAULT_INDEX.md` またはリンク先の詳細索引を更新する。
- スクリプト名を変えたら、`tools/` とそれを呼ぶワークフローを同時に更新する。
- OAuthトークン、APIキー、Slackトークン、Google認証JSONはVaultへ保存しない。
