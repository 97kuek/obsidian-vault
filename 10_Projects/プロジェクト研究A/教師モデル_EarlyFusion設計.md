---
date: 2026-06-17
tags:
  - 音源分離
  - project
project: プロジェクト研究A
status: active
---
- パイプライン②「教師あり事前学習＝教師モデル」の実装詳細。全体像は[[研究設計（パイプライン全体）]]。

## 要点

- 2ch拡張は**Early Fusion**を採用
- TF-Locoformer自体は単ch版を流用、変更は入力Conv2dのch数のみ
- この設定では**ILD**が支配的な手掛かり。装着マイクは非アレイなのでIPD/ビームフォーミングの前提が弱い
- 評価はシミュレーションのhold-outでSI-SNR/SDRを測る
- 設計の順番としては、Early Fusion → IPD ablation → シミュレーションの残響付与 → 複雑さが出たらMiddle fusion

## D1楠さんからのアドバイス

- 評価について：実データは正解がないのでSI-SNR等が測れない → シミュデータの一部を評価に使うのがよさそう
- 手法について：2ch入力への拡張は具体的に何をした？、他のfusion方式は検討していないのか？

## 評価方針

- `SimulatedEgoMixtureDataset` がクリーン音源から正解つきの2ch混合を生成しているので、そこから固定（`deterministic`）の検証セットを切り出せば **SI-SNR / SDRi** が測れる
- 今のシミュレーションは残響・雑音なしの自由空間モデル → 実データとのギャップ（残響など）は将来`pyroomacoustics`で詰める

## Early Fusion

- Early Fusion＝ch統合を**入力段階**で行う方式

### 入力

- 2chの複素STFTをそれぞれ実部・虚部に分解 → `[B, 4, T, F]`（ch0/ch1 の real・imag）にスタック
- IPDを足す場合は cos/sin の2枚が加わり `[B, 6, T, F]`

### モデル

- 変更点は **入力 Conv2d の `in_channels` だけ**（2 → 4、IPDありで6）
- この最初のConv2dで4枚の特徴マップを `emb_dim` 枚に線形結合 → **ここで2chが混ざる**
- 通過後は `[B, emb_dim, T, F]` でchの概念が消える
- TFLocoformerBlock本体は **単ch版をそのまま流用**

### 出力

- デコーダ `ConvTranspose2d(emb_dim → num_spk*2)` で話者ごとに real/imag を直接出力
- **RI直推定**（マスクではなく複素スペクトルを直接推定）
- 出力は **話者ごとに1枚の複素STFT**（ch毎ではなく、話者同定済みの1ch）
- ESPnet `AbsSeparator` のインターフェースに合わせる
- 「ch0から再構成」は複素テンソルの型テンプレートとしてch0を使うだけで、ch0にマスクを掛けているわけではない

### 割当

- 「出力1 = mic0の装着者、出力2 = mic1の装着者」と固定
- 出力順の曖昧さ（[[PIT]]）が出ない
- シミュの正解 `ref0 = A→mic0`, `ref1 = B→mic1` と対応

## 空間情報を使う分離

- 2本目のマイクが効くのは、各マイクへの **届き方の差** が手がかりになるため

|手がかり|中身|この設定での位置づけ|
|---|---|---|
|**ILD**|ch間の音量差|口元cm vs 相手m で **支配的かつ安定**。Early Fusionで暗黙に効く|
|**IPD**|ch間の位相差（方向・遅延をエンコード）|ILDと一部冗長。装着マイクは間隔が動くので方向が安定して読めない|

> [!note] IPDの物理 マイク間隔 $d$、音源方向 $\theta$、音速 $c$ のとき、到達時間差 $\tau = d\sin\theta / c$。STFTドメインでは遅延が周波数比例の位相シフトになり、 $$\mathrm{IPD}(t,f) = \angle X_0(t,f) - \angle X_1(t,f) \approx 2\pi f,\tau = \frac{2\pi f, d\sin\theta}{c}$$ 高周波で位相がラップ（$2\pi$ジャンプ）するため、`cos(IPD), sin(IPD)` に分けて連続値で渡す。

### fusion戦略

- **Early**（入力で混合）：改造最小・シンプル。空間情報は暗黙学習 ← 採用
- **Middle**（中間でch間attention）：表現力高いが設計複雑
- **Late**（出力近くで統合）：ch毎処理は柔軟だが統合が浅い
- さらに上：ニューラルビームフォーミング、Neural Spatial Filter（Gu et al. 2019）など

## なぜEarly Fusionが妥当だと思ったか

- 装着マイクは **非アレイ**：マイク間隔が人の動きで変動 → 方向ベースのIPD/ビームフォーミングの前提が崩れる
- **ILDが支配的で安定** していて、ch割当（ch0=A, ch1=B）に直結 → Early Fusionで一番効く手がかりを素直に使える
- Late fusionは特に不向き：左右マイクは「対等な2視点」ではなく **最初から関係を見ないと意味がない2つ**
- Middle / Late fusionでは2ch・残響なしの環境では過学習になってしまうのでは？

## シミュレーションの仕組み（`SimulatedEgoMixtureDataset`）

- クリーン単独話者音声から「偽の2ch録音」を作り、正解つきで教師を学習させる。

1. 発話を2つ選ぶ（A・B）、各々を正規化
2. 仮想配置：マイク2本を **0.30–0.60m** 離す、各話者を自分のマイクの **0.02–0.12m** 近くに置く。**配置は毎サンプルランダム**
3. 4経路を伝搬（`_propagate`）：距離 $r$ から **減衰 $1/r$ ＋ 遅延 $r/c \cdot f_s$**（端数遅延はFIR）。残響・雑音なしの自由空間
4. 混合：`x0 = A→mic0 + B→mic0`（A優勢）、`x1 = A→mic1 + B→mic1`（B優勢）→ 左右にILD/IPDが自然に入る
5. 正解：`ref0 = A→mic0`, `ref1 = B→mic1`（**マイクに届いた状態**＝遅延・減衰こみ。混合と辻褄が合いSI-SNRが効く）
6. train=毎エポック新規生成（拡張）、val=`deterministic`で固定（early stopping安定）

## 次のアクション

- [ ] Early Fusionベースラインのスコアを出す（シミュ検証セットで SI-SNR/SDRi）
- [ ] IPD on/off の ablation（空間情報が足りているか判定）
- [ ] 残響付与（pyroomacoustics）で実環境ギャップを測る
- [ ] 残響条件で Early vs Middle の対照実験 → 「Middleが強くなる瞬間」を観測
- [ ] `remix()` を遅延ありに寄せる検討（todo T7）

## 関連

- 全体像：[[研究設計（パイプライン全体）]]
- MOC：[[【MOC】プロジェクト研究A]]
- モデル：[[TF-Locoformer_メモ]]

---
**最終更新:** `= this.file.mtime`
