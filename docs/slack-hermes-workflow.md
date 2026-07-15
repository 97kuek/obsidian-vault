## Slack・Hermes・Obsidian連携

個人用Slackを入力・通知画面、Obsidianを正本として使うための運用規約である。

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
- 同じ日に同一内容がすでに保存されていれば追記しない。
- スクリプトは書き込み前にエージェントロックを取得し、終了時に必ず解放する。
- ロックを取得できない場合は書き込まず、`#hermes-log` へ保留を通知する。
- 自動保存はこの2ファイルへの追記だけを例外的に承認する。移動、削除、整形、分類は自動実行しない。

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

- 最初はCalendarだけをOAuth連携し、権限を広げすぎない。
- 朝のタスク報告では、当日予定とObsidianタスクを読み取り、時間の重なりと期限だけを知らせる。
- 予定の作成、変更、削除はユーザーが明示した場合だけ実行する。
- OAuthクライアント情報とトークンは `~/.hermes/` に保存し、Vaultへ入れない。

## 主要タスクの管理

- タスクの正本はObsidianの `- [ ]` とする。
- 期限は `📅 YYYY-MM-DD`、優先度は `⏫`、`🔼`、記号なし、`🔽` を使う。
- 毎朝の報告は最大3件に絞る。
- 期限なしタスクが多い場合、Hermesは週1回「今週の主要3件」の候補を提示する。
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
