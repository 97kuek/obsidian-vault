---
date: 2026-06-09
tags:
  - paper
  - 音源分離
title: "RemixIT: Continual Self-Training of Speech Enhancement Models via Bootstrapped Remixing"
authors: "Efthymios Tzinis, Yossi Adi, Vamsi Krishna Ithapu, Buye Xu, Paris Smaragdis, Anurag Kumar"
year: 2022
venue: "IEEE Journal of Selected Topics in Signal Processing (JSTSP)"
status: read
---
## どんな論文か

> **「クリーン音声が一切なくても、雑音入り音声だけで音声強調モデルを学習できる手法」**

これがあなたの研究にとって重要な理由は明確で、津軽弁コーパスには正解データ（クリーン音声）が存在しないからです。

## 従来手法の限界

### ① 教師あり学習（Supervised）

- 合成データ（クリーン音声と雑音を人工的に混ぜたもの）でモデルを学習する手法
- 大量のクリーン音声 $D_s$ と雑音データ $D_n$ が必要
- 実環境への適用時にドメインシフト（学習時と本番環境のデータ分布のズレ）が生じやすい
### ② MixIT（Mixture Invariant Training）

- 「混合音のみ」でモデルを学習できる半教師あり手法
- 複数の混合音をさらに混ぜた「混合の混合（MoM）」を作り、その中から元の混合音を再現するように学習する
- ただし、ドメイン内の独立した雑音サンプルへのアクセスが前提となっており、それが汎用性を制限している。

|手法|必要なデータ|問題点|
|---|---|---|
|教師あり学習|クリーン音声 + 雑音|実環境データに使えない|
|MixIT|混合音 + ドメイン内雑音|雑音の種類が合わないと性能が落ちる|
|**RemixIT**|**混合音だけ**|**← これが画期的！**|
## RemixITの核心アイデア

### Teacher-Student フレームワーク

- **先生と生徒の2つのモデル**を使用する

```
[Teacher モデル]
  → 混合音を見て「音声」と「雑音」を推定する
  → 推定結果はノイズが乗っているが、それでいい

[Student モデル]
  → Teacherの推定結果を「擬似正解」として学習する
  → 最終的にTeacherより上手くなることを目指す
```

### Bootstrapped Remixing

- TeacherはOODデータで事前学習されたモデルを使う
- TeacherはまずバッチBの混合音 $m = s + n$ を処理して、音声推定値 $\tilde{s}$ と雑音推定値 $\tilde{n}$ を出力する
- 次に、TeacherのBatch内の雑音推定値をランダムに並び替え、それをTeacherの音声推定値と再混合してBootstrapped Mixture（合成された擬似混合音）を作る

### 具体例でBootstrapped Remixingを理解する（Batch=4）

#### 元の混合音Batch

1. 田中さんの声 + 工事音
2. 鈴木さんの声 + 風の音
3. 佐藤さんの声 + 電車音
4. 伊藤さんの声 + カフェBGM

#### Teacherモデルが推定するもの

- 音声推定: [田中の声, 鈴木の声, 佐藤の声, 伊藤の声]
- 雑音推定: [工事音, 風音, 電車音, BGM]

#### 雑音をシャッフルする

- [電車音, 工事音, BGM, 風音] 

#### Bootstrapped Mixturesを生成

1. 田中の声 + 電車音（別のサンプルの雑音）
2. 鈴木の声 + 工事音
3. 佐藤の声 + BGM
4. 伊藤の声 + 風音

#### Studentモデルはこれを入力に学習

- 入力：田中の声+電車音
- 擬似正解：田中の声、電車音

## なぜシャッフルするのか

StudentのRemixITの損失関数を分解すると、以下の3項に分解できる。

$$L_{\text{RemixIT}} \propto \underbrace{E\left[|\mathbf{R}^b_S|^2\right]}_{\text{①教師あり損失}} + \underbrace{E\left[|\mathbf{R}^e_T|^2\right]}_{\text{②Teacherの誤差（定数）}} - 2\underbrace{E\left[\langle \mathbf{R}^b_S, \mathbf{R}^e_T \rangle\right]}_{\text{③誤差の相関}}$$

- $\mathbf{R}^e_T = \tilde{s} - s$（Teacherの誤差）
- $\mathbf{R}^b_S = \hat{s}_b - s$（Studentの誤差）

① Studentが正解に近づこうとする項
② Teacherの誤差の大きさ
③ TeacherとStudentの誤差の相関→0になればよい

Bootstrapped Remixingにより、Studentは同じ音声 $s^*$ のTeacher推定値に対して、**異なる雑音を加えた複数のバリエーション**を見ることになる。これにより、Student誤差の分布がTeacher誤差と独立に近づき、③の相関項が期待値上でゼロに収束する。

> 雑音をシャッフルするおかげで、StudentはいつもTeacherと同じ間違いをしなくて済む。独立した視点で学べるため、Teacherの誤差に引きずられない。

