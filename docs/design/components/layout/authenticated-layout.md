# AuthenticatedLayout コンポーネント設計

## 1. 概要

`AuthenticatedLayout` は、Taskuest v1 における認証後画面の共通レイアウトコンポーネントである。  
主に以下の用途で使用する。

- Header と Sidebar を含む画面構造の提供
- 各ページコンテンツの表示領域の提供
- 認証後画面の統一されたレイアウトの構築

本コンポーネントは、**画面全体の構造と配置のみに責務を限定**し、  
業務ロジックや各コンポーネントの内部処理は持たない。

---

## 2. 目的

- 認証後画面のレイアウトを統一する
- Header / Sidebar / main の配置を共通化する
- 各ページ実装時のレイアウト記述を簡素化する
- 過剰な機能追加を避け、v1 時点で保守しやすい設計にする

---

## 3. 配置場所

```txt
src/components/layout/AuthenticatedLayout/
├─ AuthenticatedLayout.tsx
├─ AuthenticatedLayout.test.tsx
└─ index.ts
```

## 4. 責務

`AuthenticatedLayout` が担当する責務は以下とする。

- Header の配置
- Sidebar の配置
- メインコンテンツ領域の表示
- レイアウト全体の構造管理
- 共通スタイルの適用

---

## 5. 担当しない責務

以下は `AuthenticatedLayout` の責務に含めない。

- 業務ロジックの管理
- データ取得・API通信
- 各ページの状態管理
- Header / Sidebar の内部処理
- 画面遷移処理
- 認証チェック（必要であれば上位で管理）

これらはページまたは上位コンポーネントで対応する。

---

## 6. 使用するHTML要素

- `div`
- `main`

---

## 7. Props 設計

| Props名 | 型 | 必須 | 説明 |
|---|---|---:|---|
| children | `React.ReactNode` | ○ | メインコンテンツ |
| headerProps | `HeaderProps` | △ | Header に渡すProps |
| sidebarProps | `SidebarProps` | △ | Sidebar に渡すProps |
| className | `string` | △ | レイアウト全体の拡張用クラス |

### 7.1 設計判断

- `children` によりページコンテンツを柔軟に差し込む
- Header / Sidebar の状態は外部から受け取る
- レイアウトは構造のみに責務を限定する
- 内部で状態を持たない設計とする

---

## 8. 表示仕様

### 8.1 レイアウト構造
- 上部に Header を配置する
- 左側に Sidebar を配置する
- 右側に main コンテンツを配置する

### 8.2 メイン領域
- `children` に渡された内容を表示する

---

## 9. アクセシビリティ

- `main` 要素を使用しコンテンツ領域を明確にする
- 視覚的に領域分離が分かる構造にする
- キーボード操作で各領域へアクセス可能にする

---

## 10. 想定利用例

### 10.1 task-list ページ

```tsx
<AuthenticatedLayout>
  <TaskListPage />
</AuthenticatedLayout>
```

## 11. 再定義コンポーネント候補

- なし（基本レイアウトとして利用）

---

## 12. 実装方針

- `AuthenticatedLayout.tsx` を単体で実装する
- Header / Sidebar を組み合わせて構成する
- 各ページは本コンポーネントをラップして使用する
- 状態管理はページまたは上位で行う

---

## 13. テスト観点

### 13.1 単体テスト対象
- Header が表示されること
- Sidebar が表示されること
- children が表示されること

### 13.2 テストしないこと
- 業務ロジック
- データ取得処理

---

## 14. 今後の拡張候補

- レスポンシブ対応（モバイル）
- Sidebar の表示切り替え強化
- レイアウトパターンの追加