# 管理画面仕様書

## 📋 概要

武器屋放置ゲームの管理画面は、ゲームマスターがマスターデータの管理、プレイヤーデータの確認、システム運用を行うためのWebアプリケーションです。

## 🏗️ 技術仕様

### フロントエンド
- **フレームワーク**: React 18.2+
- **言語**: TypeScript 5.0+
- **ビルドツール**: Vite 4.0+
- **UIライブラリ**: Material-UI (MUI) v5
- **状態管理**: Redux Toolkit + RTK Query
- **ルーティング**: React Router v6
- **HTTP通信**: Axios
- **チャート**: Chart.js / Recharts
- **日付処理**: date-fns
- **フォーム**: React Hook Form + Yup

### 開発環境
- **Node.js**: 18.0+
- **パッケージマネージャー**: npm
- **リンター**: ESLint + Prettier
- **テスト**: Vitest + React Testing Library

## 🎨 デザインシステム

### カラーパレット
- **プライマリ**: #1976d2 (青)
- **セカンダリ**: #dc004e (赤)
- **成功**: #2e7d32 (緑)
- **警告**: #ed6c02 (オレンジ)
- **エラー**: #d32f2f (赤)
- **背景**: #f5f5f5 (グレー)

### レスポンシブ対応
- **デスクトップ**: 1200px+
- **タブレット**: 768px - 1199px
- **モバイル**: 767px以下

## 📱 画面構成

### 1. レイアウト構造

```
┌─────────────────────────────────────┐
│ ヘッダー (AppBar)                    │
├─────────────┬───────────────────────┤
│             │                       │
│ サイドバー   │ メインコンテンツ        │
│ (Drawer)    │ (Main Content)        │
│             │                       │
│ - ダッシュ   │ ┌─────────────────┐   │
│ - 武器管理   │ │ ページコンテンツ  │   │
│ - 素材管理   │ │                 │   │
│ - レシピ管理 │ │                 │   │
│ - プレイヤー │ │                 │   │
│ - 設定      │ └─────────────────┘   │
│             │                       │
└─────────────┴───────────────────────┘
```

### 2. ナビゲーション構造

```
管理画面
├── ダッシュボード
├── マスターデータ管理
│   ├── 武器マスター
│   ├── 素材マスター
│   ├── レアリティ管理
│   └── 武器種別管理
├── ゲームデータ管理
│   ├── 合成レシピ
│   └── ドロップテーブル
├── プレイヤー管理
│   ├── プレイヤー一覧
│   ├── プレイヤー詳細
│   └── 統計情報
├── システム管理
│   ├── ログ管理
│   ├── データバックアップ
│   └── システム設定
└── ヘルプ・ドキュメント
```

## 🖥️ 画面詳細仕様

### 1. ダッシュボード

**目的**: システム全体の概要を一目で把握

**表示内容**:
- 統計サマリー (プレイヤー数、武器数、素材数等)
- 最近のアクティビティ
- システムステータス
- 人気武器ランキング
- 売上グラフ (日別、週別、月別)

**コンポーネント**:
```tsx
- DashboardPage
  - StatisticsCards (統計カード)
  - ActivityTimeline (アクティビティタイムライン)
  - PopularWeaponsChart (人気武器チャート)
  - SalesChart (売上チャート)
  - SystemStatus (システムステータス)
```

### 2. 武器マスター管理

**目的**: 武器マスターデータのCRUD操作

**機能**:
- 武器一覧表示 (ページネーション、検索、フィルター)
- 武器詳細表示・編集
- 新規武器作成
- 武器削除 (論理削除)
- 一括操作 (有効/無効切り替え)

**表示項目**:
- ID、名前、説明、武器種別、レアリティ
- 基本攻撃力、基本価格、必要レベル
- 画像URL、合成可能フラグ、有効フラグ
- 作成日時、更新日時

**フィルター**:
- 武器種別、レアリティ、レベル範囲
- 有効/無効、合成可能/不可

### 3. 素材マスター管理

**目的**: 素材マスターデータのCRUD操作

**機能**:
- 素材一覧表示
- 素材詳細表示・編集
- 新規素材作成
- 素材削除

**表示項目**:
- ID、名前、説明、レアリティ
- 基本価格、最大スタック数
- 画像URL、有効フラグ
- 作成日時、更新日時

### 4. 合成レシピ管理

**目的**: 武器合成レシピの管理

**機能**:
- レシピ一覧表示
- レシピ詳細表示・編集
- 新規レシピ作成
- 必要素材設定
- 成功率・コスト設定

**表示項目**:
- ID、名前、説明、対象武器
- ゴールドコスト、成功率、必要レベル
- 必要素材リスト
- 有効フラグ、作成日時

### 5. プレイヤー管理

