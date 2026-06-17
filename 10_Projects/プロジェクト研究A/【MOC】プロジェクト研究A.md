---
tags:
  - MOC
aliases:
  - 研究A
  - 音源分離研究
  - プロジェクトA
created: 2026-05-09
status: active
---
## 研究概要

日本語自然会話音声コーパス**J-CHAT**を対象に、最新の音声分離モデル**TF-Locoformer**を適用し、日本語話者の重なり合った会話音声を分離する性能を検証する。

## 研究目的

- 研究室GPU環境を用いた深層学習音声分離パイプラインの構築・運用スキルの習得
- TF-Locoformer (ESPnet互換版) の実装理解と、独自データへの適用方法の習得
- 日本語自然会話コーパスJ-CHATにおける音声分離の実現可能性検証

## 実験ノート

```dataview
LIST
FROM "10_Projects/プロジェクト研究A"
WHERE contains(tags, "experiment")
SORT date DESC
```

## 参考論文・リソース

- [[TF-Locoformer_メモ]]
- [[J-CHAT_メモ]]
- [[Transformer_メモ]]
- [[TasNet_メモ]]
- [[Conv-TasNet_メモ]]
- [[RemixIT_メモ]]
- [[執筆ロードマップ]]

## 実験結果

- [[実験結果まとめ]]

## タスク一覧

### Phase1 : 音声分離の基礎理解・環境構築
- [x] [[TasNet_メモ]]
- [x] [[Conv-TasNet_メモ]]
- [x] [[Transformer_メモ]]
- [x] [[TF-Locoformer_メモ]]
- [x] [[J-CHAT_メモ]]
- [x] [[【MOC】B4勉強会]]
- [x] 研究室GPUマシンへのSSH接続・アカウント作成
- [x] CUDA/cuDNN/PyTorch環境の確認
- [x] `Conda`による仮想環境の準備
- [x] GPU動作確認
- [x] 楠さんとの打ち合わせ

### Phase2 : TF-Locoformerのセットアップ
- [x] リポジトリのクローン
- [x] `1. ESPnet compatible code`の依存関係インストール
- [x] ESPnet本体のセットアップ
- [x] 公開済み学習済みモデルでの推論動作確認

### Phase3 : TF-Locoformerの習熟
- [ ] [[ESPnet]]のrecipe構造(`egs2/`,`conf/`,`local/`,`run.sh`)の把握
- [ ] 設定ファイル(`yaml`)の読み書き
- [x] WSJ0-2mix等の標準データセットでの再現実験
- [ ] 学習・評価のログとメトリクスの確認方法
- [ ] 問題が出やすいポイントの整理(データパス、サンプリングレート、チャネル数など)

### Phase4 : J-CHATへの適用
- [ ] J-CHATコーパスの取得・ライセンス確認
- [ ] データ仕様の把握(サンプリングレート、話者数、混合の有無など)
- [ ] J-CHAT用のデータ前処理スクリプト作成
- [ ] ESPnetのrecipeをJ-CHAT用に改変
- [ ] ファインチューニングorスクラッチ学習の実施
- [ ] 評価(客観指標+可能なら聴取確認)

### Phase5 : 結果分析・まとめ
- [ ] 英語データセット(WSJ0-2mix)との性能比較
- [ ] 失敗ケースの分析
- [ ] レポート・スライド作成

## 関連MOC・上位MOC

- 上位: [[【MOC】10_Projects]]
- 関連: [[【MOC】機械学習・深層学習]]

## メモ・気づき

---
**最終更新:** `= this.file.mtime`
