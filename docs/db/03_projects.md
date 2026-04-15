# Projects / Project Members

## 概要

このセクションでは、プロジェクトとチーム管理に関するテーブルを定義する。

- `projects`
- `project_members`

この2つにより、

- プロジェクト単位のタスク管理
- ユーザーの所属管理
- ロール（権限）管理

を実現する。

---

# projects

## 役割

プロジェクトの本体を管理するテーブル。

プロジェクトは、複数ユーザーでタスクを共有・管理するための単位。

---

## カラム一覧

| カラム名 | 型 | NULL | 説明 |
|---|---|---:|---|
| id | uuid | NO | 主キー |
| name | varchar(100) | NO | プロジェクト名 |
| description | text | YES | 説明 |
| owner_user_id | uuid | NO | プロジェクト所有者 |
| visibility | varchar(20) | NO | 公開範囲 |
| status | varchar(20) | NO | 状態 |
| created_at | timestamptz | NO | 作成日時 |
| created_by_user_id | uuid | NO | 作成者 |
| updated_at | timestamptz | NO | 更新日時 |
| updated_by_user_id | uuid | NO | 最終更新者 |
| deleted_at | timestamptz | YES | 論理削除日時 |
| deleted_by_user_id | uuid | YES | 削除実行者 |

---

## 制約

- PRIMARY KEY (`id`)
- FOREIGN KEY (`owner_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`created_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`updated_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`deleted_by_user_id`) REFERENCES `users(id)`
- CHECK (`visibility` IN ('private', 'team'))
- CHECK (`status` IN ('active', 'archived'))

---

## 補足

### visibility の意味

- `private`: 個人用または限定的なプロジェクト
- `team`: チームで共有するプロジェクト

v1では表示制御の補助として扱う（主な制御はRLSで実施）

---

### status の意味

- `active`: 通常状態
- `archived`: アーカイブ状態

プロジェクト単位で「終了したが残しておきたい」状態を表現する。

---

### owner_user_id の役割

- プロジェクトの責任者
- 削除などの最終権限を持つ

ただし、実際の操作権限は `project_members.role` とRLSで制御する。

---

# project_members

## 役割

ユーザーとプロジェクトの関係を管理する中間テーブル。

これにより、

- 複数ユーザーが1プロジェクトに所属
- 1ユーザーが複数プロジェクトに所属

を表現できる。

---

## カラム一覧

| カラム名 | 型 | NULL | 説明 |
|---|---|---:|---|
| id | uuid | NO | 主キー |
| project_id | uuid | NO | プロジェクトID |
| user_id | uuid | NO | ユーザーID |
| role | varchar(20) | NO | ロール |
| joined_at | timestamptz | NO | 参加日時 |
| invited_by_user_id | uuid | YES | 招待したユーザー |
| is_active | boolean | NO | 所属有効フラグ |
| created_at | timestamptz | NO | 作成日時 |
| created_by_user_id | uuid | NO | 作成者 |
| updated_at | timestamptz | NO | 更新日時 |
| updated_by_user_id | uuid | NO | 最終更新者 |
| deleted_at | timestamptz | YES | 論理削除日時 |
| deleted_by_user_id | uuid | YES | 削除実行者 |

---

## 制約

- PRIMARY KEY (`id`)
- FOREIGN KEY (`project_id`) REFERENCES `projects(id)`
- FOREIGN KEY (`user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`invited_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`created_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`updated_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`deleted_by_user_id`) REFERENCES `users(id)`
- UNIQUE (`project_id`, `user_id`)
- CHECK (`role` IN ('owner', 'admin', 'member'))

---

## 補足

### role の意味

- `owner`: プロジェクト所有者
- `admin`: メンバー管理や編集が可能
- `member`: 通常メンバー

---

### is_active の役割

- `true`: 現在所属中
- `false`: 脱退済み（履歴として残す）

---

### UNIQUE制約の意味

`(project_id, user_id)` に UNIQUE をつけることで、

※同じユーザーが同じプロジェクトに重複所属するのを防ぐ

---

### なぜ中間テーブルが必要か

`projects` に直接 user を持たせない理由：

- 複数人対応ができない
- ロール管理ができない
- 拡張が難しい

そのため、`project_members` を使用する。

---

## projects と project_members の関係

- projects : project_members = 1 : N
- users : project_members = 1 : N

```text 
users (1) ---- (N) project_members (N) ---- (1) projects
```


---

## 注意点

### プロジェクト作成時の処理

プロジェクト作成時は必ず以下を行う。

1. `projects` にレコード作成  
2. 同時に `project_members` にもレコード作成  

その際：

- `user_id = owner_user_id`
- `role = 'owner'`

これを行わないと、RLSでアクセスできなくなる可能性がある。

---

### 削除の扱い

- `deleted_at` は論理削除
- 実際にはデータを残す

---

## まとめ

- プロジェクト本体は `projects` で管理  
- 所属関係は `project_members` で管理  
- ロールによる権限制御が可能  
- 多対多関係を正しく表現  
- RLSと組み合わせることで安全なアクセス制御が実現できる  