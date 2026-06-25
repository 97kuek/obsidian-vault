---
date: 2026-06-25
tags:
  - reference
  - ソフトウェア開発
---# Next.js App Router

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
