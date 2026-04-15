# Users / User Progress

## 概要

このセクションでは、ユーザーに関するテーブルを定義する。

- `users`
- `user_progress`

この2つにより、

- ユーザーのプロフィール情報
- ユーザーの成長要素（経験値・レベル）

を分離して管理する。

---

# users

## 役割

アプリ利用者のプロフィール情報を管理するテーブル。

認証自体は Supabase Auth に任せるため、  
このテーブルでは以下のみを扱う。

- 表示名
- メールアドレス
- アイコン
- アプリ内ユーザーID

---

## カラム一覧

| カラム名 | 型 | NULL | 説明 |
|---|---|---:|---|
| id | uuid | NO | アプリ内ユーザーID（主キー） |
| auth_user_id | uuid | NO | Supabase Auth のユーザーID |
| display_name | varchar(50) | NO | 表示名 |
| email | varchar(255) | NO | メールアドレス |
| avatar_url | text | YES | アイコン画像URL |
| created_at | timestamptz | NO | 作成日時 |
| updated_at | timestamptz | NO | 更新日時 |
| deleted_at | timestamptz | YES | 論理削除日時 |

---

## 制約

- PRIMARY KEY (`id`)
- UNIQUE (`auth_user_id`)
- UNIQUE (`email`)

---

## 補足

### 認証との関係

- `auth_user_id` は Supabase Auth の `auth.users.id` と対応する
- アプリ内では `users.id` を主キーとして扱う

### なぜパスワードを持たないか

- 認証は Supabase に委譲しているため
- セキュリティリスクを下げるため

---

# user_progress

## 役割

ユーザーの成長要素（経験値・レベル）を管理するテーブル。

---

## カラム一覧

| カラム名 | 型 | NULL | 説明 |
|---|---|---:|---|
| id | uuid | NO | 主キー |
| user_id | uuid | NO | 対象ユーザーID |
| level | integer | NO | 現在レベル |
| current_xp | integer | NO | 現在レベル内の経験値 |
| total_xp | integer | NO | 累計経験値 |
| completed_task_count | integer | NO | 完了タスク数 |
| completed_project_count | integer | NO | 完了プロジェクト数 |
| last_level_up_at | timestamptz | YES | 最後のレベルアップ日時 |
| created_at | timestamptz | NO | 作成日時 |
| updated_at | timestamptz | NO | 更新日時 |

---

## 制約

- PRIMARY KEY (`id`)
- UNIQUE (`user_id`)
- FOREIGN KEY (`user_id`) REFERENCES `users(id)`
- CHECK (`level >= 1`)
- CHECK (`current_xp >= 0`)
- CHECK (`total_xp >= 0`)
- CHECK (`completed_task_count >= 0`)
- CHECK (`completed_project_count >= 0`)

---

## 補足

### 1ユーザー = 1レコード

- `user_id` に UNIQUE 制約をつけることで、1対1関係を保証する

---

### なぜ users と分けるのか

理由は2つ。

#### ① 責務の分離
- users → アカウント情報
- user_progress → ゲーム的成長

#### ② 将来拡張のため
今後追加しやすくなる。

例:

- 実績（achievements）
- 称号（titles）
- ステータス
- スキル

---

### XP設計の考え方（v1）

- タスク完了時に経験値を付与
- `tasks.xp_reward` を使用
- 付与済み判定は `tasks.xp_granted_at` で管理

---

### レベルアップ処理

基本的な流れ：

1. タスク完了
2. XP加算
3. `current_xp` が閾値を超えたら
4. `level` を増加
5. `last_level_up_at` を更新

---

## users と user_progress の関係

- users : user_progress = 1 : 1

```text
users (1) ---- (1) user_progress
```

---

## 注意点

### ユーザー作成時の処理

新規ユーザー登録時には以下を同時に行う。

- `users` にレコード作成
- `user_progress` に初期レコード作成

例：

- level = 1  
- current_xp = 0  
- total_xp = 0  

---

## まとめ

- 認証は Supabase に任せる  
- プロフィールと成長要素を分離  
- 将来拡張しやすい構成  
- 1ユーザー1成長レコードでシンプルに管理  