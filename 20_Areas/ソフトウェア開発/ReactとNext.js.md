---
date: 2026-06-25
tags:
  - reference
  - ソフトウェア開発
---
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

## Next.js

### Next.jsとは何か — 「どこで」と「いつ」

#### Reactだけの限界

- 素のReact(create-react-appのような構成)では、コードはすべて**ブラウザに送られてから動く**
- これを**クライアントサイドレンダリング**と呼ぶ
- このとき以下の問題が出る
- 最初は中身が空のHTMLが届き、JavaScriptが動くまで何も表示されない(初速・SEOに不利)。
- ブラウザからDBに直接触れない(必ずAPI経由)。
- APIキーなど秘密の値をブラウザに置けない。

#### Next.jsが足すもの

- React が答えるのは「状態が与えられたとき、UIはどう見えるか(What)」だけだった
- Next.js はそこに2つの軸を足す
	- **どこで動くか** … サーバー or ブラウザ
	- **いつ動くか** … ビルド時 / リクエスト時 / 表示後のブラウザ内
- つまり Next.js を学ぶとは、この「どこで・いつ」を制御する技術を学ぶこと
- コードの一部を**サーバー側で先に動かす**ことで、上の問題をまとめて解決する
- サーバーでデータ入りのHTMLを作ってから送れば、初速もSEOも良くなり、サーバー側ならDBにも直接触れ、秘密も守れる

#### コードが動く場所は2つだけ

- **サーバー側**:DBに直接アクセスできる、秘密の値を使える、`async/await` でデータを取れる。ただし `useState`・`onClick` のようなインタラクションは持てない。
- **ブラウザ側**:`useState`・`useEffect`・`onClick` などインタラクションが使える。ただしDBや秘密には触れない。

#### App Router と Pages Router、そして現在地

- Next.jsには歴史的に2つのルーティング方式がある

- **App Router**(`app/` ディレクトリ)… 現在の標準。サーバー側レンダリングを軸にした新しいモデル。
- **Pages Router**(`pages/` ディレクトリ)… 旧来の方式。今も動くが、新規開発では使わない。

- プロジェクトの作成はこれだけ

```bash
npx create-next-app@latest
```

### ファイルベースルーティング(App Router)

#### フォルダ構造がそのままURLになる

- App Routerでは、`app/` ディレクトリの**フォルダ構造がそのままURLのパス**になる
- ルーティング設定を別途書く必要はない

```
app/
  page.tsx          →  /
  about/
    page.tsx        →  /about
  blog/
    page.tsx        →  /blog
    [slug]/
      page.tsx      →  /blog/任意の値
```


- **`page.tsx`** … そのパスで表示される画面本体。これが無いとそのパスはアクセスできない。
- **フォルダ名** … URLのセグメント。
- **`[slug]` のような角括弧フォルダ** … 動的セグメント(IDやスラッグなど可変部分)。

#### page.tsx と layout.tsx

**`page.tsx`** はその画面の中身

```tsx
// app/about/page.tsx
export default function AboutPage() {
  return <h1>会社概要</h1>
}
```

**`layout.tsx`** 
その配下すべての画面を包む「枠」。ヘッダーやサイドバーなど共通部分を置きます。`children` に各 `page` が入ります。

```tsx
// app/layout.tsx(ルートレイアウト:全ページ共通)
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <body>
        <header>共通ヘッダー</header>
        {children}
      </body>
    </html>
  )
}
```

レイアウトはネストできます。`app/layout.tsx` が全体を包み、`app/blog/layout.tsx` がblog配下だけをさらに包む、という具合です。ページ移動してもレイアウト部分は保持されるので、再描画が最小限で済みます。

#### 動的セグメントで値を受け取る

`[slug]` のような動的フォルダでは、URLのその部分の値を `params` で受け取れます。**Next.js 16 では `params` は非同期**なので `await` します。

```tsx
// app/blog/[slug]/page.tsx
export default async function BlogPost({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  return <h1>記事:{slug}</h1>
}
```

