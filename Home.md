---
tags:
  - home
aliases:
  - ホーム
  - ダッシュボード
---
# 🧠 Home

> [!tip] すばやく潜る
> `Ctrl+O` ジャンプ ／ `Ctrl+Shift+F` 全文検索 ／ グラフビュー ／ タグクリック

## 🔍 検索

```dataviewjs
const box = dv.el("div", "");
const input = box.createEl("input", { attr: { type: "text", placeholder: "🔍 ノート名で検索（部分一致）..." } });
input.style.cssText = "width:100%; padding:6px 10px; margin-bottom:8px; border-radius:6px;";
const out = box.createEl("div");
const pages = dv.pages()
  .where(p => !p.file.path.startsWith("99_Templates/"))
  .where(p => !p.file.path.startsWith("00_Inbox/"))
  .where(p => !p.file.path.startsWith("40_Archives/"))
  .where(p => !p.file.name.startsWith("【MOC】"))
  .sort(p => p.file.name, "asc");
function render(q) {
  out.empty();
  q = (q || "").trim().toLowerCase();
  if (!q) { out.createEl("div", { text: "↑ キーワードを入力（ノート名で絞り込み）", attr: { style: "opacity:0.5" } }); return; }
  const hits = pages.filter(p => p.file.name.toLowerCase().includes(q));
  if (hits.length === 0) { out.createEl("div", { text: "該当なし", attr: { style: "opacity:0.5" } }); return; }
  const ul = out.createEl("ul");
  for (const p of hits.slice(0, 20)) {
    const li = ul.createEl("li");
    const a = li.createEl("a", { text: p.file.name });
    a.style.cursor = "pointer";
    a.onclick = () => app.workspace.openLinkText(p.file.path, "", false);
    li.createEl("span", { text: "  — " + p.file.folder, attr: { style: "opacity:0.45; font-size:0.85em" } });
  }
  if (hits.length > 20) out.createEl("div", { text: `他 ${hits.length - 20} 件…`, attr: { style: "opacity:0.45; font-size:0.85em" } });
}
input.addEventListener("input", e => render(e.target.value));
render("");
```

## 🗺 知識マップ（MOC）

```dataview
LIST
FROM #MOC
WHERE file.name != "Home"
SORT file.path ASC
```

---

> [!note]- 🧠 永続ノート（概念インデックス）
> ```dataview
> LIST
> FROM "20_Areas/永続ノート"
> WHERE !contains(tags, "MOC")
> SORT file.name ASC
> ```

> [!note]- 📖 科目・トピックノート
> ```dataview
> TABLE rows.file.link AS "ノート"
> FROM "20_Areas"
> WHERE !contains(tags, "MOC") AND file.folder != "20_Areas/永続ノート" AND !regexmatch("^[0-9]{8}", file.name)
> GROUP BY file.folder AS "分野"
> SORT 分野 ASC
> ```

> [!note]- 🔬 論文メモ
> ```dataview
> TABLE WITHOUT ID file.link AS "論文", year AS "年", status AS "状態"
> FROM "30_Resources"
> WHERE contains(tags, "paper")
> SORT status ASC, year DESC
> ```

> [!example]- 🚀 アクティブプロジェクト
> ```dataview
> TABLE file.mtime AS "最終更新", length(filter(file.tasks, (t) => !t.completed)) AS "残タスク"
> FROM "10_Projects"
> WHERE contains(tags, "MOC") AND file.name != "【MOC】10_Projects"
> SORT file.mtime DESC
> ```

> [!todo]- ✅ 未完了タスク
> ```dataview
> TASK
> FROM "10_Projects" OR "20_Areas"
> WHERE !completed
> LIMIT 10
> ```

> [!note]- 📥 Inbox（未整理）
> ```dataview
> LIST
> FROM "00_Inbox"
> WHERE file.name != "はじめに"
> SORT file.ctime DESC
> LIMIT 5
> ```

> [!note]- 🕒 最近編集したノート（3日以内）
> ```dataview
> LIST
> WHERE file.mtime >= date(today) - dur(3 days)
> AND !contains(tags, "MOC")
> AND file.folder != "99_Templates"
> SORT file.mtime DESC
> LIMIT 10
> ```
