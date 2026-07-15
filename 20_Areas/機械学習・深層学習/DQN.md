---
date: 2026-07-10
tags:
  - 機械学習
aliases:
  - Deep Q-Network
  - Value-based
  - SARSA
  - Q学習
---
## DQN

- 親ノート: [[強化学習の発展手法]]
- 関連: [[強化学習]], [[強化学習の定式化]]

## Value-based 手法

- Value-based 手法では、方策を直接いじらない
- 行動価値関数 $Q(s,a)$ を経験から推定する
- 方策は、$Q$ が最大の行動を選ぶ Greedy や $\varepsilon$-Greedy として決まる
- 問題は $Q$ の推定に帰着する

## ベルマン方程式

$$
Q^\pi(s,a) =
\mathbb{E}_{s'\sim p(s'|s,a)}
\big[
r(s,a) + \gamma V^\pi(s')
\big]
$$

$$
V^\pi(s') =
\mathbb{E}_{a'\sim\pi(a'|s')}
\big[
Q^\pi(s',a')
\big]
$$

$$
Q^\pi(s,a) =
\mathbb{E}_{s'\sim p(s'|s,a)}
\Big[
r(s,a)
+ \gamma
\mathbb{E}_{a'\sim\pi(a'|s')}
[Q^\pi(s',a')]
\Big]
$$

- ベルマン方程式は、今の価値を今の報酬と次の状態の価値で表す再帰式である
- 観測した $(s,a,r,s')$ を使いながら $Q$ を少しずつ更新する

## 更新の考え方

- 観測から目標値を作る
- 現在の推定値を目標値へ近づける

$$
Q^\pi(s,a)
\leftarrow
Q^\pi(s,a)
+ \alpha
\big[
Q^\pi_{target}(s,a) - Q^\pi(s,a)
\big]
$$

- この更新は、現在の推定値と目標値の重み付き平均である
- $\alpha$ は学習率である

## SARSA と Q 学習

| 手法 | 観測するもの | 目標値 | 性質 |
|---|---|---|---|
| SARSA | $(s,a,r,s',a')$ | $r(s,a) + \gamma Q(s',a')$ | On-Policy |
| Q 学習 | $(s,a,r,s')$ | $r(s,a) + \gamma \max_{a'} Q(s',a')$ | Off-Policy |

### SARSA

$$
Q_{target}(s,a) =
r(s,a) + \gamma Q(s', a')
$$

- $a'$ は、学習中の方策 $\pi$ で実際に選んだ行動である
- 実際に取る行動を織り込むため、On-Policy である
- 崖際を避けるような安全志向の挙動になりやすい

### Q 学習

$$
Q_{target}(s,a) =
r(s,a) + \gamma \max_{a'} Q(s', a')
$$

- $a'$ は実際に選んだ行動ではない
- 次状態で最善を尽くした場合の $\max$ を使う
- データ生成方策と学習対象の方策が一致しなくてもよいため、Off-Policy である
- 理想の最善手を仮定するため、楽観的になりやすい

## 関数近似と DQN

- $Q(s,a)$ を表で持つ方法は、状態数や行動数が大きい問題で破綻する
- そこで、ニューラルネットワーク $Q_\theta(s,a)$ で行動価値を近似する

### 素朴な Fitted Q と Online Q-iteration の問題

| 問題 | 内容 |
|---|---|
| データに相関がある | 連続するステップは似ており、SGD が仮定する独立同分布性を壊す |
| 自分自身がターゲットになる | $Q_\theta$ が学習中に動くため、目標値も動き続けて収束しにくい |

$$
y_i =
r + \gamma \max_{a'}Q_\theta(s',a')
$$

## DQN の工夫

| 工夫 | 役割 |
|---|---|
| Replay Buffer | 経験 $(s,a,r,s')$ をバッファに貯め、ランダムに選んで学習することで時間相関を壊す |
| Target Network | ターゲット計算用に別のネットワーク $Q_{\theta'}$ を用意し、一定間隔でだけ更新する |

$$
\Delta\theta
\leftarrow
\sum_i
\frac{\partial Q_\theta(s_i,a_i)}{\partial\theta}
\Big[
Q_\theta(s_i,a_i)
- r(s_i,a_i)
- \gamma
\max_{a'}Q_{\theta'}(s_i',a')
\Big]
$$

$$
\theta \leftarrow \theta - \alpha\Delta\theta
$$

$$
N\text{ ステップごとに }
\theta' \leftarrow \theta
$$

- Replay Buffer と Target Network により、DQN は学習を安定化する
- この2つがそろうことで、Atariを人間超えで解いたDQNが実現した