この「`params` を `await` する」のが現在の書き方です。古い同期的な書き方(`params.slug` を直接読む)を見たら、それは古いコードのサインです。

#### ページ間リンク:next/link

- ページ移動には `<a>` ではなく `<Link>` を使う
- これで全ページ再読み込みなしの高速な遷移になる

```tsx
import Link from "next/link"

export default function Nav() {
  return (
    <nav>
      <Link href="/">ホーム</Link>
      <Link href="/about">概要</Link>
    </nav>
  )
}
```

#### ローディングとエラーの特別ファイル

- App Routerには、置くだけで機能する特別なファイルがある
	- **`loading.tsx`** … そのセグメントの読み込み中に自動で表示される。
	- **`error.tsx`** … そのセグメントでエラーが起きたとき表示される(クライアントコンポーネントとして書く)。
	- **`not-found.tsx`** … 404のとき。

### Server Components と Client Components

#### デフォルトはサーバー

- App Routerでは、コンポーネントは**何も書かなければ Server Component**
- Server Componentは
	- `async` にしてDBやAPIから**直接データを取れる**。
	- 秘密の値(APIキー、DB接続情報)を**安全に使える**(ブラウザに送られないから)。
	- ただし `useState`・`useEffect`・`onClick` など**インタラクションは使えない**。

```tsx
// app/page.tsx —— 何も宣言しなければサーバーで動く
export default async function Page() {
  const users = await db.user.findMany() // DBに直接アクセスOK
  return <UserList users={users} />
}
```

#### "use client" でブラウザ側にする

ボタンの状態管理やフォーム入力など、インタラクションが要るコンポーネントは、ファイルの**先頭に `"use client"`** と書いて Client Component にします。

```tsx
"use client"
import { useState } from "react"

export default function Counter() {
  const [n, setN] = useState(0)
  return <button onClick={() => setN(n + 1)}>{n}</button>
}
```

Client Componentは `useState` や `onClick` が使える代わりに、**DBや秘密には直接触れません**。

#### 境界(boundary)という考え方

- `"use client"` を書いたファイルから先は「クライアントの世界」になる
	- **Server Component は Client Component を呼べる**(親がサーバー、子がクライアント、はOK)。
	- **`"use client"` を書いたコンポーネントが import する先も、すべてクライアント扱いになる**。
	- だから `"use client"` は**できるだけ末端(葉)の、本当にインタラクションが要る部品にだけ**付ける。上の方(レイアウトやページ全体)に付けると、配下全部がブラウザ送りになり、サーバーレンダリングの利点を捨てることになる。

- 設計の定石は「**サーバーをデフォルトにして、インタラクションが要る小さな部品だけをクライアントに切り出す**」
- たとえばページ全体はServer Componentでデータを取り、その中の「いいねボタン」だけを `"use client"` の小さな部品にする

#### サーバーからクライアントへ渡せるもの

- Server Component から Client Component へは props を渡せますが、**シリアライズ可能な値(文字列・数値・配列・プレーンなオブジェクトなど)**に限られます。関数やクラスインスタンスはそのままでは渡せません(操作を渡したいときは後述の Server Actions を使う)。

#### よくある間違い(=エージェントのレビュー観点)

1. **`"use client"` を付けすぎる**:ページの一番上に付けて、本来サーバーでよかった部分まで全部ブラウザに送ってしまう。
2. **サーバー専用の処理をクライアントで呼ぶ**:`"use client"` のコンポーネントから直接DBや秘密キーを触ろうとする(動かない/危険)。
3. **秘密の漏洩**:APIキーをClient Componentで使い、ブラウザに露出させてしまう。
4. **古いデータ取得の持ち込み**:Server Componentで直接 `await` できるのに、第5章の `useEffect + fetch` パターンを持ち込む。

## 第9章 データの取得

### サーバーで直接awaitする

