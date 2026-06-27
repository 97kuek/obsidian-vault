# Vault Review

Obsidian vault の軽い健康診断を行う。毎週から隔週を目安に、検出と提案までを行う。削除・リネーム・統合は必ずユーザー確認後に実行する。

## 事前準備

`VAULT_INDEX.md` と vault の命名規則を読む。

機械的チェックは PowerShell の `tools/vault-review.ps1` を優先して使う。

```powershell
.\tools\vault-review.ps1
```

個別に確認する場合:

```powershell
.\tools\vault-review.ps1 -Check Links
.\tools\vault-review.ps1 -Check Naming
.\tools\vault-review.ps1 -Check Structure
.\tools\vault-review.ps1 -Check Index
.\tools\vault-review.ps1 -Check Inbox
.\tools\vault-review.ps1 -Check Mocs
```

## チェック項目

1. 切れリンク
   - 存在しない `[[wiki link]]` を検出する。
   - 削除由来の可能性がある場合は、リンク削除より復元を優先して提案する。
2. 命名規約
   - 知識ノートに日付プレフィックスが付いていないか。
   - 論文メモが `_メモ.md` で終わっているか。
   - 日次以外で `YYYY-MM-DD_` を使っていないか。
3. `VAULT_INDEX.md` 整合性
   - 索引にあるが実在しないファイル。
   - 実在するが索引に載っていない主要ノート。
4. ノート構造
   - 必須 frontmatter、H1、テンプレート変数の残存を検出する。
   - 見出しレベルの飛び、`Topic4` のような表記揺れを検出する。
   - `VAULT_INDEX.md` の `updated` が点検日と一致するか確認する。`updated` は自動バックアップ（git auto-commit）で毎回更新されるため、通常は当日日付になっている。ずれている場合はファイルが長期間変更されていないサインとして扱う。
5. Inbox
   - `00_Inbox/` に未整理ノートがあるか。
6. 孤立ノート
   - MOC や他ノートから参照されていない候補を読む。
7. MOC 更新漏れ
   - 各 MOC と対応フォルダを照合する。
8. 週次・月次レビューノート
   - 今日が作成日ならテンプレートから作成を提案する。

## サマリー

```markdown
## Vault Review サマリー（YYYY-MM-DD）

### 切れリンク
- 件数・該当

### 命名規約
- 違反件数・該当ファイルとリネーム案

### VAULT_INDEX
- MISSING / UNLISTED 件数

### Inbox
- 件数・対応が必要なもの

### 孤立ノート
- 検出数・ノート名一覧

### MOC更新漏れ
- 漏れているノート一覧

### 推奨アクション
1. ...
```
