Vaultのナレッジ棚卸し（garbage collection / 庭の手入れ）を行う。ノートが増えてきたときの**月次〜四半期**の重い見直し。**重複・統合・分割・陳腐化**を検出し、整理を提案する。

**重要な原則：**
- **このコマンドは「提案」までで止まる。削除・統合・リネームは必ずユーザーの承認を得てから実行する。**
- 統合・削除の前に必ず対象ファイルを開いて中身を読む。「索引の説明」や「タイトル」だけで判断しない。
- 知識を**消す**より、**つなぐ・束ねる**ことを優先する（Zettelkastenでは孤立より重複の方が害が小さい）。
- 破壊的操作の前に作業前コミット（`git add -A && git commit -m "vault-gc前スナップショット"`）を提案する。

---

## 事前準備

`VAULT_INDEX.md` と `CLAUDE.md`、各MOCを読み、知識の全体像を把握する。対象は主に知識ノート（`20_Areas/永続ノート/`・`20_Areas/機械学習・深層学習/`・各トピックノート・`30_Resources/`）。

```bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd .
echo "=== 知識ノート一覧（パス / 行数 / 最終更新日 / 先頭見出し）==="
for f in $(find ./20_Areas ./30_Resources ./10_Projects -name '*.md' ! -name '【MOC】*' 2>/dev/null); do
  lines=$(wc -l < "$f")
  d=$(git log -1 --format=%as -- "$f" 2>/dev/null)
  h=$(grep -m1 -E '^#{1,2} ' "$f" | sed 's/^#\+ //')
  printf '%-55s | %4s行 | %s | %s\n' "${f#./}" "$lines" "${d:-?}" "$h"
done
```

---

## 1. 重複・内容の近接（統合候補）

タイトル・別名・先頭見出し・タグから、**同じ概念を扱っている／大きく重なるノートのペア**を洗い出す。判断に迷う場合は `search_vault_smart` で意味的に近いノートを照合する。

典型例：
- 同義語・表記ゆれ（例: `K-means法` と `kmeans`）
- 親子関係で内容が重複（広いノートと、その一部だけを切り出したノート）
- 同じ論文・概念について複数のメモ

各ペアについて次を提示する：
- どちらを**残す**か（リンクが多い・粒度が適切な方を主とする）
- 何を**移植**するか、リンクをどう張り替えるか（`grep -rn '\[\[旧名'` で被リンクを確認）

---

## 2. 分割候補（1ノート1概念に反するもの）

長すぎる・複数の独立概念を含むノートを検出し、分割を提案する。

```bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd .
echo "=== 行数が多い知識ノート（分割候補の目安: 永続ノートで120行超）==="
for f in $(find ./20_Areas/永続ノート -name '*.md' ! -name '【MOC】*' 2>/dev/null); do
  n=$(wc -l < "$f"); [ "$n" -gt 120 ] && printf '%4s行  %s\n' "$n" "${f#./}"
done
```

「1ノート1概念」に反していれば、どの概念を別ノートへ切り出すか、切り出し後のリンク構造を提案する（永続ノートのルール）。

---

## 3. 陳腐化・棚上げ候補（stale）

長期間更新されておらず、かつ他から参照されていないノートを洗い出す。

```bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd .
echo "=== 90日以上 git 更新がない知識ノート ==="
cutoff=$(date -d '90 days ago' +%s 2>/dev/null || date -v-90d +%s)
for f in $(find ./20_Areas ./30_Resources -name '*.md' ! -name '【MOC】*' 2>/dev/null); do
  ts=$(git log -1 --format=%at -- "$f" 2>/dev/null)
  [ -n "$ts" ] && [ "$ts" -lt "$cutoff" ] && printf '%s  %s\n' "$(git log -1 --format=%as -- "$f")" "${f#./}"
done
echo "=== 被リンク0（どのノートからも [[..]] されていない）知識ノート ==="
export LC_ALL=C.UTF-8
grep -rho --include='*.md' --exclude-dir=.obsidian -oE '\[\[[^]]+\]\]' . | sed 's/\[\[//; s/\]\]//; s/|.*//; s/#.*//; s/[[:space:]]*$//' | sort -u > /tmp/linked.txt
for f in $(find ./20_Areas/永続ノート -name '*.md' ! -name '【MOC】*' 2>/dev/null); do
  base="${f##*/}"; name="${base%.md}"
  als=$(grep -A8 -E '^aliases:' "$f" | grep -E '^\s*-\s' | sed 's/^\s*-\s*//')
  hit=0; for n in "$name" $als; do grep -qxF "$n" /tmp/linked.txt && hit=1; done
  [ "$hit" -eq 0 ] && echo "被リンク0: ${f#./}"
done
```

stale ノートは即削除せず、(a) MOC/関連ノートへリンクして再活用、(b) `40_Archives/` へ移動、(c) 内容が他に統合済みなら削除、のいずれかを内容を見て提案する。

---

## 4. 出力（提案テーブル）

```
## Vault GC 提案（YYYY-MM-DD）

### 統合候補
| 主ノート | 統合元 | 理由 | 移植/リンク方針 |

### 分割候補
| ノート | 含む概念 | 切り出し案 |

### 陳腐化・棚上げ候補
| ノート | 最終更新 | 被リンク | 推奨アクション |

### 実行プラン（承認後に着手）
1. 作業前コミット
2. （統合）… → リンク張り替え → MOC更新 → VAULT_INDEX更新
3. （分割）…
4. リンク健全性 `/vault-review` の1で最終確認
```

提案後、ユーザーが承認した項目だけを実行する。実行時は **MOC・VAULT_INDEX・被リンクの張り替え** まで必ずセットで行うこと。
