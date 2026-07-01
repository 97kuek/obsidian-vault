---
date: 2026-07-01
tags:
  - ソフトウェア開発
  - データベース
---

# DBとは何か

- DBは **Database** の略
- データを安全に保存し、あとから検索・追加・更新・削除できる仕組み
# DBとDBMSの違い

|用語|意味|
|---|---|
|DB|保存されているデータの集まり|
|DBMS|DBを操作・管理するソフトウェア|

| DBMS            | よく使われる場面          |
| --------------- | ----------------- |
| MySQL           | Webアプリでよく使う       |
| PostgreSQL      | 本格的なWebアプリ、業務システム |
| SQLite          | 小規模アプリ、ローカル開発、学習用 |
| Oracle Database | 大企業の基幹システム        |
| SQL Server      | Microsoft系の業務システム |

# なぜDBが必要なのか

|DBが得意なこと|説明|
|---|---|
|検索|条件に合うデータを高速に探せる|
|追加|新しいデータを安全に登録できる|
|更新|既存のデータを書き換えられる|
|削除|不要なデータを消せる|
|整合性管理|おかしなデータを防げる|
|同時アクセス|複数人が同時に使っても壊れにくい|
|権限管理|誰が何を見られるか制御できる|

# DBの基本操作：CRUD

|操作|意味|SQLの命令|
|---|---|---|
|Create|データを追加する|`INSERT`|
|Read|データを読む|`SELECT`|
|Update|データを更新する|`UPDATE`|
|Delete|データを削除する|`DELETE`|

- 「顧客を追加する」はCreate

```sql
INSERT INTO customers (name, email)
VALUES ('山田太郎', 'yamada@example.com');
```

- 「顧客一覧を見る」はRead

```sql
SELECT * FROM customers;
```

- 「メールアドレスを変更する」はUpdate

```sql
UPDATE customers
SET email = 'new-yamada@example.com'
WHERE id = 1;
```

- 「顧客を削除する」はDelete

```sql
DELETE FROM customers
WHERE id = 1;
```

# リレーショナルデータベース(RDB)

- RDBでは、データを **表** の形で管理する
## RDBの例

|  id | name | email                                           |
| --: | ---- | ----------------------------------------------- |
|   1 | 山田太郎 | [yamada@example.com](mailto:yamada@example.com) |
|   2 | 佐藤花子 | [sato@example.com](mailto:sato@example.com)     |

## テーブル・行・列

|用語|意味|
|---|---|
|テーブル|データを入れる表|
|行|1件分のデータ|
|列|データの項目|
|レコード|行とほぼ同じ意味|
|カラム|列とほぼ同じ意味|

## 主キーとは

- そのデータを一意に識別するための値のこと
- たとえば顧客テーブルなら `id` が主キーになる

|id|name|
|--:|---|
|1|山田太郎|
|2|山田太郎|

- 同じ名前の人が複数いる可能性はあるが、`id` があれば、「idが1の山田太郎さん」「idが2の山田太郎さん」として区別できる

## 外部キーとは

-  他のテーブルのデータを参照するためのキー
- たとえば予約テーブルを考えたとき、

|id|customer_id|room_id|check_in|check_out|
|--:|--:|--:|---|---|
|1|3|101|2026-06-25|2026-06-27|

- ここで `customer_id` は、顧客テーブルの `id` を指している

つまり、

```txt
customer_id = 3
```

というのは、

```txt
customersテーブルのid=3の顧客が予約した
```

- 部屋も同じで、`room_id` は rooms テーブルの `id` を参照します。

## なぜテーブルを分けるのか

- たとえば予約テーブルをこのように作ることもできる

|予約ID|顧客名|メール|部屋番号|部屋タイプ|チェックイン|
|--:|---|---|---|---|---|
|1|山田太郎|[yamada@example.com](mailto:yamada@example.com)|101|シングル|6/25|
|2|山田太郎|[yamada@example.com](mailto:yamada@example.com)|102|ダブル|7/1|

- 顧客のメールアドレスが変わったら、山田太郎さんが出てくるすべての予約行を更新しないといけない
### customers

|id|name|email|
|--:|---|---|
|1|山田太郎|[yamada@example.com](mailto:yamada@example.com)|
### reservations

|id|customer_id|room_id|check_in|
|--:|--:|--:|---|
|1|1|101|2026-06-25|
|2|1|102|2026-07-01|

- このように、データの重複を減らして整理することを **正規化** と言う

## テーブル同士の関係

- RDBでは、テーブル同士の関係がとても重要
- 主に1対1、1対多、多対多がある

