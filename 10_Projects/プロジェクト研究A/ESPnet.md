---
date: 2026-05-09
tags:
  - 機械学習
  - 深層学習
  - 音源分離
---
## 目的
音声処理のための研究用フレームワーク、`ESPnet`について理解することを目的とする。

## ESPnetとは何か

- **音声処理のための研究用フレームワーク**
- 音声認識・音声合成・音声分離など、様々な音声タスクに対応
- **recipe**という単位で実験を管理するという設計思想を持っている
- 料理のレシピと同じで、「この材料（データ）を、この手順（スクリプト）で、この設定（yaml）で調理（学習）する」というのが一セット

```
ESPnet
├── espnet/          ← ESPnet本体のPythonコード（モデル定義など）
├── espnet2/         ← 新しいAPIのPythonコード
└── egs2/            ← recipe置き場 ★ここが実験の作業場
```
## `egs2/` の構造

- `egs2/` の中は**データセット名**ごとにディレクトリが分かれている

```
egs2/
├── wsj0_2mix/       ← WSJ0-2mixデータセット用
├── librimix/        ← LibriMixデータセット用
├── chime4/          ← CHiME-4データセット用
└── （あなたが作る）
    jchat/           ← J-CHATデータセット用（Phase4で作成）
```

- さらにその中は**タスク名**で分かれている

```
egs2/wsj0_2mix/
├── enh1/            ← enhancement（音声強調・分離）タスク
├── asr1/            ← ASR（音声認識）タスク
└── se1/             ← speech enhancement タスク
```

- 今回使うのは `enh1/`（音声分離）

```
egs2/wsj0_2mix/enh1/    ← ここが実験の「作業ディレクトリ」
├── run.sh
├── conf/
├── local/
└── (実行後に生成されるディレクトリ)
    ├── data/
    ├── exp/
    └── dump/
```
## `run.sh` — 実験全体の司令塔

- `run.sh` はすべての起点となるスクリプト
- ここを実行すると、データ準備から学習・評価まで一通り流れる仕様

### 実行の仕方

```bash
# 全ステージを最初から最後まで実行
./run.sh

# stage1だけ実行（データ準備だけ）
./run.sh --stage 1 --stop_stage 1

# stage5から実行（学習から再開）
./run.sh --stage 5
```

- `--stage` と `--stop_stage` で**どこからどこまで実行するか**を制御
- データ準備は済んでいるから学習だけやり直したいというときに使用

### ステージの中身

- `run.sh` の中は以下のようなステージに分かれている（enh1の場合）

```
Stage 1: データ準備
    └── local/data.sh を呼び出す
        └── ESPnet形式のデータディレクトリ(data/)を作る

Stage 2: 速度摂動（データ拡張・任意）
    └── 音声を0.9倍速・1.1倍速などに変換してデータを水増し

Stage 3: 特徴量の形式変換
    └── 音源分離では波形(wav)をそのまま使うことが多いので
        このステージはスキップされることも多い

Stage 4: 統計量の計算
    └── 正規化（平均・分散）のための統計量を計算・保存

Stage 5: モデルの学習  ← メイン
    └── conf/train_enh_*.yaml の設定で学習開始

Stage 6: 推論（デコード）
    └── 学習済みモデルでテストデータを分離

Stage 7: 評価
    └── SI-SDR, SDRiなどの指標を計算して結果を出力
```

### run.shの冒頭部分（変数定義）

- `run.sh` の最初の方には設定変数がたくさん並んでいる

```bash
# どこから学習を始めるか
stage=1
stop_stage=100

# 使うGPUのID（0番目のGPUを使う）
gpu_id=0

# データセットの置き場所（自分の環境に合わせて変える）
wsj0_2mix=/path/to/wsj0_2mix

# 使うyamlファイルの名前（conf/の中から選ぶ）
train_config=conf/train_enh_tf_locoformer.yaml

# 実験結果の保存先ディレクトリ名
expdir=exp/enh_tf_locoformer
```

- **一番よく変更するのは `wsj0_2mix=` のパス部分**
## `conf/` — 実験の設定ファイル

- `conf/` の中には `.yaml` ファイルが入ってる
- ここで**モデルの構造・学習の設定**を決める

```
conf/
├── train_enh_tf_locoformer.yaml   ← TF-Locoformerを使う設定
├── train_enh_conv_tasnet.yaml     ← Conv-TasNetを使う設定（比較用）
├── decode_enh.yaml                ← 推論時の設定
└── slurm.conf                     ← ジョブスケジューラの設定
```

### `train_enh_tf_locoformer.yaml` の読み方

- 大きく4つのブロックに分かれている

```yaml
# =========================================
# 1. エンコーダ（波形→特徴量）
# =========================================
encoder: stft
encoder_conf:
    n_fft: 512          # FFTのサイズ
    hop_length: 128     # フレームシフト（サンプル数）
    win_length: 512     # 窓関数の長さ

# =========================================
# 2. 分離ネットワーク（特徴量→マスク）
# =========================================
separator: tflocoformer
separator_conf:
    n_layers: 6         # Transformerの層数
    n_heads: 8          # Attentionのヘッド数
    n_imics: 1          # 入力マイク数（モノラルなら1）
    n_spks: 2           # 分離する話者数

# =========================================
# 3. デコーダ（マスク→分離波形）
# =========================================
decoder: stft
decoder_conf:
    n_fft: 512
    hop_length: 128

# =========================================
# 4. 学習設定
# =========================================
optim: adam
optim_conf:
    lr: 1.0e-3          # 学習率

batch_size: 16
max_epoch: 100

# 損失関数（SI-SNRを使う）
criterions:
    - name: si_snr
      weight: 1.0
```

