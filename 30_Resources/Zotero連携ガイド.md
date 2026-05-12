---
date: 2026-05-12
tags:
  - ソフトウェア開発
  - reference
---
# Zotero連携ガイド

論文管理ツール Zotero とこのVaultを連携し、論文取り込み・メタデータ自動入力・引用管理を一元化する手順。

## 必要なもの

| ツール | 説明 | 入手先 |
|---|---|---|
| Zotero | 論文管理ツール本体（無料） | zotero.org |
| Better BibTeX for Zotero | Zoteroプラグイン。引用キーの自動生成 | retorque.re/zotero-better-bibtex/ |
| obsidian-zotero-integration | ObsidianプラグイN。ZoteroからObsidianへ転送 | Obsidian Community Plugins |

## セットアップ手順

### 1. Zoteroのセットアップ

1. Zotero をインストール
2. Zotero のプラグイン管理から **Better BibTeX** をインストール
3. 設定 → Better BibTeX → 引用キーのフォーマットを設定（推奨：`[auth:lower][year]`）
   - 例：Vaswani et al. 2017 → `vaswani2017`

### 2. Obsidianプラグインのセットアップ

1. Obsidian → 設定 → コミュニティプラグイン → `Zotero Integration` をインストール・有効化
2. プラグイン設定で以下を設定：
   - **Database**: Zotero
   - **PDF Utility**: `pdfannots2json`（必要に応じてインストール）
   - **Note Import Location**: `30_Resources/`
   - **Template File**: `99_Templates/論文ノート用.md`

### 3. 論文の取り込み方

```
1. ブラウザでZotero Connectorを使い論文をZoteroに保存
2. Obsidianのコマンドパレット → 「Zotero Integration: Create Note」
3. Zoteroから論文を選択 → 自動でノートが作成される
```

### 4. 引用の挿入

論文中で他の論文を引用するとき：
```
コマンドパレット → 「Zotero Integration: Insert Citation」
```

## 現在の状況

- [ ] Zoteroインストール
- [ ] Better BibTeXインストール
- [ ] obsidian-zotero-integrationインストール
- [ ] テスト論文で動作確認

## 注意点

- 既存の `30_Resources/音源分離/` にある論文PDFはZotero管理外。連携後は新規論文をZoteroに登録してから取り込む。
- PDFのパスが変わるとリンクが切れるため、Zotero管理に移行したPDFは手動でリンクを更新する。
