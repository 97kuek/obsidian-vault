---
tags:
  - home
aliases:
  - dashboard
  - home
---
> [!tip] Quick navigation
> `Cmd+O` クイックスイッチャー / `Cmd+Shift+F` 全文検索

## Main

- [[【MOC】10_Projects|Projects]]
- [[【MOC】20_Areas|Areas]]
- [[【MOC】30_Resources|Resources]]
- [[【MOC】大学授業|大学授業]]
- [[【MOC】永続ノート|永続ノート]]

## Capture

- [[Slack Inbox]]
- [[Slack Research]]

## Open Tasks

```dataview
TASK
FROM "10_Projects" OR "20_Areas/大学授業"
WHERE !completed
LIMIT 10
```
