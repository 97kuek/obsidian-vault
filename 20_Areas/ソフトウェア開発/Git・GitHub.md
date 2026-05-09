---
date: 2026-05-08
tags:
  - git
  - github
  - command
  - ソフトウェア開発
---
## コマンド集
### clone
```bash
git clone ブランチ名（もしくはURL）
```
### init
```bash
# カレントディレクトリ
git init
# ディレクトリ指定
git init ディレクトリ名
```
### remote
```bash
# リモートリポジトリ名を表示
git remote
# リモートリポジトリ名とURL表示
git remote -v
```
### branch
```bash
# ローカルリポジトリのbranchを一覧表示
git branch
# branchを削除（mergeされていないbranchのみ）
git branch -d ブランチ名
# branchを削除
git branch -D ブランチ名
```
### checkout
```bash
# ブランチの切り替え
git checkout ブランチ名
# ブランチの作成
git checkout -b ブランチ名
```
### push
```bash
git push
```
### pull
```bash
# リモートリポジトリのすべての変更内容を取得
git pull
# 指定したリポジトリのブランチの変更内容を取得
git pull リモートリポジトリ名 ブランチ名
# デフォルトのリモートリポジトリ名はorigin
git pull origin ブランチ名
```
## コミットメッセージのルール
### 1. Prefixを書く
- `feat`: 新しい機能
- `fix`: バグの修正
- `docs`: ドキュメントのみの変更
- `style`: 空白、フォーマット、セミコロン追加など
- `refactor`: 仕様に影響がないコード改善
- `perf`: パフォーマンス向上関連
- `test`: テスト関連
- `chore`: ビルド、補助ツール、ライブラリ関連
### 2. 理由を書く
```bash
feat: 〇〇なため、△△を追加
```
## ブランチ運用ルール
### Git flow
- `master`: 実際の製品ファイルを置くブランチ、リリースしたらタグ付けする
- `develop`: 開発ブランチ。リリース前の最新ブランチ。
- `feature`: 追加機能やバグ修正を行う開発用のブランチ。`develop`ブランチから分岐し、ソース修正後に`develop`ブランチにマージ
- `release`: リリース前に準備や微調整を行うブランチ。`develop`ブランチから分岐してタグ付け、調整後は`master`ブランチにマージ
- `hot-fix`: `master`ブランチで緊急修正。
### GitHub flow
- `master`: 常時デプロイ可能である。（常に安定しているブランチで、リリース可能な状態であるということ）
- `作業用ブランチ`: `master`ブランチから分岐し、`master`ブランチにマージする。ブランチ名はなんの作業をしているかわかるようにする。
1. `master`ブランチは、常時デプロイ可能な状態を保つ  
2. 全てのブランチは`master`ブランチから作成する  
3. 作業内容が分かるようなブランチ名をつける 例）`feature-user-icon`, `fix-login-animation`
4. 作業中のブランチは定期的にプッシュする  
5. Githubのプルリクエストを利用してレビューを行なってから、`master`ブランチにマージする 
6. マージされた`master`ブランチのコードはすぐにデプロイする  
7. デプロイ後は速やかに作業していたブランチを削除する**
## 参考文献
- [Gitコマンド一覧](https://zenn.dev/zmb/articles/054ba4189244a5)