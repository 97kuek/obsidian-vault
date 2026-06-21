---
date: 2026-05-12
tags:
  - paper
  - transformer
title: "Attention Is All You Need"
authors: "Vaswani et al."
year: 2017
venue: "NeurIPS 2017"
status: read
---
# Transformer 読書メモ

## 一言要約

RNN・CNNを使わずSelf-Attentionのみで系列変換を実現。現代のLLM・音源分離モデルすべての基盤となった。

## 提案手法

- Scaled Dot-Product Attention
- Multi-Head Attention（複数の視点で関係を学習）
- Positional Encoding（位置情報を明示的に付与）
- Encoder-Decoder 構造

## 実験・結果

機械翻訳（WMT 2014）でSOTA。学習速度・精度ともに従来手法を大幅に上回る。

## 気づき・メモ

- 概念ノート: [[Transformer]]
- 勉強会での詳しい解説: [[20260430_勉強会03]]
- 音源分離への応用: [[TF-Locoformer_メモ]]

## 疑問・未解決

- [ ] 

## 関連ノート

- [[TF-Locoformer_メモ]]
- [[20260430_勉強会03]]
- [[Transformer]]
