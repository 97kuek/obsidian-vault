---
date: 2026-07-15
tags:
  - 機械学習
  - 深層学習
  - transformer
aliases:
  - スパースTransformer
---
## Sparse Transformer

Sparse Transformerは、Self-Attentionの参照範囲を疎にすることで、長い系列に対する計算量とメモリ使用量を抑えるTransformerである。

## 背景

- 通常のSelf-Attentionは各位置が全位置を参照するため、系列長 $n$ に対して計算量とメモリ使用量が $O(n^2)$ となる。
- 参照先を限定しつつ、複数層を通して系列全体へ情報が伝わるパターンを設計することで、長期依存と効率を両立する。

## Factorized Self-Attention

- **Strided Attention**
  - 直近の位置と、一定間隔で離れた位置を参照する。
  - 複数層を重ねることで、直接参照しない位置の情報も伝播できる。
  - 周期性を持つ画像や音声と相性がよい一方、周期性の弱いテキストでは不利になる場合がある。
- **Fixed Attention**
  - 直近の位置と、あらかじめ定めた固定位置を参照する。
  - Strided Attentionが相対的な間隔に基づくのに対し、固定された参照先を使う点が異なる。

## 構成上の要点

- Factorized Attentionは、層ごとに異なる参照パターンを交互に使う、参照先を統合する、複数ヘッドへ割り当てる、といった方法で構成できる。
- Attentionパターンに応じた位置情報を加えることで、データ構造と参照関係の両方をモデルへ与える。
- Gradient Checkpointingなどの省メモリ手法を組み合わせることで、さらに大規模なモデルを扱いやすくする。

## 利点と注意点

- 長いコンテキストを通常のDense Attentionより少ない計算資源で扱える。
- 疎な参照でも、適切なパターンと層数によって広範囲の情報を統合できる。
- 最適な参照パターンはデータの構造に依存し、すべての系列へ同じパターンが有効とは限らない。

## 関連ノート

- [[Transformer]]
- [[大規模言語モデル2026_01_言語モデルの基礎とスケーリング]]

## 出典・根拠

- [Sparse Transformerを理解したい](https://zenn.dev/sunbluesome/articles/5f6a86dfa1e1be)
- Child et al., "Generating Long Sequences with Sparse Transformers," 2019.
