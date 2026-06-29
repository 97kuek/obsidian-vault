# Vault Rules

このファイルは Obsidian vault の詳細運用規約である。エージェントの入口は Claude Code が `CLAUDE.md`、Codex が `AGENTS.md`。詳細判断に迷ったらこのファイルを読む。

---

## 大方針

- 人間は `00_Inbox/` に殴り書きするだけでよい。
- AI エージェントは分類・整形・移動・命名・タグ・リンク/MOC/索引更新を提案し、承認後に実行する。
- ノート作成・整形は、だ・である調、箇条書き中心、元情報を削らないことを既定とする。
- 複数ファイルの作成・削除・リネームなど大きな整理では、作業前コミットを提案する。

---

## フォルダ構成

| フォルダ | 用途 |
|---|---|
| `00_Inbox/` | 未整理ノートの一時置き場 |
| `10_Projects/` | 期限・ゴールのあるアクティブな作業 |
| `20_Areas/` | 継続的に管理するトピック |
| `20_Areas/永続ノート/` | Zettelkasten 永続ノート |
| `30_Resources/` | 将来再利用できる参考資料・論文メモ |
| `40_Archives/` | 完了・不要なノート |
| `99_Templates/` | Templater テンプレート |

PDF 本体は vault に置かず、Zotero 等の外部で管理する。

---

## 触れてはいけないもの

- `.obsidian/` は原則編集しない。
- 例外は `.obsidian/snippets/vault-custom.css` の CSS 編集のみ。
- `99_Templates/` はユーザーが明示した場合だけ編集する。
- `*.pdf` などのバイナリは操作しない。

---

## 命名規則

大原則: 時間軸のノートは日付を付け、知識のノートは付けない。

| 種別 | 命名規則 | 例 |
|---|---|---|
| 知識ノート | `概念名.md` | `決定木.md` |
| MOC | `【MOC】タイトル.md` | `【MOC】プロジェクト研究A.md` |
| 論文読書メモ | `略称_メモ.md` | `TF-Locoformer_メモ.md` |
| 実験ログ | `YYYYMMDD_タイトル.md` | `20260511_音源分離実験.md` |
| 勉強会 | `YYYYMMDD_勉強会NN.md` | `20260423_勉強会02.md` |
| 執筆ドラフト | `YYYYMMDD_タイトル_draft.md` | `20260601_中間報告スライド_draft.md` |
| 週次レビュー | `YYYY-Www_週次レビュー.md` | `2026-W23_週次レビュー.md` |
| 月次レビュー | `YYYY-MM_月次レビュー.md` | `2026-06_月次レビュー.md` |
| 日次ノート | `YYYY-MM-DD.md` | `2026-05-12.md` |

手動作成するログ類は `YYYYMMDD_` を使う。Periodic Notes が作る日次・週次・月次は ISO 形式を使う。

---

## Frontmatter

公開の既定値はフォルダで決める。

| フォルダ | 既定 |
|---|---|
| `20_Areas/` | 公開 |
| `00_Inbox/` | 非公開 |
| `10_Projects/` | 非公開 |
| `30_Resources/` | 非公開 |
| `40_Archives/` | 非公開 |
| その他の運用フォルダ | 非公開 |

個別に既定値を上書きする場合だけ、通常のfrontmatterへ次を追加する。

```yaml
publish: true
# または
publish: false
```

- `20_Areas/` でも、課題解答・個人情報・秘密情報・未公開内容を含むノートには `publish: false` を付ける。
- `20_Areas/` 以外を例外的に公開する場合は、内容を監査して `publish: true` を付ける。
- 公開前に個人情報、秘密情報、未公開研究、課題解答、第三者の著作物が含まれていないか確認する。
- 公開処理の詳細は `docs/publishing.md` を参照する。

通常ノート:

```yaml
date: YYYY-MM-DD
tags:
  - タグ
```

MOC:

```yaml
tags:
  - MOC
aliases:
  - 別名1
created: YYYY-MM-DD
status: active
```

論文読書メモ:

```yaml
date: YYYY-MM-DD
tags:
  - paper
title: ""
authors: ""
year:
venue: ""
status: unread
```

実験ノート:

```yaml
date: YYYY-MM-DD
tags:
  - experiment
project: ""
environment: ""
```

永続ノート:

```yaml
date: YYYY-MM-DD
tags:
  - permanent
aliases:
  -
```

執筆ドラフト:

```yaml
date: YYYY-MM-DD
tags:
  - draft
project: ""
type: ""
status: drafting
```

---

## テンプレート

| テンプレート | 使うタイミング |
|---|---|
| `【MOC】.md` | 新しいトピックの MOC |
| `プロジェクト用.md` | `10_Projects/` 内の個別ノート |
| `論文ノート用.md` | 論文読書メモ |
| `実験ノート用.md` | 実験・作業ログ |
| `授業ノート用.md` | 授業・勉強会 |
| `永続ノート用.md` | 横断概念の永続ノート |
| `週次レビュー用.md` | 週次レビュー |
| `月次レビュー用.md` | 月次レビュー |
| `執筆ドラフト用.md` | レポート・スライドの下書き |

テンプレート変数（`<% tp.* %>`）は実ノートに残さず、実値に置換する。

---

## MOC

MOC は次の階層を基本にする。

```text
Home
├── 10_Projects/【MOC】10_Projects
├── 20_Areas/【MOC】20_Areas
│   ├── ソフトウェア開発/【MOC】ソフトウェア開発
│   ├── 機械学習・深層学習/【MOC】機械学習・深層学習
│   ├── 授業/【MOC】授業
│   └── 永続ノート/【MOC】永続ノート
└── 30_Resources/【MOC】30_Resources
```

各 MOC には関連 MOC・上位 MOC へのリンクを置く。MOC の末尾には `` **最終更新:** `= this.file.mtime` `` を入れる。

---

## 永続ノート

- 他分野にも通じる横断概念だけを永続ノートにする。
- 特定分野の手法・アルゴリズムそのものは、科目・トピックノートに置く。
- 1ノート1概念。
- 論文の要約ではなく、自分の言葉で書く。
- 出典と関連ノートへリンクする。
- 作成したら `20_Areas/永続ノート/【MOC】永続ノート.md` と `VAULT_INDEX.md` を更新する。

---

## クリップ

`00_Inbox/` に入る X などのクリップは出典として扱う。

| バケツ | やること | 行き先 |
|---|---|---|
| 知見化 | 自分の言葉でノート化／既存ノートに吸収 | 永続ノート・解説ノート・`30_Resources/クリップ/` |
| プロジェクト取り込み | 未検証アイデアや判断材料として記録 | 該当プロジェクトの `アイデア・検討.md` |
| ツール台帳 | ツール候補に1行追記 | `20_Areas/ソフトウェア開発/AI駆動開発.md` |
| 破棄 | 知見化しない主観・周知 | Inbox ファイル削除 |

原文保管は L/P/D テストで判断する。長文、プロジェクト判断材料、図表・数値・コードなど再現困難な一次情報を含む場合は保管する。

---

## タグ

| カテゴリ | タグ |
|---|---|
| システム | `MOC` `inbox` `archive` `clip/x` |
| ノート種別 | `reference` `idea` `paper` `experiment` `lecture` `project` `permanent` `draft` `dataset` `corpus` |
| トピック | `機械学習` `深層学習` `音源分離` `ソフトウェア開発` |
| モデル | `transformer` `bert` `ai` など |

タグは小文字英語または日本語に統一する。
