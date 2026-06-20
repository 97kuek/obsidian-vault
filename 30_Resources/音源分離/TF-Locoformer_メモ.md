---
date: 2026-05-12
tags:
  - paper
  - 音源分離
  - transformer
title: "TF-Locoformer: Transformer with Local Modeling by Convolution for Speech Separation and Enhancement"
authors: "Kohei Saijo, Gordon Wichern, François G. Germain, Zexu Pan, Jonathan Le Roux"
year: 2024
venue: "IWAENC 2024"
status: read
---
# TF-Locoformer 読書メモ

## 一言要約

時間・周波数軸のLocal/Global Attention（Loco = Local-Global）を組み合わせた音源分離Transformer。英語データセットでSOTA級。

## 背景・問題設定

Conv-TasNet等のCNNベース手法は局所的な依存関係を捉えるが、長距離依存が苦手。全系列を見るTransformerは計算量が問題。

## 提案手法

- Time-Frequency 2次元のTransformer構造
- Local Attention（短距離）+ Global Attention（長距離）を交互に適用（Loco構造）
- 計算効率を保ちつつ長距離依存を捉える

## 実験・結果

- WSJ0-2mix、WHAMR!、Libri2mix、DNSなどの英語データセットでSOTA相当
- 日本語自然会話音声（J-CHAT）への適用は未検証

## 気づき・メモ

- ESPnet互換実装あり
- 本研究の主要モデル → [[【MOC】プロジェクト研究A]]
- 日本語音声では英語モデルより性能低下が予想される

## 疑問・未解決

- [ ] 

## 関連ノート

- [[TasNet_メモ]]
- [[Conv-TasNet_メモ]]
- [[Transformer_メモ]]
- [[【MOC】プロジェクト研究A]]
