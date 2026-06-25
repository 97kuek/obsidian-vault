---
date: 2026-06-25
tags:
  - reference
  - ソフトウェア開発
---# React基礎

## Reactの基礎

### Reactの考え方とコンポーネント

#### Reactが解決した問題

- React以前、画面の書き換えは手作業だった
- あるデータ(たとえばログイン中のユーザー名)が変わったとき、それを表示している画面のあちこちを**自分で全部書き換えに行く**必要があり、書き換え漏れがそのままバグになる

- Reactはこれを逆転させた
> 「**今のデータならこういう画面になる**」とだけ書いておけば、データが変わったときの画面更新はReactが自動でやってくれる。

```
UI = f(state)
```

- UIは、stateを入れると画面が返ってくる関数、という意味
- Reactの学習は、ほぼ全部この仕組みの詳細を学ぶこと

#### コンポーネント = ただの関数

- Reactで画面を作る部品を**コンポーネントという**
- 正体は **JavaScriptの関数**で、「画面に出すもの」を `return` する

```jsx
function Welcome() {
  return <h1>こんにちは</h1>
}
```

- 使うときは自作のHTMLタグのように書く

```jsx
<Welcome />
```

- **コンポーネント名は大文字で始める**
- 小文字だと、ReactはただのHTMLタグ(`<div>` など)と区別できない

#### JSX:JavaScriptの中にマークアップを書く記法

- `<h1>こんにちは</h1>` は文字列でもHTMLでもなく、**JSX**という記法
- JavaScriptの中にHTMLっぽい書き方を混ぜられ、裏で普通のJavaScriptに変換される
- これで見た目とロジックを自然に一緒に書ける

1. **returnする一番外側の要素は1つだけ**。並べたいときは親要素で包むか、空タグ `<>...</>`(フラグメント)で包む。
2. **`class` ではなく `className`**。`class` はJavaScriptの予約語だから。
3. **`{}` でJavaScriptの値や式を埋め込める**。例:`<h1>{name}さん</h1>`
4. **自己終了タグはスラッシュが必要**。`<img />`、`<br />`。
5. **属性はキャメルケース**。`onclick` ではなく `onClick`。

```jsx
function Greeting() {
  const name = "敬太郎"
  const hour = new Date().getHours()

  return (
    <div className="greeting">
      <h1>{name}さん、こんにちは</h1>
      <p>今は{hour}時です</p>
    </div>
  )
}
```

`{}` の中には変数だけでなく、`new Date().getHours()` のような**式**も書けます。

#### コンポーネントは組み合わせる

- コンポーネントの中で別のコンポーネントを呼べる
- 小さな部品を組み合わせて大きな画面を作る、これがReactの本質

```jsx
function App() {
  return (
    <div>
      <Greeting />
      <Greeting />
    </div>
  )
}
```

- 今の `Greeting` は `name` が直書きで、常に同じものしか出せない
- これを動的にする道具が、次章の **props** と、第3章の **state** 

---

### props — 部品にデータを渡す

#### propsとは

- コンポーネントは「部品」なので、外から設定を渡せると再利用できる
- HTMLタグに属性を付けるのと同じ書き方で、コンポーネントにもデータを渡せる
- これを **props**(properties)と呼ぶ

```jsx
// 渡す側
<Greeting name="敬太郎" />
<Greeting name="花子" />
```

```jsx
// 受け取る側:第一引数に props オブジェクトが入ってくる
function Greeting(props) {
  return <h1>{props.name}さん、こんにちは</h1>
}
```

- 同じ `Greeting` が、渡された `name` によって違う画面を出せるようになった

#### 分割代入で書く

- 毎回 `props.name` と書くのは冗長なので、引数の時点で展開(分割代入)するのが普通です。

```jsx
function Greeting({ name }) {
  return <h1>{name}さん、こんにちは</h1>
}
```

複数あれば並べます。デフォルト値も付けられます。

```jsx
function Button({ label, variant = "primary" }) {
  return <button className={variant}>{label}</button>
}
```

### 文字列以外を渡す

文字列以外(数値・真偽値・配列・オブジェクト・関数)は `{}` で囲んで渡します。

```jsx
<UserCard
  name="敬太郎"
  age={22}                 // 数値
  isAdmin={true}           // 真偽値
  hobbies={["飛行機", "音響"]} // 配列
  onClick={handleClick}    // 関数(後の章で使う)
/>
```

