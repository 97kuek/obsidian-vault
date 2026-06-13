---
tags:
  - MOC
aliases:
  - Resources
  - リソース
created: 2026-05-12
status: active
---
## 概要・目的

将来再利用できる参考資料・論文のハブMOC。

## 論文読書キュー

```dataview
TABLE WITHOUT ID file.link AS "論文", year AS "年", status AS "状態", authors AS "著者"
FROM "30_Resources"
WHERE contains(tags, "paper")
SORT status ASC, year DESC
```

## 主要ノート

### 音源分離
- [[TasNet_メモ]] — TasNet（2018）時間領域音源分離の先駆け
- [[Conv-TasNet_メモ]] — Conv-TasNet（2019）TCNベース、当時SOTA
- [[TF-Locoformer_メモ]] — TF-Locoformer（2023）研究の主要モデル
- [[Transformer_メモ]] — Attention Is All You Need（2017）
- [[J-CHAT_メモ]] — J-CHATコーパス、研究の評価対象
- [[RemixIT_メモ]] — RemixIT、クリーン音声なしで学習する音声強調

## その他リソース

- [[Zotero連携ガイド]] — Zotero+Obsidian連携の設定手順

## 関連MOC・上位MOC

- 上位: [[Home]]
- 関連: [[【MOC】プロジェクト研究A]]

## 未整理・Inbox

- [ ] 

## メモ・気づき

---
**最終更新:** `= this.file.mtime`
