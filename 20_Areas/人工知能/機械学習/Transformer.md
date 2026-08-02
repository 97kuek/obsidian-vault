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
  - Sparse Transformer
  - スパースTransformer
---
## Transformer

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
- 学習時は各トークン位置の損失を並列計算できるが、自己回帰生成時は、それまでのトークンを使って次のトークンを順番に生成する。
- 一般的なTransformerでは、Position-wise FFNが多くのパラメータを占める。
- Attention score行列 $QK^\top$ はQueryとKeyに異なる変換を使うため、一般には対称行列にならない。
- 限界：Attentionの計算量が系列長に対して $O(n^2)$ で増える。長い系列では計算・メモリ負荷が重い。
- 位置情報を明示的に入れないと、系列順序を区別できない。

## Sparse Transformerによる長系列化

Sparse Transformerは、Self-Attentionの参照範囲を疎にすることで、長い系列に対する計算量とメモリ使用量を抑える手法である。通常のSelf-Attentionは系列長 $n$ に対して $O(n^2)$ の計算量とメモリを必要とするが、参照先を限定し、複数層を通じて系列全体へ情報を伝えることで効率と長期依存を両立する。

### Factorized Self-Attention

- **Strided Attention**
  - 直近の位置と一定間隔で離れた位置を参照する。
  - 複数層を重ねることで、直接参照しない位置の情報も伝播できる。
  - 周期性を持つ画像や音声と相性がよい一方、周期性の弱いテキストでは不利になる場合がある。
- **Fixed Attention**
  - 直近の位置と、あらかじめ定めた固定位置を参照する。
  - Strided Attentionが相対的な間隔に基づくのに対し、固定された参照先を使う点が異なる。

Factorized Attentionは、層ごとに異なる参照パターンを交互に使う、参照先を統合する、複数ヘッドへ割り当てる、といった方法で構成できる。Attentionパターンに応じた位置情報やGradient Checkpointingを組み合わせることで、さらに大規模なモデルを扱いやすくなる。

- 利点：長いコンテキストをDense Attentionより少ない計算資源で扱える。
- 注意点：最適な参照パターンはデータ構造に依存し、すべての系列へ同じパターンが有効とは限らない。

## 他の概念との関係

- 応用: [[TF-Locoformer_メモ]]（音源分離向けにTransformerを時間・周波数方向へ拡張）
- 関連: [[20260430_勉強会03]]（TransformerとGPTの勉強会メモ）
- 出典: [[Transformer_メモ]]（Attention Is All You Need）

## 出典・根拠

- [[Transformer_メモ]] — Attention Is All You Need
- [[20260430_勉強会03]] — Transformer・GPTの勉強会メモ
- [Sparse Transformerを理解したい](https://zenn.dev/sunbluesome/articles/5f6a86dfa1e1be)
- Child et al., "Generating Long Sequences with Sparse Transformers," 2019.
