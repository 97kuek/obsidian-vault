---
date: 2026-06-21
tags:
  - 機械学習
  - 深層学習
  - transformer
aliases:
  - Transformer
  - トランスフォーマー
  - Self-Attention
  - Attention
  - Multi-Head Attention
---
# Transformer

Transformerは、RNNやCNNではなく**Self-Attentionを中心に系列を処理する**深層学習アーキテクチャである。長距離依存を扱いやすく、並列計算しやすいことから、LLMや音源分離モデルの基盤になった。

## 核心的な主張

- RNNは系列を順番に処理するため並列化しにくく、長い文では初期情報が薄れやすい。
- Transformerは各位置が他の全位置を直接参照するため、任意の2トークン間の関係を少ないステップで扱える。
- Attentionは「どの入力にどれだけ注目するか」を重みとして計算し、その重みでValueを加重和する仕組みである。

## Attentionの基本

Scaled Dot-Product Attentionは、Query、Key、Valueを使って次のように計算する。

1. QueryとKeyの内積で関連度スコアを出す。
2. $\sqrt{d_k}$ で割ってスケールを整える。
3. softmaxで注意重みに変換する。
4. 注意重みでValueを加重和する。

Multi-Head Attentionでは、この処理を複数のヘッドで並列に行う。1つの視点ではなく、複数の関係性を同時に見るためである。

## 構成要素

- **Encoder**：入力系列全体を双方向に見て、文脈を反映した表現を作る。
- **Decoder**：未来位置をマスクしながら、これまでに生成した系列とEncoder出力を使って次トークンを予測する。
- **Self-Attention**：同じ系列内の位置どうしの関係を見る。
- **Cross-Attention**：Decoder側のQueryがEncoder出力のKey/Valueを参照する。
- **Position-wise FFN**：Attention後の各位置を独立に非線形変換する。
- **Positional Encoding**：Attentionだけでは順序が分からないため、位置情報を明示的に与える。
- **Add & Norm**：残差接続とLayer Normalizationで深いモデルの学習を安定させる。

## 利点と限界

- 利点：並列化しやすい、長距離依存を扱いやすい、モデルを大きくしたときに性能を伸ばしやすい。
- 限界：Attentionの計算量が系列長に対して $O(n^2)$ で増える。長い系列では計算・メモリ負荷が重い。
- 位置情報を明示的に入れないと、系列順序を区別できない。

## 他の概念との関係

- 応用: [[TF-Locoformer_メモ]]（音源分離向けにTransformerを時間・周波数方向へ拡張）
- 関連: [[20260430_勉強会03]]（TransformerとGPTの勉強会メモ）
- 出典: [[Transformer_メモ]]（Attention Is All You Need）

## 出典・根拠

- [[Transformer_メモ]] — Attention Is All You Need
- [[20260430_勉強会03]] — Transformer・GPTの勉強会メモ