### children:タグで挟んだ中身

開きタグと閉じタグの間に書いた中身は、`children` という特別なpropsとして受け取れます。「枠」を作って中身を差し替えたいときに使います。

```jsx
function Card({ children }) {
  return <div className="card">{children}</div>
}

// 使う側
<Card>
  <h2>タイトル</h2>
  <p>本文</p>
</Card>
```

### propsは読み取り専用

最重要ルール:**コンポーネントは受け取ったpropsを書き換えてはいけない**。propsは「親から渡された設定」であり、子が勝手に変えると `UI = f(state)` の前提が崩れます。データは常に**親から子へ、一方向に**流れます。これをReactでは「単方向データフロー」と呼びます。

では「変化するデータ」はどう扱うのか? それが次章の state です。

## state — 変化するデータとイベント

### なぜ普通の変数ではダメなのか

「ボタンを押すたびに数が増えるカウンター」を、普通の変数で書いてみます。

```jsx
function Counter() {
  let count = 0
  return <button onClick={() => count++}>{count}</button>
}
```

これは**動きません**。`count++` で変数自体は増えますが、Reactは「データが変わったから画面を作り直す」必要があると気づけません。`UI = f(state)` の `f`(再実行)が走らないのです。

Reactに「これは変化するデータで、変わったら画面を作り直して」と教えるための仕組みが **state** です。

### useState

state は **フック**(`use` で始まるReactの特別な関数)の一つ、`useState` で作ります。

```jsx
import { useState } from "react"

function Counter() {
  const [count, setCount] = useState(0)

  return (
    <button onClick={() => setCount(count + 1)}>
      {count}
    </button>
  )
}
```

`useState(0)` は配列を返し、それを分割代入で2つに受けます。

- `count` … 現在の値(初期値は `0`)
- `setCount` … 値を更新するための関数

そして核心はこれです:

> **`setCount` を呼ぶと、Reactはそのコンポーネントを「もう一度実行」して、新しい `count` で画面を作り直す。**

この「コンポーネントの再実行」を**再レンダリング**と呼びます。Reactの動的な動きは、すべてこの「stateが変わる → 再レンダリング」で説明できます。

### イベントハンドラ

`onClick` のような属性に関数を渡すと、その操作が起きたときに呼ばれます。これを**イベントハンドラ**と呼びます。

```jsx
function Form() {
  function handleClick() {
    alert("押された")
  }
  return <button onClick={handleClick}>送信</button>
}
```

注意:`onClick={handleClick}` は「関数を渡す」。`onClick={handleClick()}` と書くと「**今すぐ実行**して結果を渡す」になり、レンダリングのたびに即実行されてしまいます。引数を渡したいときはアロー関数で包みます。

```jsx
<button onClick={() => handleDelete(user.id)}>削除</button>
```

### stateを更新するときのルール

#### 1. 必ず set関数を使う

`count = 5` のような直接代入はNG。`setCount(5)` を使う。これがReactに変化を伝える唯一の方法です。

#### 2. オブジェクトや配列は「新しいものを作って」渡す(イミュータブル更新)

既存のstateを書き換えるのではなく、新しいオブジェクト/配列を作って渡します。

```jsx
// NG:元の配列を書き換えている
todos.push(newTodo)
setTodos(todos)

// OK:新しい配列を作って渡す
setTodos([...todos, newTodo])
```

```jsx
// オブジェクトも同じ。スプレッドでコピーしてから一部を上書き
setUser({ ...user, name: "新しい名前" })
```

理由:Reactは「前のstateと新しいstateが別物かどうか」で変化を判断するため、同じ配列を書き換えると変化に気づけないことがあるからです。

#### 3. 前の値を使う更新は関数形式で

新しい値が前の値に依存するときは、関数を渡す形が安全です。

```jsx
setCount(prev => prev + 1)
```

### まとめ

props(外から渡る・読み取り専用)と state(内部で変化する・set関数で更新)。この2つでReactのデータの扱いはほぼ説明できます。次は、そのデータを使って「出し分け」と「繰り返し表示」をする方法です。

---

## 第4章 条件分岐とリストの表示

### 条件によって表示を変える

JSXの `{}` の中にはJavaScriptの式が書けるので、条件分岐もそこで行います。

