---
tags:
  - home
aliases:
  - ホーム
  - ダッシュボード
---
# 🧠 Home

このVaultの入口。**知識へ4つの経路で潜れる** — ①構造 / ②概念 / ③トピック / ④検索

> **すばやく潜るショートカット**
> - `Ctrl + O` … クイックスイッチャー（ノート名で一発ジャンプ）
> - `Ctrl + Shift + F` … 全文検索（Vault横断）
> - `Ctrl + P` … コマンドパレット
> - グラフビュー … リンクの繋がりから関連知識をたどる
> - タグをクリック … 同じタグのノートを一覧（例：`#paper` `#permanent`）

---

## 🗺 知識マップ（MOC）

構造からたどる。各分野のハブ。

```dataview
LIST
FROM #MOC
WHERE file.name != "Home"
SORT file.path ASC
```

---

## 🧠 永続ノート（概念インデックス）

自分の言葉で書いた原子的な概念。脳内のコア。

```dataview
LIST
FROM "20_Areas/永続ノート"
WHERE !contains(tags, "MOC")
SORT file.name ASC
```

---

## 📖 科目・トピックノート

分野ごとにまとめた知識ノート。

```dataview
TABLE rows.file.link AS "ノート"
FROM "20_Areas"
WHERE !contains(tags, "MOC") AND file.folder != "20_Areas/永続ノート"
GROUP BY file.folder AS "分野"
SORT 分野 ASC
```

---

## 🔬 論文メモ

```dataview
TABLE WITHOUT ID file.link AS "論文", year AS "年", status AS "状態"
FROM "30_Resources"
WHERE contains(tags, "paper")
SORT status ASC, year DESC
```

---
---

## 🚀 アクティブプロジェクト

```dataview
TABLE file.mtime AS "最終更新", length(filter(file.tasks, (t) => !t.completed)) AS "残タスク"
FROM "10_Projects"
WHERE contains(tags, "MOC") AND file.name != "【MOC】10_Projects"
SORT file.mtime DESC
```

## ✅ 未完了タスク

```dataview
TASK
FROM "10_Projects" OR "20_Areas"
WHERE !completed
LIMIT 10
```

## 📥 Inbox（未整理）

```dataview
LIST
FROM "00_Inbox"
WHERE file.name != "はじめに"
SORT file.ctime DESC
LIMIT 5
```

## 🕒 最近編集したノート（3日以内）

```dataview
LIST
WHERE file.mtime >= date(today) - dur(3 days)
AND !contains(tags, "MOC")
AND file.folder != "99_Templates"
SORT file.mtime DESC
LIMIT 10
```
