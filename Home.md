---
tags:
  - home
aliases:
  - ホーム
  - ダッシュボード
---
# Home

> [!tip] Quick navigation
> `Ctrl+O` jump / `Ctrl+Shift+F` full-text search / Graph view / Tag click

## Search

```dataviewjs
const box = dv.el("div", "");
const input = box.createEl("input", { attr: { type: "text", placeholder: "Search by note name (partial match)..." } });
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
  if (!q) { out.createEl("div", { text: "Type a keyword to filter by note name", attr: { style: "opacity:0.5" } }); return; }
  const hits = pages.filter(p => p.file.name.toLowerCase().includes(q));
  if (hits.length === 0) { out.createEl("div", { text: "No matches", attr: { style: "opacity:0.5" } }); return; }
  const ul = out.createEl("ul");
  for (const p of hits.slice(0, 20)) {
    const li = ul.createEl("li");
    const a = li.createEl("a", { text: p.file.name });
    a.style.cursor = "pointer";
    a.onclick = () => app.workspace.openLinkText(p.file.path, "", false);
    li.createEl("span", { text: "  — " + p.file.folder, attr: { style: "opacity:0.45; font-size:0.85em" } });
  }
  if (hits.length > 20) out.createEl("div", { text: `${hits.length - 20} more...`, attr: { style: "opacity:0.45; font-size:0.85em" } });
}
input.addEventListener("input", e => render(e.target.value));
render("");
```

## Knowledge Map (MOC)

```dataview
LIST
FROM #MOC
WHERE file.name != "Home"
SORT file.path ASC
```

---

> [!note]- Permanent Notes (concept index)
> ```dataview
> LIST
> FROM "20_Areas/永続ノート"
> WHERE !contains(tags, "MOC")
> SORT file.name ASC
> ```

> [!note]- Subject & Topic Notes
> ```dataview
> TABLE rows.file.link AS "Note"
> FROM "20_Areas"
> WHERE !contains(tags, "MOC") AND file.folder != "20_Areas/永続ノート" AND !regexmatch("^[0-9]{8}", file.name)
> GROUP BY file.folder AS "Field"
> SORT Field ASC
> ```

> [!note]- Paper Notes
> ```dataview
> TABLE WITHOUT ID file.link AS "Paper", year AS "Year", status AS "Status"
> FROM "30_Resources"
> WHERE contains(tags, "paper")
> SORT status ASC, year DESC
> ```

> [!example]- Active Projects
> ```dataview
> TABLE file.mtime AS "Last Modified", length(filter(file.tasks, (t) => !t.completed)) AS "Open Tasks"
> FROM "10_Projects"
> WHERE contains(tags, "MOC") AND file.name != "【MOC】10_Projects"
> SORT file.mtime DESC
> ```

> [!todo]- Open Tasks
> ```dataview
> TASK
> FROM "10_Projects" OR "20_Areas"
> WHERE !completed
> LIMIT 10
> ```

> [!note]- Inbox (unsorted)
> ```dataview
> LIST
> FROM "00_Inbox"
> WHERE file.name != "はじめに"
> SORT file.ctime DESC
> LIMIT 5
> ```

> [!note]- Recently Edited (last 3 days)
> ```dataview
> LIST
> WHERE file.mtime >= date(today) - dur(3 days)
> AND !contains(tags, "MOC")
> AND file.folder != "99_Templates"
> SORT file.mtime DESC
> LIMIT 10
> ```