**J-CHATに適用する際に変更が必要になりやすい箇所：**

- `n_spks`: 何人の話者を分離するか
- `n_fft`, `hop_length`: データのサンプリングレートに合わせて調整

### `decode_enh.yaml` の中身

- 推論時の設定はシンプル

```yaml
# 推論時にどのチェックポイントを使うか
inference_enh_conf:
    normalize_output_wav: true   # 出力波形を正規化するか
```
## `local/` — データセット固有の処理

- `local/` はrecipeの中で最も「手を入れる」場所
- J-CHAT用recipeを作るときも、ここを書き直すことになる

```
local/
├── data.sh       ← データ準備のメインスクリプト ★最重要
└── path.sh       ← データのパスを定義
```

### ESPnetのデータ形式を理解する

- ESPnetは **kaldi形式** と呼ばれる独自のデータ形式を使用する
- 学習前にまずデータをこの形式に変換する必要がある
- `local/data.sh` を実行すると、以下のようなディレクトリが生成される

```
data/
├── tr/              ← 学習データ（training）
│   ├── wav.scp          ← 混合音声のパス一覧
│   ├── spk1.scp         ← 話者1のクリーン音声パス一覧
│   ├── spk2.scp         ← 話者2のクリーン音声パス一覧
│   ├── utt2spk          ← 発話ID→話者のマッピング
│   └── spk2utt          ← 話者→発話IDのマッピング
├── cv/              ← 検証データ（validation）
│   └── （同上）
└── tt/              ← テストデータ（test）
    └── （同上）
```

### `wav.scp` の形式（最重要ファイル）

- `wav.scp` はESPnetのデータ管理の核心

```
# 形式: <発話ID>  <wavファイルへの絶対パス>

mix_001  /data/wsj0_2mix/tr/mix/001.wav
mix_002  /data/wsj0_2mix/tr/mix/002.wav
mix_003  /data/wsj0_2mix/tr/mix/003.wav
```

- 音源分離では、混合音(mix)と正解の分離音(spk1, spk2)でそれぞれ別の`.scp`ファイルが必要

```
# wav.scp（モデルへの入力）
mix_001  /data/wsj0_2mix/tr/mix/001.wav

# spk1.scp（正解ラベル1）
mix_001  /data/wsj0_2mix/tr/s1/001.wav

# spk2.scp（正解ラベル2）
mix_001  /data/wsj0_2mix/tr/s2/001.wav
```

- **発話IDが3つのファイルで一致している**ことが重要
- ESPnetはIDでデータを紐付けるので、IDがずれると学習できない

### `data.sh` が内部でやっていること

```bash
# data.sh の処理の流れ（イメージ）

# 1. 元データのファイルパスを収集
find /data/wsj0_2mix/tr/mix -name "*.wav" | sort > mix_paths.txt

# 2. 発話IDを付けてwav.scpを作る
paste id_list.txt mix_paths.txt > data/tr/wav.scp

# 3. 同様にspk1.scp, spk2.scpも作る

# 4. utt2spkを作る
# （音声分離では話者情報が不要なことも多いので簡略化される）
```
## 実験実行後に生成されるディレクトリ

- `run.sh` を実行すると、以下のディレクトリが自動的に生成される

```
egs2/wsj0_2mix/enh1/
├── data/          ← Stage1で生成（kaldi形式のデータ）
├── dump/          ← Stage3で生成（特徴量のキャッシュ）
└── exp/           ← Stage5以降で生成（実験結果）
    └── enh_tf_locoformer/
        ├── train.log          ← 学習ログ
        ├── valid.loss.best    ← 最良モデルのチェックポイント
        ├── config.yaml        ← 実験の設定（コピー）
        └── decode_tt/         ← テスト結果
            └── si_snr         ← 評価スコア
```

- **`exp/` の中は実験の「成果物」なので、消さないように注意** 
- 学習が途中で落ちても、チェックポイントが残っていれば再開できる

## 全体のデータの流れ（まとめ）

```
元データ（wav files）
    ↓  Stage 1: local/data.sh
data/ （kaldi形式：wav.scp, spk1.scp, spk2.scp）
    ↓  Stage 4: 統計量計算
dump/ （正規化情報）
    ↓  Stage 5: 学習（conf/train_enh_*.yaml の設定で）
exp/ （学習済みモデル・ログ）
    ↓  Stage 6: 推論
exp/decode_tt/ （分離音声）
    ↓  Stage 7: 評価
SI-SDR, SDRiのスコア
```

## 7. よくつまずくポイント

実際に動かすと高確率でハマる箇所を先に挙げておきます。

**パスの問題**

```bash
# run.shの冒頭のパス指定が間違っている → Stage1で即エラー
wsj0_2mix=/path/to/wsj0_2mix  ← ここが一番多い
```

**サンプリングレートの不一致**

```yaml
# データが16kHzなのにyamlが8kHz想定になっている → 学習が発散する
# conf/train_enh_*.yaml の n_fft などを確認
```

**wav.scpのIDがずれている**

```
# mix.scp と spk1.scp の発話IDが1行ずれている → 全データがミスマッチ
# 生成後に head data/tr/wav.scp と head data/tr/spk1.scp を並べて確認する
```

**GPU番号の指定ミス**

```bash
# run.sh の gpu_id が違う → 他人のジョブと競合する
# nvidia-smi で空いているGPUを確認してから指定
```
