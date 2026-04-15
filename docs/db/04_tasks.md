# Tasks

## 概要

このセクションでは、タスク管理の中核となる `tasks` テーブルを定義する。

このテーブルは、以下の2種類のタスクを統一的に管理する。

- 個人タスク
- プロジェクトタスク

---

## 役割

タスクの作成・進捗・担当・優先度・経験値など、  
アプリの主要機能をすべて集約する中心テーブル。

---

## カラム一覧

| カラム名 | 型 | NULL | 説明 |
|---|---|---:|---|
| id | uuid | NO | 主キー |
| project_id | uuid | YES | プロジェクトID（個人タスクはNULL） |
| owner_user_id | uuid | NO | タスク所有者 |
| title | varchar(200) | NO | タスク名 |
| description | text | YES | 詳細説明 |
| status | varchar(20) | NO | 進捗状態 |
| priority | varchar(20) | NO | 優先度 |
| assignee_user_id | uuid | YES | 担当者 |
| created_by_user_id | uuid | NO | 作成者 |
| updated_by_user_id | uuid | NO | 最終更新者 |
| due_date | timestamptz | YES | 期限 |
| completion_rate | integer | NO | 進捗率（0〜100） |
| xp_reward | integer | NO | 完了時の経験値 |
| xp_granted_at | timestamptz | YES | 経験値付与済み日時 |
| completed_at | timestamptz | YES | 完了日時 |
| archived_at | timestamptz | YES | アーカイブ日時 |
| archived_by_user_id | uuid | YES | アーカイブ実行者 |
| sort_order | integer | NO | 並び順 |
| created_at | timestamptz | NO | 作成日時 |
| updated_at | timestamptz | NO | 更新日時 |
| deleted_at | timestamptz | YES | 論理削除日時 |
| deleted_by_user_id | uuid | YES | 削除実行者 |

---

## 制約

- PRIMARY KEY (`id`)
- FOREIGN KEY (`project_id`) REFERENCES `projects(id)`
- FOREIGN KEY (`owner_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`assignee_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`created_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`updated_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`archived_by_user_id`) REFERENCES `users(id)`
- FOREIGN KEY (`deleted_by_user_id`) REFERENCES `users(id)`
- CHECK (`status` IN ('todo', 'in_progress', 'done'))
- CHECK (`priority` IN ('low', 'medium', 'high', 'urgent'))
- CHECK (`completion_rate BETWEEN 0 AND 100`)
- CHECK (`xp_reward >= 0`)

---

## タスクの種類

### 個人タスク

- `project_id IS NULL`
- `owner_user_id = ログインユーザー`

※自分専用のタスク

---

### プロジェクトタスク

- `project_id IS NOT NULL`

※チームで共有するタスク

---

## ステータス設計

| 値 | 意味 |
|---|---|
| todo | 未着手 |
| in_progress | 作業中 |
| done | 完了 |

---

## 優先度設計

| 値 | 意味 |
|---|---|
| low | 低 |
| medium | 中 |
| high | 高 |
| urgent | 緊急 |

---

## 補足

### owner_user_id と assignee_user_id

- `owner_user_id`: タスクの持ち主
- `assignee_user_id`: 実際に作業する人

#### 個人タスク
- owner = assignee（基本）

#### プロジェクトタスク
- owner ≠ assignee になることがある

---

### XP（経験値）管理

- タスク完了時に `xp_reward` を加算
- `xp_granted_at` が NULL の場合のみ付与

※二重付与を防ぐ

---

### 完了の定義

以下のいずれかで判定する。

- `status = 'done'`
- `completed_at IS NOT NULL`

---

### 並び順（sort_order）

- UI上での表示順制御に使用
- ドラッグ＆ドロップに対応可能

---

## 削除とアーカイブの違い

### deleted_at（論理削除）

- 完全に不要なタスク
- 通常表示から除外

---

### archived_at（アーカイブ）

- 完了済み・保管対象
- 履歴として残す

---

## tasks と他テーブルの関係

- users : tasks = 1 : N
- projects : tasks = 1 : N

```text
users (1) ---- (N) tasks
projects (1) ---- (N) tasks
```

---

## 注意点

### プロジェクトタスクの権限

タスクの操作は以下に依存する。

- `project_members` の所属
- `role`

※RLSで制御する

---

### データ取得時の条件

通常表示では以下を除外する。

- `deleted_at IS NOT NULL`
- 必要に応じて `archived_at IS NOT NULL`

---

## まとめ

- タスクはアプリの中心データ
- 個人・チーム両対応
- 進捗・優先度・期限を管理
- XP・レベルと連動
- アーカイブと削除を分離
- RLSにより安全にアクセス制御