**三項演算子(AかBか)**:

```jsx
function Status({ isLoggedIn }) {
  return <p>{isLoggedIn ? "ログイン中" : "ゲスト"}</p>
}
```

**`&&`(条件が真のときだけ表示)**:

```jsx
function Inbox({ count }) {
  return (
    <div>
      <h1>受信箱</h1>
      {count > 0 && <span>未読が{count}件あります</span>}
    </div>
  )
}
```

`count > 0` が偽なら、後ろのJSXは表示されません。

**早期return(丸ごと出し分け)**:

```jsx
function Profile({ user }) {
  if (!user) {
    return <p>読み込み中...</p>
  }
  return <h1>{user.name}</h1>
}
```

### リストを表示する:.map()

配列データを並べて表示するには、JavaScriptの `.map()` で「データの配列」を「JSXの配列」に変換します。

```jsx
function UserList({ users }) {
  return (
    <ul>
      {users.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

### key の重要性

`.map()` で要素を並べるとき、各要素には **`key`** を付ける必要があります。`key` は「この要素はどれなのか」をReactに教える目印で、リストが変化(追加・削除・並び替え)したときに、Reactが効率よく・正しく差分更新するために使います。

- `key` には**安定して一意な値**(DBのidなど)を使う。
- **配列のindexをkeyにするのは避ける**(並び替えや削除でindexがずれ、表示が壊れることがある)。

`key` を付け忘れるとReactが警告を出します。これは後の「エージェントのレビュー」でも頻出のチェックポイントです。

---

## 第5章 useEffectと外部とのやりとり

### 副作用(side effect)とは

コンポーネントの本来の仕事は「stateを受け取って画面を返す」ことです。しかし実際には、それ以外のこと——サーバーからデータを取る、タイマーをセットする、ブラウザのAPIを叩く——も必要になります。これらを**副作用**と呼びます。

副作用をレンダリング中に直接書くと、再レンダリングのたびに走って無限ループしたりします。そこで「レンダリングが終わった**後**に、決めたタイミングで実行する」ための道具が **`useEffect`** です。

### useEffectの基本

```jsx
import { useEffect, useState } from "react"

function Clock() {
  const [time, setTime] = useState(new Date())

  useEffect(() => {
    const id = setInterval(() => setTime(new Date()), 1000)
    return () => clearInterval(id) // クリーンアップ
  }, []) // 依存配列

  return <p>{time.toLocaleTimeString()}</p>
}
```

ポイントは3つです。

1. **第1引数の関数** … 実行したい副作用本体。
2. **第2引数の依存配列** … いつ再実行するかを決める。
    - `[]`(空)… 最初の1回だけ。
    - `[count]` … `count` が変わるたび。
    - 省略 … 毎レンダリング(基本使わない)。
3. **戻り値の関数(クリーンアップ)** … 後片付け。タイマー解除やイベント解除など。次の実行前と、コンポーネントが消えるときに呼ばれる。

### データ取得の例(そしてここが伏線)

Reactだけでサーバーからデータを取る、典型的な書き方:

```jsx
function Users() {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetch("/api/users")
      .then(res => res.json())
      .then(data => {
        setUsers(data)
        setLoading(false)
      })
  }, [])

  if (loading) return <p>読み込み中...</p>
  return <UserList users={users} />
}
```

これは動きますが、よく見ると面倒です。**画面が一度ブラウザに表示され、JavaScriptが動き出してから、ようやくデータを取りに行く**。だから一瞬「読み込み中...」が出る。データ取得用のstateとloading管理も毎回手で書く必要がある。

> この「ブラウザに届いてからデータを取りに行く」構造こそ、Next.jsが**サーバー側でデータを先に用意する**ことで解決する問題です。第2部の主役になります。

### フックの2大ルール

`useState` や `useEffect` などフックには、破ると壊れる鉄則があります。

1. **フックはコンポーネント(または別のフック)の中の、トップレベルでだけ呼ぶ。** `if` やループ、関数の中で呼ばない。
2. **毎回同じ順番で呼ばれるようにする。** 上のルールはこれを守るためのもの。

これでReactの基礎は一通り揃いました。コンポーネント、JSX、props、state、イベント、条件分岐とリスト、useEffect。**これらは全部 `UI = f(state)` の具体化**です。ここから Next.js に入ります。
