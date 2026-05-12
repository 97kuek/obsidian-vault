# Obsidian Vault ガイド

このファイルはClaude Codeがこのvaultで作業する際の規約・ルールをまとめたもの。

---

## Quick Start（まずここを読む）

**作業開始前に必ず行うこと：**
1. `VAULT_INDEX.md` を読んでファイル構成を把握する（`list_vault_files` で全探索しない）
2. 目的のファイルが分かったら `get_vault_file` で直接読む
3. 作業前に `git status` でVaultの状態を確認する

**よくある作業パターン：**
| 依頼 | 手順 |
|---|---|
| 新規ノート作成 | 命名規則・フロントマター規約を確認 → `create_vault_file` |
| ファイル検索 | `search_vault_simple`（キーワード）or `search_vault_smart`（意味） |
| MOC更新 | `get_vault_file` で読む → `create_vault_file` で上書き |
| 実験ノート追加 | `実験ノート用.md` テンプレートに従い `10_Projects/プロジェクト研究A/` に作成 |
| 論文メモ追加 | `論文ノート用.md` テンプレートに従い `30_Resources/音源分離/` に作成し `VAULT_INDEX.md` を更新 |

---

## Vault概要

PARAメソッド（Projects / Areas / Resources / Archives）をベースに構成された研究・学習用vault。

---

## フォルダ構成

| フォルダ | 用途 | 注意点 |
|---|---|---|
| `00_Inbox/` | 未整理ノートの一時置き場 | 定期的にレビューして振り分ける |
| `10_Projects/` | 期限・ゴールのあるアクティブな作業 | 完了したら `40_Archives/` へ移動 |
| `20_Areas/` | 継続的に管理するトピック | 終わりのない継続的関心事 |
| `30_Resources/` | 将来再利用できる参考資料・論文 | 特定プロジェクト専用でも可 |
| `40_Archives/` | 完了・不要なノート | 削除せずアーカイブ |
| `99_Templates/` | Templaterテンプレート | 実ノートではない |

---

## 現在のアクティブプロジェクト

- **プロジェクト研究A**：TF-Locoformerを使った日本語自然会話音声（J-CHAT）の音源分離
  - MOC: `10_Projects/プロジェクト研究A/【MOC】プロジェクト研究A.md`
  - 進捗: Phase3（TF-Locoformerの習熟）進行中
  - 実験環境: 研究室GPUサーバー g12（RTX 2080 Ti × 2）、ESPnet使用

---

## 触れてはいけないファイル・フォルダ

- `.obsidian/` 以下のファイル（Obsidian設定 — 変更するとアプリが壊れる）
- `*.pdf` ファイル（バイナリ — 操作不可）
- `99_Templates/` 以下（ユーザーが明示的に依頼した場合のみ編集可）

---

## ファイル命名規則

### 通常ノート・実験ノート
```
YYYYMMDD_タイトル.md
```
例：`20260511_音源分離実験用スクリプトの作成.md`

### MOCファイル
```
【MOC】タイトル.md
```
例：`【MOC】プロジェクト研究A.md`

### 論文読書メモ
```
論文タイトル略称_メモ.md
```
例：`TF-Locoformer_メモ.md`

---

## フロントマター規約

### 通常ノート・実験ノート
```yaml
date: YYYY-MM-DD
tags:
  - タグ
```

### MOCファイル
```yaml
tags:
  - MOC
aliases:
  - 別名1
created: YYYY-MM-DD
status: active
```

### 論文読書メモ
```yaml
date: YYYY-MM-DD
tags:
  - paper
title: ""
authors: ""
year: 
venue: ""
status: unread  # unread / reading / read
```

### 実験ノート
```yaml
date: YYYY-MM-DD
tags:
  - experiment
project: ""
environment: ""
```

---

## テンプレート使い分け

| テンプレート | 使うタイミング |
|---|---|
| `【MOC】.md` | 新しいトピックのMOCを作るとき |
| `プロジェクト用.md` | 10_Projects内の個別ノート |
| `論文ノート用.md` | 論文を読んで読書メモを作るとき |
| `実験ノート用.md` | 実験・作業ログを記録するとき |
| `授業ノート用.md` | 授業・勉強会のノート |
| `週次レビュー用.md` | 週次レビュー（毎週月曜推奨） |

**テンプレート変数（`<% tp.* %>`）は実ノートに残さず、必ず実際の値に置換すること。**

---

## MOC階層設計

```
Home
├── 10_Projects/
│   └── 【MOC】10_Projects
│       └── 【MOC】プロジェクト研究A
├── 20_Areas/
│   └── 【MOC】20_Areas
│       ├── 【MOC】ソフトウェア開発
│       └── 【MOC】機械学習・深層学習
│           └── 【MOC】B4勉強会
└── 30_Resources/
    └── 【MOC】30_Resources
```

各MOCには「関連MOC・上位MOC」セクションで親MOCにリンクする。
MOCの末尾には必ず `` **最終更新:** `= this.file.mtime` `` を入れること（自動更新）。

---

## タグ体系

| カテゴリ | タグ | 用途 |
|---|---|---|
| システム | `MOC` | Map of Content |
| システム | `inbox` | Inbox未整理ノート |
| システム | `archive` | アーカイブ済み |
| ノート種別 | `paper` | 論文読書メモ |
| ノート種別 | `experiment` | 実験ノート |
| ノート種別 | `lecture` | 授業・勉強会ノート |
| ノート種別 | `project` | プロジェクトノート |
| ノート種別 | `dataset` | データセット情報 |
| ノート種別 | `corpus` | コーパス情報 |
| トピック | `機械学習` | 機械学習全般 |
| トピック | `深層学習` | 深層学習全般 |
| トピック | `音源分離` | 音源分離・音声処理 |
| トピック | `ソフトウェア開発` | ソフトウェア開発全般 |
| モデル | `transformer` `bert` `ai` 等 | 各モデル・技術（小文字英語） |

**ルール：** タグは小文字英語または日本語に統一（`AI` → `ai`）。

---

## 検索の使い分け

| 用途 | 使うツール | 備考 |
|---|---|---|
| ファイル名・キーワードで探す | `search_vault_simple` | 高速 |
| 意味・内容で関連ノートを探す | `search_vault_smart` | セマンティック検索 |
| フォルダ内容を一覧する | `list_vault_files` | 必要最小限のフォルダのみ |
| ファイルの内容を読む | `get_vault_file` | パスが分かっているとき |

**VAULT_INDEX.mdを先に読めば `list_vault_files` の多用を避けられる。**

---

## Git作業フロー

Claudeに複数ファイルの作成・削除・リネームを依頼する前に必ずcommitすること。

```bash
git add -A && git commit -m "作業前スナップショット"
git diff HEAD    # 作業後の差分確認
```

---

## VAULT_INDEX.mdの更新ルール

ファイルを追加・削除・リネームしたら `VAULT_INDEX.md` を必ず更新する。
これによりClaude が次回の作業でファイル探索コストを最小化できる。

---

## センシティブ情報

現時点でセンシティブな情報が含まれるフォルダはなし。
APIキー・パスワード等が必要になった場合は `99_Private/` フォルダを作成し、`.gitignore` と CLAUDE.md に追記する。
