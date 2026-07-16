## Slack・Hermes・Obsidian連携

個人用Slackを入力・通知画面、Obsidianを正本として使うための運用規約である。

## 現在の実装状態

| 機能 | 状態 | 備考 |
|---|---|---|
| Slack接続 | 設定済み | Hermes Gatewayをlaunchdで常駐させる |
| `#inbox` 自動収集 | 稼働中 | ライブ受信に加え、10分ごとの差分同期でMac停止中の投稿も回収する |
| `#research` 自動収集 | 稼働中 | 差分同期で回収し、`arxiv` スキルによる候補提示だけを行う |
| `#hermes-log` | 稼働中 | 毎朝9:10にGateway・cron・保留キューの要約を配信する |
| Google Calendar | 読み取り専用で認証済み | `calendar.readonly` のみを許可する |
| 朝8時レポート | 稼働中 | cron ID `0482192c5d6a`。8時にスリープ中なら復帰後にSlack DMへ配信する |
| 日次ヘルスチェック | 稼働中 | cron ID `7614c3f6c280`。`#hermes-log`へ配信する |
| 週次タスク確認 | 稼働中 | cron ID `63e1b74ad673`。毎週日曜18:00にSlack DMへ主要3件の候補を配信する |
| Slack履歴差分同期 | 稼働中 | no-agent cron ID `2a1d85ddd0e0`。10分間隔、LLM不使用、出力はローカルのみ |

状態は2026-07-16時点である。外部サービス側のチャンネル参加、権限失効、トークン失効はVaultの文書だけでは判定せず、実際の接続テストで確認する。

## チャンネルの役割

| Slackチャンネル | 用途 | Obsidianでの扱い |
|---|---|---|
| `#inbox` | 思いつき、依頼、あとで考えること | `00_Inbox/Slack Inbox.md` へ原文を追記する |
| `#research` | 論文、データセット、記事、URL | `00_Inbox/Slack Research.md` へ出典付きで追記する |
| `#hermes-log` | 自動処理の結果、失敗、稼働確認 | Vaultへ保存せず、Slackだけに要約を残す |
| HermesとのDM | 朝のタスク報告、対話、承認 | 必要な場合だけVaultへ反映する |

`#inbox` と `#research` は収集箱であり、自動分類済みノートの置き場ではない。原文を保存した後、`docs/agent-commands/inbox.md` に従って整理する。

## 自動保存形式

Hermesは投稿ごとに `tools/capture-slack-message.rb` を実行し、対象ファイルの末尾へ追記する。

```markdown
## YYYY-MM-DD HH:mm

- 内容: 投稿の原文
- 状態: 未整理
```

- 投稿本文、URL、添付ファイル名を削らない。
- Slack上の秘密情報、OAuthトークン、APIキーは保存しない。検出した場合は追記を中止して警告する。
- SlackメッセージIDを受け取れる場合はそれを重複判定に使い、受け取れない場合は同じ日の同一内容を重複として扱う。
- permalink、投稿時刻、チャンネル名を受け取れる場合は出典メタデータとして保存する。
- スクリプトは書き込み前にエージェントロックを取得し、終了時に必ず解放する。
- ロックを取得できない場合は `.agent-queue/` のローカル再処理キューへ保存し、日次ヘルスチェックで再処理する。
- 自動保存はこの2ファイルへの追記だけを例外的に承認する。移動、削除、整形、分類は自動実行しない。

## Mac停止中の投稿回収

- Hermes Gatewayはlaunchdでログイン時に自動起動し、Macが起きている間だけ動作する。
- Slack Socket Mode停止中の投稿は、`tools/sync-slack-history.rb` がSlack履歴APIから差分回収する。
- no-agent cron `2a1d85ddd0e0` が10分ごとに `~/.hermes/scripts/slack-history-sync.sh` を実行する。
- 各回はSlackの最新タイムスタンプを比較するだけで、LLMを起動しない。
- Macがスリープ中は実行せず、復帰後に期限を過ぎた同期ジョブを実行する。
- 同期位置は `.agent-state/slack-history.json`、実行ログは `.agent-state/hermes-slack-sync.log` に保存し、Git管理しない。
- 投稿はSlackメッセージIDで重複排除し、ロック競合時は `.agent-queue/` へ退避して次回処理する。
- 初回だけ直近7日を走査し、その後は最後に処理した投稿以降だけを取得する。

