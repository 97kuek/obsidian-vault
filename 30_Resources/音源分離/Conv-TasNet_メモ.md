---
date: 2026-05-12
tags:
  - paper
  - 音源分離
title: "Conv-TasNet: Surpassing Ideal Time–Frequency Magnitude Masking for Speech Separation"
authors: "Luo, Yi and Mesgarani, Nima"
year: 2019
status: read
---
# Conv-TasNet 読書メモ

![[Conv-TasNet.pdf]]

## 一言要約

TasNetのLSTMをTemporal Convolutional Network（TCN）に置き換え、精度・速度を大幅改善。理想的なT-Fマスキングを超える性能を達成。

## 背景・問題設定

TasNetのLSTMは計算量が多く、リアルタイム処理が難しかった。並列化が困難で長い系列の処理も遅い。

## 提案手法

- Temporal Convolutional Network（TCN）ベースの分離モジュール
- Depthwise Separable Convolutionで効率化
- 時間領域エンコーダ・デコーダ構造は TasNet を踏襲

## 実験・結果

WSJ0-2mixでSOTA（2019年当時）。理想的なIBMを超えるSDRを達成。

## 気づき・メモ

- [[TasNet_メモ]] の後継
- [[TF-Locoformer_メモ]] はTransformerでさらに発展

## 関連ノート

- [[TasNet_メモ]]
- [[TF-Locoformer_メモ]]
- [[【MOC】プロジェクト研究A]]
