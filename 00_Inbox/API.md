## APIとは何か

- **Application Programming Interface** の略  
- 日本語にすると、**アプリケーション同士がやり取りするための窓口・約束ごと** 

### 身近な例

- たとえば、天気アプリを開くと現在の天気が表示される
- 多くの場合、天気情報を提供しているサーバーに対して、「東京の今日の天気を教えて」とリクエストする
- そのとき以下のようなデータを返す

```json
{
  "city": "Tokyo",
  "weather": "sunny",
  "temperature": 28
}
```

- このやり取りを可能にしているのが **Web API** 

## WebアプリにおけるAPIの位置づけ

- Webアプリでは、よく次のような構成になる

```text
ユーザー
  ↓
フロントエンド
  ↓ API
バックエンド
  ↓
データベース
```

## APIでやり取りするもの
### 1. エンドポイント

- エンドポイントは、APIのURL  
- どの機能を呼び出すかを表す
- ホテル予約システムなら、以下は「予約に関するAPI」だと考えられる

```text
/api/reservations
```

### 2. HTTPメソッド

- HTTPメソッドは、**何をしたいのか** を表す

|メソッド|意味|例|
|---|---|---|
|GET|取得する|予約一覧を取得する|
|POST|新しく作る|予約を作成する|
|PUT / PATCH|更新する|予約内容を変更する|
|DELETE|削除する|予約をキャンセルする|
- ホテル予約システムなら、以下は「予約一覧を取得するAPI」

```text
GET /api/reservations
```

## リクエストとレスポンス

- APIの基本は、「リクエスト→レスポンス」という流れ
### リクエスト

- リクエストは、クライアントからサーバーへのお願い

```http
POST /api/reservations
Content-Type: application/json
```

```json
{
  "userId": 1,
  "roomId": 5,
  "checkIn": "2026-07-01",
  "checkOut": "2026-07-03"
}
```

### レスポンス

- レスポンスは、サーバーからクライアントへの返事

```json
{
  "reservationId": 100,
  "status": "confirmed",
  "message": "予約が完了しました"
}
```

## ステータスコード

- APIのレスポンスには、処理結果を表す **ステータスコード** が付く
- 代表的なものは次の通り

|ステータスコード|意味|
|---|---|
|200|成功|
|201|作成成功|
|400|リクエストが間違っている|
|401|ログインが必要|
|403|権限がない|
|404|データが見つからない|
|500|サーバー側のエラー|

- たとえば、存在しない予約IDを取得しようとしたら、以下のステータスコードが返る

```http
404 Not Found
```

## JSONとは何か

- APIでは、データのやり取りに **JSON** がよく使われる

```json
{
  "id": 1,
  "name": "田中太郎",
  "email": "tanaka@example.com"
}
```

## REST APIとは何か

- APIの設計方法の一つに **REST API** がある
- RESTでは、データを「リソース」として考えます。
- たとえばホテル予約システムなら、以下のようにリソースとして扱う

```text
/users
/hotels
/rooms
/reservations
```

- そして、HTTPメソッドで操作を表す

```text
GET    /api/reservations        予約一覧を取得
GET    /api/reservations/1      予約ID 1を取得
POST   /api/reservations        新しい予約を作成
PATCH  /api/reservations/1      予約ID 1を変更
DELETE /api/reservations/1      予約ID 1を削除
```

- REST APIでは、URLはなるべく「名詞」にして、操作はHTTPメソッドで表すのが基本

```text
/api/getReservations
/api/createReservation
```

よりも、

```text
GET  /api/reservations
POST /api/reservations
```

の方がRESTらしい設計

## APIはなぜ必要なのか

- APIがあると、フロントエンドとバックエンドを分けて開発できる

## Next.jsで考えるAPI

- Next.js App Router 構成だと、APIは例えば次のように作れる

```text
app/api/reservations/route.ts
```

- このファイルに、以下のように書く

```ts
export async function GET() {
  // 予約一覧を取得する処理
}

export async function POST(request: Request) {
  // 新しい予約を作成する処理
}
```

- フロントエンド側で以下のように書くことでAPIを呼び出せる

```ts
await fetch("/api/reservations")
```

## API設計で大事なこと

### 1. 何のデータを扱うか

```text
ユーザー
ホテル
部屋
予約
支払い
```

### 2. どんな操作が必要か

```text
予約を作る
予約を確認する
予約を変更する
予約をキャンセルする
```

### 3. 誰が操作できるか

### 4. エラー時に何を返すか

## APIでよく出てくる用語

|用語|意味|
|---|---|
|クライアント|APIを呼び出す側。ブラウザやスマホアプリなど|
|サーバー|APIを提供する側|
|エンドポイント|APIのURL|
|リクエスト|クライアントからサーバーへの要求|
|レスポンス|サーバーからクライアントへの返事|
|JSON|APIでよく使うデータ形式|
|HTTPメソッド|GET、POST、PATCH、DELETEなど|
|ステータスコード|成功・失敗を表す番号|
|認証|ログインしているか確認すること|
|認可|その操作をしてよい権限があるか確認すること|
