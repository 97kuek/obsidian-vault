## Inbox
```dataview
LIST
FROM "00_Inbox"
SORT file.ctime DESC
LIMIT 5
```

## 最近の更新ノート
```dataview
TABLE date
FROM "20_Areas"
SORT file.mtime DESC
LIMIT 5
```

## プロジェクト
```dataview
TABLE file.mtime AS 最終更新
FROM "10_Projects"
SORT file.mtime DESC
```

## 未完了タスク
```dataview
TASK
FROM "10_Projects" OR "20_Areas"
WHERE !completed
LIMIT 10
```

## 最近編集したノート
```dataview
LIST
WHERE file.mtime >= date(today) - dur(3 days)
SORT file.mtime DESC
LIMIT 10
```