理論的には、バッチサイズ $B \to \infty$ の極限で、RemixITの損失の勾配は教師あり学習の損失の勾配に収束することが証明されている：$\nabla_{\theta_S} L_{\text{RemixIT}} \approx \nabla_{\theta_S} L_{\text{Supervised}}$
## 5. Teacher の更新プロトコル（3種類）

学習中にTeacherを更新するかどうかで、以下の3つのモードがあります：

**① 静的Teacher（Static）**: Teacherの重みを学習中ずっと固定する。$\theta_T^{(k)} = \theta_T^{(0)}, ; \forall k$

**② 逐次更新Teacher（Sequential Update）**: 20エポックごとにStudentの最新の重みをTeacherにコピーする。$\theta_T^{(k+1)} := \theta_S^{(k)}$

**③ 指数移動平均Teacher（EMA）**: 毎エポック少しずつStudentの重みをTeacherに反映する。$\bar{\theta}_T^{(j+1)} := \gamma \theta_S^{(j)} + (1-\gamma)\bar{\theta}_T^{(j)}, \quad \gamma = 0.01$

イメージ図：

```
【静的Teacher】
  Teacher: 固定 ─────────────────────────────→
  Student: ─→ 少し改善 ──────────────────────→ 頭打ち

【逐次更新Teacher】（論文推奨）
  Teacher: 固定→→→→→→→[20epoch] 更新!→→→[20epoch] 更新!→→→
  Student: ────成長──────────────→さらに成長───────────────→ 継続改善

【指数移動平均Teacher】（ゼロショット適応向け）
  Teacher: じわじわ更新し続ける（なだらかに追随）
```

Teacherモデルの継続的な更新とBootstrapped Remixingの組み合わせがRemixITの大幅な性能向上の鍵であり、そのため論文では逐次更新プロトコルをデフォルト戦略として選択している（ゼロショット適応では過学習を避けるためEMAを使用）。
## 6. Studentモデルの成長の仕組み

StudentはRemixITの学習が進むにつれて徐々にTeacherより優れた性能を発揮するようになる。この傾向はTeacherが良い推定を行う領域（SI-SDRが高い領域）でより顕著である。一方、Teacherの性能が非常に悪い領域（例えばSI-SDRが-30〜-10dBの場合）では、Studentは性能改善できないことがある。

また、論文ではStudentのネットワークを段階的に深くする戦略も使っています：

実験では、U=8のConvBlocksから始まり、20エポックごとにU=16、U=32と深くしていく成長型Student設計を採用しており、固定深さのモデルよりも有意に高い性能を達成している。

## 7. 損失関数

学習にはSI-SDR損失を使用する：

$$L(y, \hat{y}) = -\text{SI-SDR}(y, \hat{y}) = -20\log_{10}\frac{|\alpha y|}{|\alpha y - \hat{y}|}$$

$\alpha = \hat{y}^\top y / |y|^2$ により、スケールの違いに対して不変になる。

RemixITの場合、正解 $y$ の代わりにTeacherの推定値（擬似正解）を使って計算します。
## 8. 実験結果の概要

DNSデータセットでの実験では、RemixITのUnsupervised版（Teacher U=8, Student U=8→16→32）が先行するSSL手法（MixIT等）を大幅に超える性能を達成した（SI-SDR: 14.5dB → 16.0dB）。クリーン音声に一切アクセスせずにこの性能を達成できており、ドメイン内クリーン音声を使った教師あり学習（18.6dB）にも迫っている。

また、ゼロショット適応でも有効性が確認されており、非常に異なる分布のデータ（例えばWHAM!で事前学習したモデルをDNSデータセット150件だけで適応）でも顕著な改善が見られた。

## RemixITを津軽弁コーパスにどう適用するか

### 論文の設定

- 混合音 = 話者音声 + 雑音
- クリーン音声sは不在
- OOD事前学習済みTeacher
- **1チャンネル入力**
## 今回の研究の設定

- 混合音 = 装着者の声 + 相手の声
- クリーン音声sは不在
- 事前学習済みTF-Locoformer
- **2チャンネル入力**

### 今回の研究の新規性
 
>今回の研究の新規性はRemixITではシングルチャネル専用であったがこれをマルチチャンネルに拡張し、チャンネル感の情報（左右の音量差・位相差など）を組み込む点にある。
>例えば、**チャンネルをまたいでシャッフルする設計**、**各チャンネルの空間情報を保持した擬似混合生成**といった工夫が考えられる

## まとめ

1. OODデータで事前学習したTeacherを用意
2. ターゲットドメインの混合音をTeacherに入力
3. Teacherが音声推定s̃と雑音推定ñを出力
4. バッチ内の雑音推定をシャッフル→**Bootstrapped Mixture**を生成
5. StudentがBootstrapped Mixtureを入力として、Teacherの出力を擬似政界にSI-SDR損失で学習
6. Kステップ後にStudentの重みでTeacherを更新
7. ステップ2に戻って繰り返す