Obsidian vaultの定期メンテナンスレビューを実行する。**毎週〜隔週**の軽い健康診断。以下を順番にチェックし、最後に日本語でサマリーをまとめること。機械的チェック（1〜3）は Bash、内容判断（4〜6）は MCP/読解で行う。**このコマンドは検出と提案のみ。削除・リネーム・統合は必ずユーザー確認後に行う。**

---

## 事前準備

`VAULT_INDEX.md` と `CLAUDE.md` の「ファイル命名規則」を読み、vault構成と規約を把握する。

---

## 1. リンク健全性チェック（切れリンク）

Bashツールで以下を実行し、実在しないノートを指すwikiリンクを検出する（エイリアスも許容、PDF等の埋め込みとREADMEのプレースホルダは除外）。

```bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd .
export LC_ALL=C.UTF-8
: > /tmp/targets.txt
find . -path ./.obsidian -prune -o -path ./.claude -prune -o -name '*.md' -print | sed 's#.*/##; s#\.md$##' >> /tmp/targets.txt
grep -rhA8 --include='*.md' --exclude-dir=.obsidian --exclude-dir=.claude -E '^aliases:' . | grep -E '^\s*-\s' | sed 's/^\s*-\s*//; s/[[:space:]]*$//' >> /tmp/targets.txt
sort -u /tmp/targets.txt -o /tmp/targets.txt
# 実ノートのみ走査（.claude のコマンド定義と、例示構文を含むメタ文書 README/CLAUDE/VAULT_INDEX は除外）
grep -rno --include='*.md' --exclude-dir=.obsidian --exclude-dir=.claude -oE '\[\[[^]]+\]\]' . | grep -vE '/(README|CLAUDE|VAULT_INDEX)\.md:' | while IFS= read -r line; do
  lnk="${line##*:}"; t=$(echo "$lnk" | sed 's/\[\[//; s/\]\]//; s/|.*//; s/#.*//; s/[[:space:]]*$//')
  case "$t" in *.pdf|*.png|*.excalidraw*|*.canvas) continue;; esac
  grep -qxF "$t" /tmp/targets.txt || echo "BROKEN [[$t]] <- ${line%%:*}"
done | sort -u
```

切れリンクが出たら、まず `git log --diff-filter=D --name-only -- '<path>'` で**最近削除されていないか**を確認する。削除されていれば「リンク削除」ではなく `git checkout <消したコミット>^ -- <path>` での**復元**を優先的に提案する。

---

## 2. 命名規約リント

`CLAUDE.md` の規約（知識ノート＝日付なし／時間軸ノート＝`YYYYMMDD_`）に対する違反を検出する。

```bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd .
echo "[A] 知識ノートなのに日付プレフィックスが付いている疑い（永続ノート/トピック）"
find ./20_Areas/永続ノート ./20_Areas/機械学習・深層学習 ./20_Areas/ソフトウェア開発 -maxdepth 1 -name '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]_*.md' 2>/dev/null
echo "[B] paperタグなのに _メモ.md で終わっていない疑い"
grep -rlZ --include='*.md' -E '^\s*-\s*paper\s*$' ./30_Resources 2>/dev/null | xargs -0 -I{} sh -c 'case "{}" in *_メモ.md) ;; *) echo "{}";; esac'
echo "[C] 日次以外でハイフン日付(YYYY-MM-DD)を使っている疑い"
find . -path ./.obsidian -prune -o -name '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_*.md' -print 2>/dev/null
```

検出されたら、正しい名前へのリネーム案（`git mv` コマンド）を提示する。リネームは参照リンクへの影響を `grep -rn '\[\[旧名'` で確認してから提案すること。

---

## 3. VAULT_INDEX 整合性

索引と実態のズレ（索引にあるが実在しない／実在するが索引にない）を検出する。

```bash
cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || cd .
export LC_ALL=C.UTF-8
echo "=== 索引に載っているが実在しないファイル ==="
grep -oE '`[^`]+\.md`' VAULT_INDEX.md | tr -d '`' | while read p; do
  [ -f "$(find . -path "*/$p" -print -quit 2>/dev/null)" ] || { find . -path "*/$p" | grep -q . || echo "MISSING: $p"; }
done
echo "=== 実在するが索引に載っていない .md（テンプレ/ルート除く）==="
find ./10_Projects ./20_Areas ./30_Resources -name '*.md' 2>/dev/null | sed 's#^\./##' | while read f; do
  base="${f##*/}"; grep -qF "$base" VAULT_INDEX.md || echo "UNLISTED: $f"
done
```

ズレがあれば `VAULT_INDEX.md` の修正案を提示する。

---

## 4. Inbox整理チェック

`00_Inbox/` の中身を確認する。

- ファイルがある場合：各ファイルの内容・タグ・作成日を読み、振り分け先フォルダと対応方法を提案する
- 0件の場合：「Inboxはクリーンです」と報告する

---

## 5. 孤立ノート（orphan）チェック

`10_Projects/` `20_Areas/` `30_Resources/` のノートで、次を満たすものを孤立候補としてリストする。

- どのMOCからもリンクされていない
- 他のノートからも参照されていない
- `tags: [inbox]` / `tags: [archive]` でもない

対処法（MOCへ追加・アーカイブ・削除）を提案する。

---

## 6. MOC更新漏れチェック

各MOC（`【MOC】永続ノート` `【MOC】機械学習・深層学習` `【MOC】授業` `【MOC】プロジェクト研究A` `【MOC】30_Resources` など）と、対応フォルダ内のファイルを照合し、MOCに未掲載の新規ノートを報告する。

---

## 7. 週次・月次レビューノート作成

今日の日付（`currentDate`）を確認する。

- **週次**：月曜なら `99_Templates/週次レビュー用.md` を基に `00_Inbox/YYYY-Www_週次レビュー.md`（例 `2026-W23_週次レビュー.md`）を作成（テンプレ変数は実値に置換）。Periodic Notes プラグインが既に作成済みでないか先に確認する
- **月次**：1日または末日なら `99_Templates/月次レビュー用.md` を基に `00_Inbox/YYYY-MM_月次レビュー.md` を作成
- 該当なしなら「今日はレビュー作成日ではありません」と報告

---

## 8. サマリー出力

```
## Vault Review サマリー（YYYY-MM-DD）

### 切れリンク
- 件数・該当（削除由来なら復元提案）

### 命名規約リント
- 違反件数・該当ファイルとリネーム案

### VAULT_INDEX 整合性
- MISSING / UNLISTED 件数

### Inbox
- 件数・対応が必要なもの

### 孤立ノート
- 検出数・ノート名一覧

### MOC更新漏れ
- 漏れているノート一覧

### レビューノート
- 作成した/しなかった理由

### 推奨アクション（優先順）
1. ...
2. ...
```

より深い「重複・統合・分割・陳腐化」の棚卸しは `/vault-gc` で行う（月次推奨）。
