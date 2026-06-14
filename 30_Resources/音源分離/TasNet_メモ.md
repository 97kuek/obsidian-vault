---
date: 2026-05-12
tags:
  - paper
  - 音源分離
title: "TasNet: time-domain audio separation network for real-time, single-channel speech separation"
authors: "Luo, Yi and Mesgarani, Nima"
year: 2018
venue: "IEEE/ACM TASLP"
status: read
---
# TasNet 読書メモ

## 一言要約

エンコーダ-デコーダ構造で時間領域の音声を直接処理する音源分離ネットワーク。

## 背景・問題設定

従来の周波数領域ベースの手法（STFT）は位相推定の問題があった。TasNetはこれを回避するため、時間領域で直接処理する。

## 提案手法

- Convolutional Encoder/Decoder で波形を直接扱う
- LSTM で混合音声の特徴を話者ごとの分離マスクに変換
- 周波数変換不要で波形レベルの損失を最小化

## 実験・結果

WSJ0-2mixデータセットで評価。従来のSTFTベース手法を上回る。

## 気づき・メモ

- [[Conv-TasNet_メモ]] はLSTMをTCNに置き換えた後継モデル

## 疑問・未解決

- [ ] 

## 関連ノート

- [[Conv-TasNet_メモ]]
- [[TF-Locoformer_メモ]]
- [[【MOC】プロジェクト研究A]]