**目的**: プレイヤーデータの確認・管理

**機能**:
- プレイヤー一覧表示
- プレイヤー詳細表示
- 所持武器・素材確認
- 統計情報表示
- アカウント状態管理 (BAN等)

**表示項目**:
- ID、ユーザー名、メールアドレス
- レベル、経験値、ゴールド、ジェム
- 最終ログイン、登録日
- アカウント状態

## 🔧 API連携仕様

### RTK Query設定

```typescript
// API Base
const baseQuery = fetchBaseQuery({
  baseUrl: 'http://localhost:8000/api/v1/',
  prepareHeaders: (headers) => {
    headers.set('authorization', `Bearer ${getToken()}`)
    return headers
  },
})

// API Endpoints
export const adminApi = createApi({
  reducerPath: 'adminApi',
  baseQuery,
  tagTypes: ['Weapon', 'Material', 'Recipe', 'Player'],
  endpoints: (builder) => ({
    // 武器関連
    getWeapons: builder.query<WeaponResponse, WeaponParams>({
      query: (params) => ({ url: 'weapons/', params }),
      providesTags: ['Weapon'],
    }),
    // 素材関連
    getMaterials: builder.query<MaterialResponse, MaterialParams>({
      query: (params) => ({ url: 'materials/', params }),
      providesTags: ['Material'],
    }),
    // その他...
  }),
})
```

### エラーハンドリング

```typescript
// 統一エラーハンドリング
const handleApiError = (error: any) => {
  if (error.status === 401) {
    // 認証エラー
    redirectToLogin()
  } else if (error.status >= 500) {
    // サーバーエラー
    showErrorNotification('サーバーエラーが発生しました')
  } else {
    // その他のエラー
    showErrorNotification(error.data?.message || 'エラーが発生しました')
  }
}
```

## 📊 データ表示仕様

### テーブル仕様

**共通機能**:
- ページネーション (10, 25, 50, 100件/ページ)
- ソート (昇順・降順)
- 検索 (名前、ID等)
- フィルター (カテゴリ別)
- 一括選択・操作
- CSV エクスポート

**表示形式**:
```tsx
<DataGrid
  rows={data}
  columns={columns}
  pageSize={pageSize}
  pagination
  checkboxSelection
  disableSelectionOnClick
  onPageSizeChange={setPageSize}
  onSortModelChange={handleSort}
  components={{
    Toolbar: CustomToolbar,
  }}
/>
```

### フォーム仕様

**バリデーション**:
- 必須項目チェック
- 型チェック (数値、文字列等)
- 範囲チェック (最小値、最大値)
- 重複チェック (名前等)

**フォーム例**:
```tsx
const weaponSchema = yup.object({
  name: yup.string().required('名前は必須です').max(100),
  base_attack: yup.number().required().min(1).max(9999),
  base_price: yup.number().required().min(0),
  required_level: yup.number().required().min(1).max(100),
})
```

## 🔐 セキュリティ仕様

### 認証・認可

**認証方式**: JWT Bearer Token
**権限レベル**:
- **Super Admin**: 全機能アクセス可能
- **Admin**: データ管理のみ
- **Viewer**: 閲覧のみ

**実装**:
```typescript
// 権限チェック
const usePermission = (requiredRole: Role) => {
  const user = useSelector(selectCurrentUser)
  return user?.role >= requiredRole
}

// 保護されたルート
<ProtectedRoute requiredRole={Role.ADMIN}>
  <WeaponManagement />
</ProtectedRoute>
```

## 📱 レスポンシブ対応

### ブレークポイント
- **xs**: 0px - 599px (モバイル)
- **sm**: 600px - 959px (タブレット縦)
- **md**: 960px - 1279px (タブレット横)
- **lg**: 1280px - 1919px (デスクトップ)
- **xl**: 1920px+ (大画面)

### 対応方針
- モバイル: サイドバー → ドロワー
- タブレット: 2カラム → 1カラム
- テーブル: 横スクロール対応

## 🧪 テスト仕様

### テスト種別
- **Unit Test**: コンポーネント単体
- **Integration Test**: API連携
- **E2E Test**: ユーザーフロー

### テスト例
```typescript
describe('WeaponList', () => {
  it('武器一覧が表示される', async () => {
    render(<WeaponList />)
    await waitFor(() => {
      expect(screen.getByText('鉄の剣')).toBeInTheDocument()
    })
  })
})
```

## 🚀 デプロイ仕様

### Docker化
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "run", "preview"]
```

### 環境変数
```env
VITE_API_BASE_URL=http://localhost:8000/api/v1
VITE_APP_TITLE=武器屋管理画面
VITE_APP_VERSION=1.0.0
```

---
最終更新: 2025/06/02 23:01
