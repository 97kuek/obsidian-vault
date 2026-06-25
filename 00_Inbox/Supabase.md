
## Supabaseとは

- Supabaseは**PostgreSQLを中心に据えたBaaS（Backend as a Service）**
- ここで一番大事な対比がFirebaseとSupabaseの根本思想の違い
- Firebaseは独自のNoSQLドキュメントDBが中心で、独自のクエリ言語に乗ることになる
- 一方Supabaseは**ただのPostgreSQL**
- 中身は本物のリレーショナルDBで、`CREATE TABLE`も`JOIN`も外部キー制約もトランザクションも全部SQLそのまま使える
- この「ただのPostgresである」という点がSupabaseの設計哲学の核
- バックエンドの面倒な部分（認証・API・ストレージ・リアルタイム）を肩代わりしてくれるけれど、データ層は標準的なPostgresなので、いざとなれば普通のPostgresとして引っ越せるしロックインが弱い。Prismaを噛ませているのもまさにこの性質を使っていて、植木さんのスタックでは「Supabase = ホスティングされたPostgres」として扱い、ORMはPrismaが担当する、という分業になっているはずです。

## Supabaseを構成する6つの部品

- Supabaseは単一の製品ではなく、Postgresを取り囲む複数のオープンソースコンポーネントの集合体
- それぞれ独立したサービスとして動いていて、APIゲートウェイがリクエストを振り分けている

### 1. Database（PostgreSQL本体）

- テーブル・ビュー・関数・トリガー・拡張機能
- 後述するRLSもStorageのメタデータも認証ユーザー情報も、実体は全部このPostgresの中のテーブルに入っている
- 「Supabaseの機能はだいたいPostgresの上に実装されている」と理解すると一気に見通しが良くなる

### 2. Auto-generated API（PostgREST）

- **PostgRESTというツールが、テーブル定義を読み取って自動的にREST APIを生やしてくれます**。`users`テーブルを作れば、その瞬間に`/rest/v1/users`が使えるようになる。スキーマが即APIになるので、自前でCRUDエンドポイントを書く必要がない。`supabase-js`の`supabase.from('users').select()`は、内部的にはこのPostgREST APIへのHTTPリクエストに変換されています。

### 3. Auth（GoTrue）

- メール/パスワード、マジックリンク、電話番号、GoogleやGitHubなどのOAuthプロバイダ認証を提供します。サインアップしたユーザーは`auth.users`という専用スキーマのテーブルに格納されます。ここで発行されるのが**JWT**で、これが後のRLSと連動するのが超重要なポイントです（後述）。

**4. Storage** 画像やPDFなどのファイルを置くS3互換のオブジェクトストレージ。ファイル本体はストレージに、メタデータ（誰のどのファイルか）はPostgresのテーブルに入ります。だからファイルのアクセス制御も後述のRLSと同じ仕組みで書けます。

**5. Realtime** PostgresのWAL（Write-Ahead Log、書き込みログ）を監視して、テーブルの変更（INSERT/UPDATE/DELETE）をWebSocket経由でクライアントにプッシュします。「あるテーブルが更新されたら画面を即座に反映」みたいなことができる。これに加えてBroadcast（任意メッセージの送受信）とPresence（誰がオンラインか）の機能もあります。

**6. Edge Functions** Denoランタイムで動くサーバーレス関数。世界各地のエッジで実行されます。RLSでは書けない複雑なサーバー側ロジックや、外部API連携、Webhookの受け口などに使います。

ここまでの部品がどう組み合わさっているかを図にします。部品同士の関係を図にするとこうなります。クライアントからのリクエストはまずAPIゲートウェイを通り、用途に応じて各サービスに振り分けられ、最終的にはほぼすべてが中心のPostgreSQLに行き着きます。

### Row Level Security (RLS)

- 普通のWebアプリでは「ユーザーAは自分のデータしか見られない」という制御をバックエンドのアプリケーションコードで書く
- ところがSupabaseはPostgRESTでテーブルが**そのままAPIになってしまう**ので、もし無防備だと「`/rest/v1/users`を叩けば全員のデータが見える」状態になりかねない
- これを防ぐのがRLS（行レベルセキュリティ）
- RLSはPostgresにもともと備わっている機能で、「**このテーブルの各行に、誰がアクセスできるか**」をSQLのポリシーとして宣言する

```sql
-- studentsテーブルでRLSを有効化
alter table students enable row level security;

-- 「自分が担当する生徒だけ閲覧できる」ポリシー
create policy "tutors can view own students"
on students for select
using ( auth.uid() = tutor_id );
```

