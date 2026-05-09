---
tags:
  - MOC
aliases: 
created: 2026-05-09
updated: 2026-05-09
status: active
---
## 研究概要

日本語自然会話音声コーパス**J-CHAT**を対象に、最新の音声分離モデル**TF-Locoformer**を適用し、日本語話者の重なり合った会話音声を分離する性能を検証する。
## 研究目的
TF-LocoformerはWSJ0-2mixなど英語音声データセットでSOTA級の性能を示している音源分離モデルだが、日本語の自然会話音声に対する有効性は十分に検証されていない。本研究では以下を目的とする。

- 研究室GPU環境を用いた深層学習音声分離パイプラインの構築・運用スキルの習得
- TF-Locoformer (ESPnet互換版) の実装理解と、独自データへの適用方法の習得
- 日本語自然会話コーパスJ-CHATにおける音声分離の実現可能性検証
## タスク一覧
### Phase1 : 音声分離の基礎理解・環境構築
- [x] [[TasNet.pdf]]
- [x] [[Conv-TasNet.pdf]]
- [x] [[Transformer.pdf]]
- [ ] [[TF-Locoformer.pdf]]
- [ ] [[音声対話言語モデルのための大規模日本語対話音声コーパス.pdf]]
- [x] [[【MOC】B4勉強会]]
- [ ] https://qiita.com/yuAbe/items/e462560da51b886aa321
- [ ] 研究室GPUマシンへのSSH接続・アカウント作成
- [ ] CUDA/cuDNN/PyTorch環境の確認
- [x] `Conda`による仮想環境の準備
- [x] GPU動作確認
- [ ] 楠さんとの打ち合わせ
### Phase2 : TF-Locoformerのセットアップ
- [ ] リポジトリのクローン
- [ ] `1. ESPnet compatible code`の依存関係インストール
- [ ] ESPnet本体のセットアップ(recipeディレクトリ構成の理解)
- [ ] 公開済み学習済みモデルでの推論動作確認
### Phase3 : TF-Locoformerの習熟
- [ ] ESPnetのrecipe構造(`egs2/`,`conf/`,`local/`,`run.sh`)の把握
- [ ] 設定ファイル(`yaml`)の読み書き
- [ ] WSJ0-2mix等の標準データセットでの再現実験
- [ ] 学習・評価のログとメトリクスの確認方法
- [ ] 問題が出やすいポイントの整理(データパス、サンプリングレート、チャネル数など)
### Phase4 : J-CHATへの適用
- [ ] J-CHATコーパスの取得・ライセンス確認
- [ ] データ仕様の把握(サンプリングレート、話者数、混合の有無など)
- [ ] J-CHAT用のデータ前処理スクリプト作成(ESPnetのdata.sh/scp形式に合わせる)
- [ ] ESPnetのrecipeをJ-CHAT用に改変(`egs2/jchat/enh1/`のような構成を新規作成)
- [ ] ファインチューニングorスクラッチ学習の実施
- [ ] 評価(客観指標+可能なら聴取確認)
### Phase5 : 結果分析・まとめ
- [ ] 英語データセット(WSJ0-2mix)との性能比較
- [ ] 失敗ケースの分析(どんな会話で分離が難しいか)
- [ ] レポート・スライド作成

## 関連MOC・上位MOC

- 上位: 
- 関連: [[機械学習・深層学習 MOC]]​```

## メモ・気づき

---
**Last reviewed:** {{date:YYYY-MM-DD}}