## Workflow Index

このディレクトリは、ユーザーの依頼単位で実行する共通手順の正本である。ファイル名は呼び出しIDと一致するkebab-caseとし、Codexでは同名の自然言語依頼として扱う。

| 依頼・呼び出し | 手順 | 目的 |
|---|---|---|
| `/inbox` | `inbox.md` | Inboxの分類・整形・移動 |
| `/vault-review` | `vault-review.md` | 週次の軽い点検 |
| `/vault-gc` | `vault-gc.md` | 月次の重複・陳腐化点検 |
| `/paper` | `paper.md` | 論文メモ作成 |
| `/permanent` | `permanent.md` | 永続ノート作成 |
| `/pdf-to-md` | `pdf-to-md.md` | PDFのMarkdown変換 |
| `/publish` | `publish.md` | 公開候補・追加・停止・監査 |
| `/proofread` | `proofread.md` | 指定文書の添削 |
| 朝のタスク報告 | `daily-task-report.md` | 未完了タスクの読み取り専用集計 |

- 製品固有のコマンドファイルは薄い入口に留め、このディレクトリの正本を参照する。
- 手順から呼ぶスクリプト名を変更した場合は、`tools/` と該当手順を同時に更新する。
