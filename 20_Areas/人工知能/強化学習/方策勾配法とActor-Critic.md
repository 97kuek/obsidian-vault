---
date: 2026-07-10
tags:
  - 機械学習
aliases:
  - 方策勾配法
  - REINFORCE
  - reward-to-go
  - 重点サンプリング
  - Actor-Critic
  - Actor Critic
  - A2C
  - A3C
  - アドバンテージ関数
---
## 方策勾配法とActor-Critic

- 親ノート: [[強化学習]]
- 関連: [[DQN]]

## 方策勾配法

- 方策勾配法は、方策 $\pi_\theta$ をパラメタ $\theta$ で表す
- 目的関数 $J(\theta)$ を最大化するように、勾配上昇で $\theta$ を更新する
- 価値関数を経由せず、方策そのものを直接改善する

$$
J(\theta) =
\mathbb{E}_{\tau\sim p_\theta(\tau)}
\left[
\sum_t r(s_t, a_t)
\right]
=
\mathbb{E}_{\tau\sim p_\theta(\tau)}
[r(\tau)]
$$

$$
\theta^* = \arg\max_\theta J(\theta)
$$

## トラジェクトリの確率

- トラジェクトリの生起確率は、初期分布、方策、環境の遷移確率の積で表される

$$
p_\theta(\tau) =
p_{init}(s_1)
\prod_{t=1}^{T}
\pi_\theta(a_t|s_t)
p(s_{t+1}|s_t, a_t)
$$

## Log-gradient trick

- 目的関数を $\theta$ で微分すると、次の形になる

$$
\nabla_\theta J(\theta) =
\int \nabla_\theta p_\theta(\tau) r(\tau) d\tau
$$

- ここで Log-gradient trick を使う

$$
\nabla_\theta \log p_\theta(\tau)
=
\frac{1}{p_\theta(\tau)}
\nabla_\theta p_\theta(\tau)
$$

$$
\nabla_\theta p_\theta(\tau)
=
p_\theta(\tau)
\nabla_\theta \log p_\theta(\tau)
$$

- 代入すると、積分を期待値の形に戻せる

$$
\nabla_\theta J(\theta) =
\mathbb{E}_{\tau\sim p_\theta(\tau)}
\big[
\nabla_\theta \log p_\theta(\tau) r(\tau)
\big]
$$

- $\log p_\theta(\tau)$ は次のように展開できる

$$
\log p_\theta(\tau) =
\log p_{init}(s_1)
+ \sum_t \log \pi_\theta(a_t|s_t)
+ \sum_t \log p(s_{t+1}|s_t,a_t)
$$

- $\theta$ で微分すると、初期分布の項と環境の遷移確率の項は消える

$$
\nabla_\theta \log p_\theta(\tau) =
\sum_{t=1}^{T}
\nabla_\theta \log \pi_\theta(a_t|s_t)
$$

- よって、方策勾配は次の形になる

$$
\nabla_\theta J(\theta) =
\mathbb{E}_{\tau\sim p_\theta}
\left[
\left(
\sum_t
\nabla_\theta \log \pi_\theta(a_t|s_t)
\right)
\left(
\sum_t r(s_t,a_t)
\right)
\right]
$$

