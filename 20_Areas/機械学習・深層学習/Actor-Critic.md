---
date: 2026-07-10
tags:
  - 機械学習
aliases:
  - Actor Critic
  - A2C
  - A3C
  - アドバンテージ関数
---
## Actor-Critic

- 親ノート: [[強化学習の発展手法]]
- 関連: [[方策勾配法とREINFORCE]], [[DQN]]

## Actor-Critic

- Actor-Critic は、Policy-based と Value-based の考え方を組み合わせる
- Actor は方策で行動を選ぶ
- Critic は価値関数で行動を評価する
- 生の報酬和ではなく、価値関数で評価した良し悪しを方策勾配に掛ける

| 役割 | 内容 | パラメタ |
|---|---|---|
| Actor | 方策で行動を選ぶ | $\theta$ |
| Critic | 行動を評価して方策更新を補助する | $\phi$ |

## アドバンテージ関数

$$
A^\pi(s,a) = Q^\pi(s,a) - V^\pi(s)
$$

- アドバンテージ関数は、その行動 $a$ が状態 $s$ における平均的な行動よりどれだけ良いかを表す

| 項 | 意味 |
|---|---|
| $Q^\pi(s,a)$ | 状態 $s$ で行動 $a$ を選んだ後の報酬和 |
| $V^\pi(s)$ | 状態 $s$ から先の報酬和の平均 |
| $A^\pi(s,a)$ | 平均よりどれだけ良い行動か |

- 方策勾配は、アドバンテージを使って次のように書ける

$$
\nabla_\theta J(\theta)
\approx
\frac{1}{N}
\sum_i
\sum_t
\nabla_\theta
\log \pi_\theta(a_t^{(i)}|s_t^{(i)})
\cdot
A^\pi(s_t, a_t)
$$

## アドバンテージを使う理由

- 生の報酬和 $\hat{Q}_t$ をそのまま使う REINFORCE は、勾配の分散が大きくなりやすい
- 報酬の絶対値に振り回されるため、学習が不安定になりやすい
- $V$ を基準として引くと、平均より良いか悪いかという相対評価になる
- 相対評価にすることで分散が下がり、学習が安定する

## Critic の学習

- $V^\pi$ は、Critic のニューラルネットワーク $V_\phi$ で近似する
- モンテカルロで得た報酬和にフィットさせる

$$
\mathcal{L}(\phi)
=
\frac{1}{2}
\big(
V_\phi^\pi(s_t) - y_t^{(i)}
\big)^2
$$

$$
y_t^{(i)}
=
\sum_{t'=t}^{T}
r(s_{t'}^{(i)}, a_{t'}^{(i)})
$$

- アドバンテージは TD 誤差の形でも近似できる

$$
A^\pi(s_i, a_i)
\approx
r(s_i, a_i)
+ V^\pi(s_i')
- V^\pi(s_i)
$$

## Batch Actor-Critic

1. 方策 $\pi_\theta$ でサンプルを収集する
2. Critic の $V_\phi$ を報酬和にフィットさせる
3. アドバンテージ $A = r + V(s') - V(s)$ を計算する
4. Actor を方策勾配で更新する

$$
\nabla_\theta J
\approx
\sum
\nabla\log\pi_\theta(a|s) A
$$

- Actor と Critic は別々のパラメタを持つ
- 両者は相互に影響しながら学習する

## A3C

- A3C は Actor-Critic の代表的な発展形である
- 名前は Asynchronous、Advantage、Actor-Critic の3つのAに由来する

| 要素 | 内容 |
|---|---|
| Asynchronous | 複数の Actor を分散並列で動かし、非同期に方策を更新する |
| Advantage | アドバンテージ関数を使う |
| Actor-Critic | Actor と Critic を組み合わせる |

- A3C は Replay Buffer を使わない
- 並列で多様なデータを集めることで、データ相関の問題に対処する
- 多様な経験を集めながら高速に学習できる点が特徴である
