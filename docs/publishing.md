# 公開サイト運用

このvaultは、`20_Areas/` のノートを既定でQuartzの静的サイトへ変換し、GitHub Pagesへ公開する。Inbox・Projects・Resources・Archives・運用文書は既定で公開しない。

AIエージェントへ候補選定・公開追加・公開停止・監査を依頼する場合は、`/publish` または同名の自然言語依頼を使い、`docs/agent-commands/publish.md` の手順に従う。

## 公開ルール

- `20_Areas/` は公開が既定である。
- `00_Inbox/`、`10_Projects/`、`30_Resources/`、`40_Archives/`、運用文書は非公開が既定である。
- Areas内で公開しないノートには `publish: false` を追加する。
- 非公開フォルダ内から例外的に公開するノートには、監査後に `publish: true` を追加する。
- 公開ノートから非公開ノートへのWikiリンクは、公開時にリンクを外して表示名だけを残す。
- 公開ノートが参照する画像は、対応形式に限って公開物へコピーする。
- DataviewおよびDataviewJSは静的サイトでは実行せず、公開時に説明文へ置換する。

## 公開する

1. Areas内では、公開可能な内容であることを確認する。非公開フォルダ内では、対象ノートのfrontmatterへ `publish: true` を追加する。
2. ローカルで公開対象を確認する。

```powershell
node tools/export-public-notes.mjs --output .quartz/content
```

3. `main` ブランチへpushする。
4. GitHub Actionsの `Publish approved notes` がQuartzをビルドしてGitHub Pagesへデプロイする。

## 公開を停止する

- Areas内では対象ノートへ `publish: false` を追加する。非公開フォルダ内では `publish: true` を削除する。
- 次回デプロイ時に公開サイトから除外される。
- Git履歴や過去のデプロイに残る可能性があるため、秘密情報を一度でも公開した場合は、削除だけでなく認証情報の失効・再発行を行う。

## 構成

- `tools/export-public-notes.mjs`：許可済みノートと参照画像をQuartzの `content/` へ抽出する。
- `site/quartz.config.ts`：サイト名、URL、テーマ、Markdown変換を設定する。
- `site/quartz.layout.ts`：検索、目次、バックリンク、グラフなどの画面構成を設定する。
- `.github/workflows/publish-notes.yml`：固定したQuartzバージョンでビルドし、GitHub Pagesへデプロイする。

## 注意

- GitHub Pagesは公開Webサイトである。
- `publish: true` を付ける前に、個人情報、秘密情報、未公開研究、課題の解答、第三者の著作物が含まれていないか確認する。
- Quartzの更新は、固定コミットを変更してローカルビルドを確認してから行う。
- ビルド時は固定したQuartz本体に対して互換範囲内の依存更新を適用し、high以上の脆弱性が残る場合はデプロイを停止する。