- 環境のモデル $p(s'|s,a)$ を知らなくても勾配を計算できる
- これが方策勾配法がモデルフリーで動ける理由である

## REINFORCE

- 期待値は、$N$ 回の試行でサンプル近似できる

$$
\nabla_\theta J(\theta)
\approx
\frac{1}{N}
\sum_{i=1}^{N}
\sum_{t=1}^{T}
\nabla_\theta
\log \pi_\theta(a_t^{(i)}|s_t^{(i)})
\cdot
\sum_{t=1}^{T}
r(s_t^{(i)}, a_t^{(i)})
$$

1. 方策 $\pi_\theta$ を走らせてトラジェクトリ $\tau^{(i)}$ をサンプルする
2. サンプルから方策勾配を計算する
3. 勾配上昇で $\theta$ を更新する

$$
\theta \leftarrow
\theta + \alpha \nabla_\theta J(\theta)
$$

- $J$ を最大化するため、更新の符号は $+$ である
- $\nabla \log \pi$ は、その行動を出しやすくする方向を表す
- $r(\tau)$ は、その軌跡でもらえた報酬を表す

## reward-to-go

- 時刻 $t$ より前の報酬は、時刻 $t$ の行動とは無関係である
- そのため、各時刻の $\log \pi$ には、その時刻以降の報酬だけを掛ければよい

$$
\nabla_\theta J(\theta)
\approx
\frac{1}{N}
\sum_i
\sum_t
\nabla_\theta
\log \pi_\theta(a_t^{(i)}|s_t^{(i)})
\underbrace{
\sum_{t'=t}^{T}
r(s_{t'}^{(i)}, a_{t'}^{(i)})
}_{\hat{Q}_t^{(i)}}
$$

- 余計な項を落とすことで、分散が減って学習が安定する
- $\hat{Q}_t$ は、その時刻から将来に得られる報酬和の推定である

## 重点サンプリングと Off-Policy 化

- 方策を更新するたびにサンプルし直すのは非効率である
- 重点サンプリングを使うと、別の分布から得たサンプルでも期待値を補正できる

$$
\mathbb{E}_{x\sim p(x)}[f(x)]
=
\mathbb{E}_{x\sim q(x)}
\left[
\frac{p(x)}{q(x)}f(x)
\right]
$$

- 古い方策 $\theta$ で集めたデータから、新しい方策 $\theta'$ の勾配を計算できる

$$
\nabla_{\theta'} J(\theta')
=
\mathbb{E}_{\tau\sim p_\theta}
\left[
\prod_t
\frac{\pi_{\theta'}(a_t|s_t)}
{\pi_\theta(a_t|s_t)}
\sum_t
\nabla_{\theta'}
\log \pi_{\theta'}(a_t|s_t)
\sum_{t'\ge t}
r(s_{t'}, a_{t'})
\right]
$$

| 用語 | 意味 |
|---|---|
| On-Policy | 学習データの生成に、今学習中の方策そのものを使う |
| Off-Policy | 学習データの生成に、今学習中の方策そのものを使わない |

- REINFORCE は基本的に On-Policy である
- 重点サンプリングを使うと Off-Policy 化できる
- Off-Policy はデータを使い回せるため、サンプル効率が良い

## Actor-Critic

Actor-Criticは、Policy-basedとValue-basedの考え方を組み合わせる手法である。Actorが方策で行動を選び、Criticが価値関数で行動を評価する。生の報酬和ではなく、価値関数で評価した良し悪しを方策勾配へ掛ける。

| 役割 | 内容 | パラメタ |
|---|---|---|
| Actor | 方策で行動を選ぶ | $\theta$ |
| Critic | 行動を評価して方策更新を補助する | $\phi$ |

## アドバンテージ関数

$$
A^\pi(s,a) = Q^\pi(s,a) - V^\pi(s)
$$

- アドバンテージ関数は、行動 $a$ が状態 $s$ における平均的な行動よりどれだけ良いかを表す。
- 生の報酬和を使うREINFORCEは勾配の分散が大きくなりやすい。
- $V$ を基準として引き、報酬の絶対値ではなく相対評価にすることで分散を下げ、学習を安定させる。

方策勾配は、アドバンテージを使って次のように書ける。

$$
\nabla_\theta J(\theta)
\approx
\frac{1}{N}
\sum_i\sum_t
\nabla_\theta \log \pi_\theta(a_t^{(i)}|s_t^{(i)})
\cdot A^\pi(s_t,a_t)
$$

## Criticの学習

$V^\pi$ はCriticのニューラルネットワーク $V_\phi$ で近似し、モンテカルロで得た報酬和へフィットさせる。

$$
\mathcal{L}(\phi)=\frac{1}{2}\big(V_\phi^\pi(s_t)-y_t^{(i)}\big)^2
$$

$$
y_t^{(i)}=\sum_{t'=t}^{T}r(s_{t'}^{(i)},a_{t'}^{(i)})
$$

アドバンテージはTD誤差の形でも近似できる。

$$
A^\pi(s_i,a_i)\approx r(s_i,a_i)+V^\pi(s_i')-V^\pi(s_i)
$$

## Batch Actor-Critic

1. 方策 $\pi_\theta$ でサンプルを収集する。
2. Criticの $V_\phi$ を報酬和へフィットさせる。
3. アドバンテージ $A=r+V(s')-V(s)$ を計算する。
4. Actorを方策勾配で更新する。

ActorとCriticは別々のパラメタを持ち、相互に影響しながら学習する。

## A3C

A3CはAsynchronous Advantage Actor-Criticの略である。

| 要素 | 内容 |
|---|---|
| Asynchronous | 複数のActorを分散並列で動かし、非同期に方策を更新する |
| Advantage | アドバンテージ関数を使う |
| Actor-Critic | ActorとCriticを組み合わせる |

- Replay Bufferを使わず、並列で多様なデータを集めることでデータ相関へ対処する。
- 多様な経験を集めながら高速に学習できる点が特徴である。
