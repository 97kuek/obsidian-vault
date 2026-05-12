---
tags:
  - home
aliases:
  - ホーム
  - ダッシュボード
---
## Quick Links
[[【MOC】プロジェクト研究A]] | [[【MOC】機械学習・深層学習]] | [[【MOC】ソフトウェア開発]] | [[実験結果まとめ]]

---

## Inbox
```dataview
LIST
FROM "00_Inbox"
WHERE file.name != "はじめに"
SORT file.ctime DESC
LIMIT 5
```

## アクティブプロジェクト
```dataview
TABLE file.mtime AS "最終更新", length(filter(file.tasks, (t) => !t.completed)) AS "残タスク"
FROM "10_Projects"
WHERE contains(tags, "MOC") AND file.name != "【MOC】10_Projects"
SORT file.mtime DESC
```

## 論文読書状況
```dataview
TABLE WITHOUT ID file.link AS "論文", year AS "年", status AS "状態"
FROM "30_Resources"
WHERE contains(tags, "paper")
SORT status ASC, year DESC
```

## 未完了タスク
```dataview
TASK
FROM "10_Projects" OR "20_Areas"
WHERE !completed
LIMIT 10
```

## 最近編集したノート（3日以内）
```dataview
LIST
WHERE file.mtime >= date(today) - dur(3 days)
AND !contains(tags, "MOC")
AND file.folder != "99_Templates"
SORT file.mtime DESC
LIMIT 10
```
