# 論文メモ作成

`30_Resources/` に論文の読書メモを作る。論文を読んだら、frontmatter 付きで定型作成し、索引・MOC・関連リンクまで更新する。

## 原則

- 読書メモは、その論文に書いてあったことの参照記録である。
- 横断概念があれば永続ノート化を提案するが、手法そのものは永続ノートにしない。
- frontmatter は必ず埋める。不明な項目は「要確認」を添えるか、ユーザーに短く尋ねる。
- 既存メモの上書きは事前に確認する。

## 手順

1. `99_Templates/論文ノート用.md`、`VAULT_INDEX.md`、`30_Resources/【MOC】30_Resources.md` を読む。
2. タイトル・著者・年・会議/雑誌・トピック・読んだ内容を受け取る。
3. `30_Resources/<トピック>/<略称>_メモ.md` を作成する。
4. `30_Resources/【MOC】30_Resources.md` と `VAULT_INDEX.md` を更新する。
5. 関連ノートへリンクする。
6. 横断概念があれば永続ノート化を提案する。
7. 切れリンク確認を行い、サマリーを出す。

## Frontmatter

```yaml
date: YYYY-MM-DD
tags:
  - paper
  - <トピックタグ>
title: "<正式タイトル>"
authors: "<著者>"
year: <年>
venue: "<会議/雑誌>"
status: unread
```