## リサーチ整理

`#research` の投稿は次の順序で扱う。

1. `00_Inbox/Slack Research.md` へ原文と出典を保存する。
2. Hermesは論文、データセット、記事、未判定に分けた整理候補を提示する。
3. ユーザー承認後に、論文は `docs/agent-commands/paper.md`、その他は `docs/agent-commands/inbox.md` に従って整理する。
4. PDF本体はVaultへ入れず、Zoteroなどで管理する。

## Hermesログ

`#hermes-log` には生ログを常時転送せず、次だけを残す。

- cronの成功・失敗
- SlackからVaultへの保存成功・保留・重複スキップ
- Gatewayの起動・停止
- 連続エラーとユーザー対応が必要な警告

トークン、OAuth認証コード、投稿本文の全文、ローカル環境変数はログへ出さない。正常時は1処理1行、詳細は失敗時だけ表示する。

## Google Calendar

- CalendarだけをOAuth連携し、`https://www.googleapis.com/auth/calendar.readonly` だけを許可する。
- 朝のタスク報告では、当日予定とObsidianタスクを読み取り、時間の重なりと期限だけを知らせる。
- 現在の権限では予定の作成、変更、削除を行えない。将来必要になった場合も、ユーザーの明示承認後に別スコープを追加する。
- OAuthクライアント情報とトークンは `~/.hermes/` に保存し、Vaultへ入れない。

| ローカルファイル | 用途 | Git管理 |
|---|---|---|
| `~/.hermes/google_client_secret.json` | OAuthクライアント情報 | 対象外 |
| `~/.hermes/google_token.json` | 読み取り用アクセストークン・更新情報 | 対象外 |

朝9時ジョブはHermes専用Pythonと `google_api.py calendar list` を使う。一般のPython環境へ依存パッケージを再インストールしない。

## 主要タスクの管理

- タスクの正本はObsidianの `- [ ]` とする。
- 期限は `📅 YYYY-MM-DD`、優先度は `⏫`、`🔼`、記号なし、`🔽` を使う。
- 毎朝の報告は最大3件に絞る。
- 期限なしタスクが多い場合、Hermesは週1回「今週の主要3件」の候補を提示する。
- 週次確認は候補提示だけを行い、ユーザーが採用番号と必要な期限を返して確定する。
- Hermesは期限、優先度、完了状態を推測して書き換えない。ユーザーが決めた内容だけを反映する。

## Slack側の初期設定

各チャンネルのメンバー追加画面からHermesを追加する。チャンネルIDは次のとおりである。

| チャンネル | ID |
|---|---|
| `#inbox` | `C0BGZCQMC5V` |
| `#hermes-log` | `C0BGZCXPMQX` |
| `#research` | `C0BHGM04GFK` |

Hermes追加後にGatewayを再起動し、各チャンネルへテスト投稿を1件ずつ送る。保存先とログを確認してから通常運用へ移る。

## Hermesのチャンネルプロンプト

- `#inbox`: 投稿本文をそのまま `ruby tools/capture-slack-message.rb inbox "投稿本文"` へ渡し、結果だけを短く返信する。
- `#research`: 投稿本文をそのまま `ruby tools/capture-slack-message.rb research "投稿本文"` へ渡し、保存後に資料種別の候補を1行で返す。
- `#hermes-log`: ユーザーの収集入力には使わず、自動処理からの通知先にする。

可能な場合は次のオプションも渡す。

```zsh
ruby tools/capture-slack-message.rb \
  --id "Slack message ts" \
  --permalink "Slack permalink" \
  --timestamp "ISO 8601 timestamp" \
  --channel-name "inbox" \
  inbox "投稿本文"
```

保留キューは `ruby tools/capture-slack-message.rb flush` で再処理する。