- ここで出てくる`auth.uid()`がポイント
- これは**いまリクエストしてきているログインユーザーのID**を返すPostgresの関数
- Authが発行したJWTがリクエストに含まれていて、Supabaseがそれを検証してこの値を埋めてくれる
- 「認証（Auth）」と「認可（RLS）」がJWTを介して直結している。
- **セキュリティの境界がアプリ層ではなくデータベース層に降りる**ことです。フロントから直接DBを叩いても、別のクライアントから叩いても、SQLを直接実行しても、ポリシーは必ず効く。アプリのバグでチェックを書き忘れても漏れない。一方で「ロジックがSQLポリシーに散る」「複雑な認可は書きにくい」という難しさもあって、ここがRLSの賛否が分かれるところです。

## 2種類のAPIキー

これもRLSとセットで必ず理解しておくべき部分です。Supabaseは大きく2つのキーを発行します。

`anon`キー（公開キー）は、フロントエンドに埋め込んでよいキーです。なぜ公開して安全かというと、このキー経由のアクセスには**RLSが必ず適用される**から。RLSさえちゃんと書いてあれば、ブラウザにキーが見えていても他人のデータは漏れません。

`service_role`キーは、**RLSを完全にバイパスする**管理者キーです。全データに無制限アクセスできるので、絶対にフロントに出してはいけない。サーバーサイド（API Route、Edge Function、バッチ処理）でのみ使います。「service_roleキーをクライアントに漏らす」のは典型的かつ致命的な事故です。

この対比（anon＝RLS適用・公開可／service_role＝RLSバイパス・サーバー専用）は面接でそのまま聞かれてもおかしくない知識です。

## 実際の使い方：3つの入り口

Supabaseを操作する経路は主に3つあります。

ひとつ目はダッシュボード（Web管理画面）。テーブル作成、SQLエディタ、Authのユーザー管理、Storageのファイル確認、ログ閲覧などをGUIでやれます。最初の構築や確認に使います。

ふたつ目がクライアントライブラリ。JS/TSなら`supabase-js`で、こんな書き味になります。

```ts
import { createClient } from '@supabase/supabase-js'
const supabase = createClient(URL, ANON_KEY)

// 取得（裏ではPostgREST APIへのHTTPリクエスト）
const { data, error } = await supabase
  .from('students')
  .select('id, name, grade')
  .eq('active', true)

// 挿入
await supabase.from('lessons').insert({ student_id, date, note })

// 認証
await supabase.auth.signInWithPassword({ email, password })
```

みっつ目が直接のPostgres接続。接続文字列（`postgresql://...`）を使って、**Supabaseを普通のPostgresとして**ORM（Prisma, Drizzleなど）やマイグレーションツールから触る経路です。植木さんのPrisma構成はこれ。なおサーバーレス環境（Vercelなど）では接続数が爆発しやすいので、Supabaseは**Supavisor**という接続プーラーを挟んだプーリング用の接続文字列を別途用意しています。`DATABASE_URL`にプーリング用、マイグレーション用に直結用、と2本持つのが定石です。

## Firebaseと比べてどっちを選ぶか

ざっくりした判断軸はこうです。

リレーショナルなデータ構造（生徒・授業・請求のように関連が明確で、JOINや集計、トランザクションが要る）ならSupabaseが素直です。SQLが書けて、データ設計の常識がそのまま通用する。逆に、スキーマレスで素早く回したい・ドキュメント単位で扱いたい・GoogleのモバイルSDK（プッシュ通知やCrashlytics）と深く統合したい、ならFirebaseが向きます。

Supabaseの強みはオープンソースでセルフホスト可能なこと、PostgresなのでpgvectorでベクトルDBにもなりAI用途に強いこと、ロックインが弱いこと。弱みはRealtimeや一部機能の成熟度がFirebaseほど枯れていない場面があること、RLSの設計に学習コストがあることです。

## 料金について

無料枠があり、その上に有料プラン（Pro / Team / Enterprise）が積み上がる従量＋定額の構成、という大枠は以前から変わっていません。ただ**具体的な金額・各枠の制限（DB容量、同時接続、ストレージ量、無料プロジェクトの一時停止条件など）は改定されることがある**ので、実際に使う前に[supabase.com/pricing](https://supabase.com/pricing)で最新を確認してください。ここは私の知識が古い可能性がある部分です。

---

全体像としては「**中身は本物のPostgres。その周りに認証・自動API・ストレージ・リアルタイム・関数を生やし、RLSとJWTでセキュリティをDB層に統合したのがSupabase**」と一言でまとめられます。

katekyoアプリの文脈で特に深掘りすると面接で効くのは、(1) 自分の構成はRLSベースかPrismaのアプリ層認可か、(2) anon/service_roleキーの使い分けをどう設計したか、(3) サーバーレスでの接続プーリングをどう扱ったか、あたりです。このどれかを具体的に説明できる準備をしておくと強いと思います。掘り下げたい部分はありますか。