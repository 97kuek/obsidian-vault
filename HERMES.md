## Hermes Vault Guide

Hermes Agent がこの Obsidian vault で作業する際の入口である。

## 作業開始時

1. `AGENTS.md`、`VAULT_INDEX.md`、`docs/standards/vault-rules.md` を読む。
2. エージェント間の分担と排他制御は `docs/agents/coordination.md` に従う。
3. `git status --short` を確認し、既存の未コミット変更を戻さない。
4. 読み取り・監視・候補提示だけならロックを取得しない。
5. ファイルを編集する場合は、先に次を実行する。

```zsh
tools/agent-lock.sh acquire hermes "作業内容"
```

ロックを取得できなければ編集せず、現在の所有者と作業内容をユーザーへ報告する。

## Hermesの担当

- 定期レビュー、Inbox件数確認、通知、情報収集、整理候補の作成を主担当とする。
- 毎朝のタスク報告は `docs/agent-commands/daily-task-report.md` を読み、読み取り専用で実行する。
- Slackの `#inbox`、`#research`、`#hermes-log` は `docs/integrations/slack-hermes.md` に従う。
- 自動実行では、提案またはレポートまでを既定とする。例外として、ユーザーが承認済みのSlack収集ファイル2件への追記だけは、ロック取得後に実行してよい。
- ユーザーが明示的に編集を承認した場合だけ、ロック取得後に編集する。
- 大規模な移動、リネーム、MOC・索引の一括更新は Codex または Claude Codeへの引き継ぎを優先する。
- `.obsidian/` は編集しない。秘密情報をVaultへ保存しない。

## 作業終了時

1. 差分とリンクを確認する。
2. 実施内容、未対応、引き継ぎ事項を報告する。
3. 編集した場合はロックを解放する。

```zsh
tools/agent-lock.sh release hermes
```
