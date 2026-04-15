# RLS (Row Level Security)

## 概要

Taskuest v1 では、Supabase の Row Level Security（RLS）を利用して、  
ユーザーごとのアクセス制御をデータベースレベルで実現する。

RLSにより、

- 他ユーザーのデータを参照できない
- 所属していないプロジェクトのデータにアクセスできない

といった制御を安全に行う。

---

## RLSとは

RLS（Row Level Security）は、

※「どの行をそのユーザーが操作していいか」

をデータベース側で制御する仕組み。

---

### 従来の制御（アプリ側のみ）

```text
フロントでフィルタする
→ ミスをした場合他人のデータが見える可能性あり
```

---

### RLSあり

DBが最初から条件に合うデータしか返さない  
→ セキュリティが強固になる

---

## 認証との関係

Supabaseでは、ログイン中のユーザーは以下で取得できる。

- `auth.uid()`

これは Supabase Auth のユーザーID。

---

## Taskuestでのユーザー特定

Taskuestでは以下の対応関係を持つ。

- `auth.uid()` → SupabaseのユーザーID
- `users.auth_user_id` → 上記と一致
- `users.id` → アプリ内ユーザーID

---

### ヘルパー関数

この対応を簡潔にするため、以下の関数を使用する。

```sql
select public.get_current_user_id();
```

---

## テーブルごとの制御方針

---

### users

#### 方針
- 自分の情報のみ参照・更新可能

#### ルール
- `auth.uid() = auth_user_id`

---

### user_progress

#### 方針
- 自分の成長情報のみ操作可能

#### ルール
- `user_id = get_current_user_id()`

---

### projects

#### 方針
- 以下の場合のみアクセス可能
  - 自分がオーナー
  - 自分がメンバー

#### SELECT
- owner または project_members に存在する場合

#### INSERT
- 自分が作成者かつ owner であること

#### UPDATE
- owner または admin

#### DELETE
- owner のみ

---

### project_members

#### 方針
- 同じプロジェクトのメンバーのみ閲覧可能

#### SELECT
- 自分がそのプロジェクトに所属している場合

#### INSERT / UPDATE / DELETE
- owner または admin のみ

---

### tasks

#### 方針
- 個人タスクとプロジェクトタスクで制御を分ける

---

#### 個人タスク

条件：

- `project_id IS NULL`
- `owner_user_id = 自分`

自分のみアクセス可能

---

#### プロジェクトタスク

条件：

- 自分が project_members に存在する

プロジェクトメンバーのみアクセス可能

---

#### INSERT / UPDATE / DELETE

- 個人タスク → owner のみ
- プロジェクトタスク → メンバー（またはロールに応じて制御）

---

## 注意点

### プロジェクト作成時の重要処理

`projects` 作成後は必ず以下を行う。

- `project_members` に owner を登録

```text
user_id = owner_user_id
role = 'owner'
```


これを行わないと、RLSによりアクセスできなくなる可能性がある。

---

### RLSは「許可ルール」

RLSは、

「許可された条件だけ通す」

仕組み。

そのため、

- ルールに一致しないデータは見えない
- 明示的に許可しないと操作できない

---

### フロントとの役割分担

RLSはセキュリティの最終防衛線。

フロントでは以下も併用する。

- UI上の制御（ボタン表示など）
- バリデーション

---

## v1の設計方針

Taskuest v1では以下を重視する。

- シンプルで分かりやすい制御
- 必要十分なセキュリティ
- 将来拡張しやすい構造

---

## 将来拡張

将来的には以下のような制御も可能。

- タスク編集は admin 以上のみ
- 削除は owner のみ
- 読み取り専用メンバーの追加
- 招待リンクによる参加制御

---

## まとめ

- RLSによりDBレベルで安全なアクセス制御を実現
- `auth.uid()` を起点にユーザーを特定
- project_members を中心に権限を管理
- 個人タスクとプロジェクトタスクを分けて制御
- v1としてシンプルかつ実用的な設計