---
date: 2026-07-10
tags:
  - 機械学習
aliases:
  - 方策勾配法
  - REINFORCE
  - reward-to-go
  - 重点サンプリング
---
# 方策勾配法とREINFORCE

- 親ノート: [[強化学習の発展手法]]
- 関連: [[強化学習の定式化]], [[Actor-Critic]]

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