App Routerの基本は、**Server Componentを `async` にしてデータを直接待つ**ことです。第5章の `useEffect`・`loading` state・`fetch().then()` は不要になります。

```tsx
// app/dashboard/page.tsx
export default async function Dashboard() {
  const stats = await getStats()      // 自前の関数でもDBクエリでもOK
  const user = await getCurrentUser()
  return (
    <div>
      <h1>{user.name}さんのダッシュボード</h1>
      <Stats data={stats} />
    </div>
  )
}
```

データ取得がサーバーで完結し、HTMLにデータが入った状態でブラウザに届くので、初速もSEOも良くなります。

### キャッシュは「明示的に」考える

データ取得とセットで重要なのが**キャッシュ**(一度取った結果を再利用するか)です。ここは Next.js で歴史的に最も変わり続けた部分で、古い記事と現行版で挙動が違います。現在の考え方はシンプルに:

> **デフォルトでは毎回新しく取得し、キャッシュしたいときは明示的に指定する。**

- 「この結果は一定時間使い回してよい」なら、再検証(revalidate)の時間を指定する。
- 「常に最新」なら、何もしない(都度取得)。
- 現行版には結果を明示的にキャッシュする仕組み(`use cache` 等のディレクティブ)も入りつつあります。

ここは特に変化が速い領域なので、**実際のディレクティブ名や既定値は必ず公式ドキュメントの当該バージョンを確認**してください。「キャッシュは明示的に制御するもの」という原則だけ押さえておけば、細部はドキュメントで確認できます。

### 並列取得とウォーターフォール

`await` を素直に縦に並べると、**直列**に実行されて遅くなることがあります(これを"ウォーターフォール"と呼ぶ)。

```tsx
// 遅い:aが終わってからbを取りに行く
const a = await getA()
const b = await getB()
```

互いに依存しないなら**並列**にします。

```tsx
// 速い:同時に投げて両方待つ
const [a, b] = await Promise.all([getA(), getB()])
```

これもエージェントの出力でよく見るレビュー観点です。「依存していない取得が直列になっていないか」をチェックします。

### ストリーミングと Suspense

重い部分だけ後から表示する仕組みもあります。`<Suspense>` で包むと、その中身の読み込みを待つ間 `fallback` を見せ、準備できた部分から順に画面に流し込めます(ストリーミング)。

```tsx
import { Suspense } from "react"

export default function Page() {
  return (
    <div>
      <h1>すぐ出る部分</h1>
      <Suspense fallback={<p>読み込み中...</p>}>
        <SlowSection />   {/* 重いデータ取得を含む部品 */}
      </Suspense>
    </div>
  )
}
```

`loading.tsx` は、実はページ全体をこの Suspense で包む仕組みのショートカットです。

---

## 第10章 データの変更 — Server Actions

### 取得だけでなく「書き込み」も

ここまでは「読む」話でした。フォーム送信やDB更新など「**書く**」操作には、App Routerでは **Server Actions** という仕組みが使えます。これは「**サーバーで動く関数を、クライアントから直接呼べる**」ようにするものです。自前でAPIエンドポイントを切らなくても、関数を1つ書くだけでフォーム処理ができます。

### "use server"

関数(またはファイル)の先頭に `"use server"` と書くと、それは**必ずサーバーで実行される関数**になります。

```tsx
// app/todos/page.tsx
import { revalidatePath } from "next/cache"
import { db } from "@/lib/db"

async function createTodo(formData: FormData) {
  "use server"                          // ← この関数はサーバーで動く
  const title = formData.get("title") as string
  await db.todo.create({ data: { title } }) // DBに直接書ける
  revalidatePath("/todos")              // 一覧を最新化
}

export default function TodosPage() {
  return (
    <form action={createTodo}>          {/* actionに関数を直接渡せる */}
      <input name="title" />
      <button type="submit">追加</button>
    </form>
  )
}
```

ポイント:

