## Note Format

このファイルは、ノート本文、frontmatter、テンプレート、MOC、タグに関する正本である。配置とファイル名は `vault-structure.md` を参照する。

## 本文

- ノート作成・整形は、だ・である調、箇条書き中心、元情報を削らないことを既定とする。
- Markdownの見出しは `##` から始め、`#` は使用しない。
- ファイル名をノートのタイトルとして扱い、本文の最上位見出しを `##` とする。

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
- 公開処理の詳細は `docs/operations/publishing.md` を参照する。

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

## テンプレート

| テンプレート | 使うタイミング |
|---|---|
| `【MOC】.md` | 新しいトピックのMOC |
| `プロジェクト用.md` | `10_Projects/` 内の個別ノート |
| `論文ノート用.md` | 論文読書メモ |
| `実験ノート用.md` | 実験・作業ログ |
| `授業ノート用.md` | 授業・勉強会 |
| `永続ノート用.md` | 横断概念の永続ノート |
| `週次レビュー用.md` | 週次レビュー |
| `月次レビュー用.md` | 月次レビュー |
| `執筆ドラフト用.md` | レポート・スライドの下書き |

テンプレート変数（`<% tp.* %>`）は実ノートに残さず、実値に置換する。

### テンプレートの設計原則

- frontmatterと、そのノート種別に必須の見出しだけを置く。
- 特定プロジェクト名、固定リンク、大きなMermaid図を埋め込まない。
- DataviewやDataviewJSはテンプレートへ常設せず、必要なノートへ個別に追加する。
- 新しい用途は既存テンプレートへ無理に詰め込まず、再利用が3回以上見込める場合だけ新規テンプレートを検討する。
- テンプレートを増やしても、既存ノートが特定プラグインなしで読める状態を保つ。

## Obsidian CSS

- `.obsidian/snippets/vault-custom.css` はObsidian標準のCSS変数を優先して使う。
- 色、余白、文字の可読性を中心にし、内部DOM階層へ依存するセレクタを避ける。
- 外部Webフォント、常時アニメーション、`backdrop-filter`、広範囲の`!important`を使わない。
- プラグイン固有CSSは、機能上必要で安定した公開クラスがある場合だけ追加する。
- ファイル、フォルダ、操作UIをCSSで隠さない。表示整理はObsidianの設定やワークスペースで行う。
- ライト、ダーク、モバイルの標準表示を壊さない。

## MOC

MOCは次の階層を基本にする。

```text
Home
├── 10_Projects/【MOC】10_Projects
├── 20_Areas/【MOC】20_Areas
│   ├── ソフトウェア開発/【MOC】ソフトウェア開発
│   ├── 人工知能/【MOC】人工知能
│   ├── 大学授業/【MOC】大学授業
│   └── 永続ノート/【MOC】永続ノート
└── 30_Resources/【MOC】30_Resources
    └── 講座/【MOC】講座
```

各MOCには関連MOC・上位MOCへのリンクを置く。末尾には `` **最終更新:** `= this.file.mtime` `` を入れる。

## 永続ノート

- 他分野にも通じる横断概念だけを永続ノートにする。
- 特定分野の手法・アルゴリズムそのものは、科目・トピックノートに置く。
- 1ノート1概念とし、論文の要約ではなく自分の言葉で書く。
- 出典と関連ノートへリンクする。
- 作成したら `20_Areas/永続ノート/【MOC】永続ノート.md` と `docs/indexes/areas.md` を更新する。

## クリップ

`00_Inbox/` に入るXなどのクリップは出典として扱う。

| バケツ | やること | 行き先 |
|---|---|---|
| 知見化 | 自分の言葉でノート化・既存ノートに吸収 | 永続ノート・解説ノート・`30_Resources/クリップ/` |
| プロジェクト取り込み | 未検証アイデアや判断材料として記録 | 該当プロジェクトの `アイデア・検討.md` |
| ツール台帳 | ツール候補に1行追記 | `20_Areas/ソフトウェア開発/AI駆動開発.md` |
| 破棄 | 知見化しない主観・周知 | Inboxファイル削除 |

原文保管はL/P/Dテストで判断する。長文、プロジェクト判断材料、図表・数値・コードなど再現困難な一次情報を含む場合は保管する。

## タグ

| カテゴリ | タグ |
|---|---|
| システム | `MOC` `inbox` `archive` `clip/x` |
| ノート種別 | `reference` `idea` `paper` `experiment` `lecture` `project` `permanent` `draft` `dataset` `corpus` |
| トピック | `機械学習` `深層学習` `音源分離` `ソフトウェア開発` |
| モデル | `transformer` `bert` `ai` など |

タグは小文字英語または日本語に統一する。
