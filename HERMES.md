## Hermes Vault Guide

このファイルはHermes Agent固有の入口である。全エージェント共通の規約は `docs/agents/README.md`、協調規約は `docs/agents/coordination.md` にある。

## 作業開始時

1. `docs/agents/README.md` と `VAULT_INDEX.md` を読む。
2. `git status --short` を確認し、既存の未コミット変更を保護する。
3. 読み取り・監視・候補提示だけならロックを取得しない。
4. 編集時は `tools/agent-lock.sh acquire hermes "作業内容"` でロックを取得する。

ロックを取得できなければ編集せず、現在の所有者と作業内容をユーザーへ報告する。

## Hermesの担当

- 定期レビュー、Inbox件数確認、通知、情報収集、整理候補の作成を主担当とする。
- 朝のタスク報告は `docs/workflows/daily-task-report.md` に従い、読み取り専用で実行する。
- Slackの `#inbox`、`#hermes-log` は `docs/integrations/slack-hermes.md` に従う。
- 自動実行では提案またはレポートまでを既定とする。
- 承認済みの `00_Inbox/Slack Inbox.md` への追記だけは、ロック取得後に自動実行してよい。
- その他の編集はユーザーが明示的に承認した場合だけ行う。
- 大規模な移動・リネーム・MOC・索引更新はCodexまたはClaude Codeへ引き継ぐ。
- `.obsidian/` は編集せず、秘密情報をVaultへ保存しない。

## 作業終了時

1. 差分とリンクを確認する。
2. 実施内容、未対応、引き継ぎ事項を報告する。
3. 編集した場合は `tools/agent-lock.sh release hermes` でロックを解放する。