- `<form action={createTodo}>` のように、フォームのactionに**サーバー関数を直接渡せる**。
- 関数内では DB に直接書け、秘密も使える(サーバーだから)。
- 更新後に `revalidatePath` / `revalidateTag` で、キャッシュされた画面を最新化する。

これで「取得=Server Componentで `await`」「変更=Server Action」という、App Routerのデータの流れが一周しました。

### セキュリティの注意

Server Actionは「クライアントから呼べるサーバー関数」なので、**入力の検証と権限チェックを関数内で必ず行う**こと。クライアントを信用しない、が鉄則です。これは後述のエージェントレビューでも重要なチェック項目です。

---

## AIエージェントへの的確な指示

### エージェントを正しく指揮する

#### なぜ「概念理解」が「指示力」になるのか

- エージェントへの的確な指示とは、**自分で全部書けること**ではない
- むしろ**テックリードやレビュアーに近いスキル**
- 必要なのは次の3つ
	1. **正確なメンタルモデル**(何をどう作るべきか指定できる)
	2. **失敗を見抜く目**(出力の良し悪しをレビューできる)
	3. **何が現行か**を知っていること(古いコードを弾ける)

#### 前提を最初に固定する

- エージェントは放っておくと、学習データに多い古いパターン(Pages Router、Next 13/14時代の書き方)を出しがち
- 指示の冒頭で前提を固定すると、これを防げます。

> 「Next.js 16 の App Router で実装して。Server Component をデフォルトにして、インタラクションが必要な部品だけ `"use client"` に切り出す。データ取得は Server Component で直接 `await` し、`useEffect` でのfetchは使わない。`params` は非同期として `await` する。」

- このように**アーキテクチャの制約を先に渡す**と、出力が一段安定する

#### プロジェクトの規約をファイルに書く(AGENTS.md)

- 毎回同じ前提を打ち込むのは非効率です。現行の Next.js は、プロジェクトの規約をエージェントに伝えるためのファイル(`AGENTS.md` など)を最初から用意するようになっている
- ここに「App Router を使う」「この層でDBアクセスする」「命名規則」などを書いておくと、**恒久的な指示書**として効く

#### レビューの目:よくある失敗カタログ

エージェントの出力を、自分のメンタルモデルと突き合わせます。Next.jsで頻出のチェック項目を、この教材の各章に対応づけて挙げます。

- **server/client の取り違え**(第8章):`"use client"` が上に付きすぎていないか。サーバー専用処理をクライアントから呼んでいないか。
- **秘密の漏洩**(第8章):APIキーがClient Componentに渡っていないか。
- **古いデータ取得**(第5・9章):Server Componentで直接 `await` できる場面で `useEffect + fetch` を使っていないか。
- **ウォーターフォール**(第9章):独立した取得が直列になっていないか(`Promise.all` 候補)。
- **キャッシュの過不足**(第9章):意図せずキャッシュ/都度取得になっていないか。
- **key の欠落**(第4章):リストに安定したkeyが付いているか。
- **Server Actionの検証漏れ**(第10章):入力検証と権限チェックがあるか。
- **同期paramsなどの旧API**(第7章):`await` すべきものを同期で読んでいないか。

「これらを指摘できる」状態が、的確な指示が出せる状態とほぼ同義です。

#### 検証ループを回す

指示は細かく書きすぎず、**出てきた差分(diff)を自分のメンタルモデルと突き合わせて検証する**ループが基本です。「動くか」だけでなく「どこで動くか・データはどう流れるか」をレビューします。現行の Next.js はエージェント向けのツール(ブラウザのエラーをターミナルに転送する、診断情報をエージェントに見せる、MCP連携など)も整備されているので、それらを使うと検証が速くなります。

#### 仕上げ:小さく作って確かめる

エージェントに一度に大きな機能を作らせず、**小さな単位で作らせて、その都度レビュー・検証**する。各単位であなたのメンタルモデルと照合できるので、ズレが早期に見つかります。これは大規模な開発でも有効な進め方です。

