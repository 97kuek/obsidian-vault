---
date: 2026-07-01
tags:
  - ソフトウェア開発
  - データベース
---

# SQLとは

- SQLは、DBを操作するための言語
## データを取得する

```sql
SELECT *
FROM customers;
```

## 条件をつけて取得する

```sql
SELECT *
FROM customers
WHERE name = '山田太郎';
```

## 並び替える

```sql
SELECT *
FROM reservations
ORDER BY check_in ASC;
```

## 件数を数える

```sql
SELECT COUNT(*)
FROM reservations;
```

## 複数テーブルを結合する

```sql
SELECT
  reservations.id,
  customers.name,
  rooms.room_number,
  reservations.check_in,
  reservations.check_out
FROM reservations
JOIN customers
  ON reservations.customer_id = customers.id
JOIN rooms
  ON reservations.room_id = rooms.id;
```

これで、

```txt
予約ID
顧客名
部屋番号
チェックイン日
チェックアウト日
```

をまとめて取得できる
# JOINとは

JOINは、複数のテーブルをつなげて見るための仕組みです。

たとえば reservations テーブルには `customer_id` しか入っていません。

|id|customer_id|room_id|
|--:|--:|--:|
|1|3|101|

これだけだと、顧客名はわかりません。

そこで customers テーブルとJOINします。

```sql
SELECT
  reservations.id,
  customers.name
FROM reservations
JOIN customers
  ON reservations.customer_id = customers.id;
```

これにより、

|reservation_id|name|
|--:|---|
|1|山田太郎|

のように、予約と顧客情報を組み合わせて見られます。

RDBを理解するうえで、JOINはかなり重要です。

---

# 制約とは

- DBには **おかしなデータを入れないためのルール** を設定できる
- これを制約と言う

|制約|意味|
|---|---|
|PRIMARY KEY|主キー。一意に識別する|
|FOREIGN KEY|外部キー。他テーブルを参照する|
|NOT NULL|空を許さない|
|UNIQUE|重複を許さない|
|CHECK|条件を満たす値だけ許す|
|DEFAULT|初期値を設定する|

たとえば、

```sql
email TEXT NOT NULL UNIQUE
```

とすると、

```txt
メールアドレスは空にできない
同じメールアドレスを重複登録できない
```

という意味になる

- DB設計では、アプリ側だけでチェックするのではなく、DB側にも最低限の制約を置くのが重要

