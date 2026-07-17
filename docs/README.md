## Documentation Index

このディレクトリはVaultの運用ドキュメントを、責務ごとに分離して管理する場所である。人間向けの概要はルートの `README.md`、AIエージェントの入口は `AGENTS.md`、`CLAUDE.md`、`HERMES.md` とする。

## 正本

| 知りたいこと | 正本 | 補足 |
|---|---|---|
| Vaultの分類・命名・frontmatter・見出し | `standards/vault-rules.md` | 全エージェント共通 |
| エージェントの役割・編集ロック | `agents/coordination.md` | Codex・Claude Code・Hermes共通 |
| 作業別の実行手順 | `agent-commands/` | Inbox、添削、公開、レビューなど |
| Slack・Hermes・Calendar連携 | `integrations/slack-hermes.md` | 外部連携と自動化境界 |
| 公開サイトの仕組み | `operations/publishing.md` | Quartz・GitHub Pagesの構成 |
| 画像・スクリーンショットの添付 | `operations/attachments.md` | 保存先、貼り付け、リンク確認、公開時の注意 |
| ファイルの所在 | `../VAULT_INDEX.md` | 追加・削除・移動時に更新 |

同じ規則を複数ファイルへ詳しく複製しない。入口ドキュメントには要約と正本へのリンクだけを置き、具体的な判定基準は上表の正本へ集約する。

## ディレクトリ構成

```text
docs/
├── README.md             # この案内図
├── standards/            # Vault全体へ適用する不変ルール
├── agents/               # 複数AIエージェントの協調規約
├── agent-commands/       # 依頼単位の実行手順
├── integrations/         # Slack、Hermes、Calendarなど外部連携
└── operations/           # 公開・保守などシステム運用
```

## 配置基準

| 内容 | 配置 |
|---|---|
| 人間が最初に読む概要 | ルート `README.md` |
| エージェント固有の入口 | ルート `AGENTS.md`、`CLAUDE.md`、`HERMES.md` |
| 全エージェント共通の規則 | `docs/standards/` |
| エージェント間の協調・権限 | `docs/agents/` |
| 1つの依頼を完了する手順 | `docs/agent-commands/` |
| 外部サービスの連携仕様 | `docs/integrations/` |
| Vaultを支える公開・保守処理 | `docs/operations/` |
| 実行可能な補助プログラム | `tools/` |

## 更新ルール

- 規則を変える場合は、まず正本を更新する。
- 入口ドキュメントは、正本へのリンク切れと要約の矛盾だけを確認する。
- ファイルを追加、削除、移動、改名したら `VAULT_INDEX.md` を更新する。
- 手順から呼び出すスクリプト名を変えたら、`tools/` と該当する `agent-commands/` を同時に更新する。
- OAuthトークン、APIキー、Slackトークン、Google認証JSONは `docs/` やVaultへ保存しない。
