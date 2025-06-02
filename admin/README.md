# 武器屋放置ゲーム 管理画面

武器屋放置ゲームの管理画面です。ゲームマスターがマスターデータの管理、プレイヤーデータの確認、システム運用を行うためのWebアプリケーションです。

## 🚀 クイックスタート

### 前提条件
- Node.js 18.0+
- npm

### セットアップ

```bash
# 依存関係のインストール
npm install

# 開発サーバー起動
npm run dev

# ビルド
npm run build

# プレビュー
npm run preview
```

### アクセス情報
- **開発サーバー**: http://localhost:5173
- **バックエンドAPI**: http://localhost:8000

## 🏗️ 技術スタック

- **React**: 18.2+
- **TypeScript**: 5.0+
- **Vite**: 4.0+
- **Material-UI**: v5
- **Redux Toolkit**: 状態管理
- **RTK Query**: API通信
- **React Router**: ルーティング

## 📱 機能一覧

### ✅ 実装済み
- **ダッシュボード**: システム統計・概要表示
- **基本レイアウト**: レスポンシブナビゲーション
- **武器管理**: 武器一覧表示（モックデータ）
- **素材管理**: 基本画面
- **レシピ管理**: 基本画面
- **プレイヤー管理**: 基本画面

### 🚧 開発中
- API連携（現在はモックデータ）
- CRUD操作
- 検索・フィルター機能
- データ分析・グラフ

### ⏳ 予定
- 認証機能
- リアルタイム更新
- データエクスポート
- ログ管理

## 📁 プロジェクト構造

```
admin/
├── src/
│   ├── components/          # 共通コンポーネント
│   │   └── Layout.tsx      # メインレイアウト
│   ├── pages/              # ページコンポーネント
│   │   ├── Dashboard.tsx   # ダッシュボード
│   │   ├── WeaponList.tsx  # 武器管理
│   │   ├── MaterialList.tsx # 素材管理
│   │   ├── RecipeList.tsx  # レシピ管理
│   │   └── PlayerList.tsx  # プレイヤー管理
│   ├── services/           # API通信
│   │   └── api.ts         # RTK Query設定
│   ├── store/             # Redux store
│   │   └── index.ts       # Store設定
│   ├── types/             # TypeScript型定義
│   │   └── index.ts       # 型定義
│   ├── utils/             # ユーティリティ
│   ├── hooks/             # カスタムフック
│   ├── App.tsx            # メインアプリ
│   └── main.tsx           # エントリーポイント
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 🎨 デザインシステム

### カラーパレット
- **プライマリ**: #1976d2 (青)
- **セカンダリ**: #dc004e (赤)
- **成功**: #2e7d32 (緑)
- **警告**: #ed6c02 (オレンジ)
- **エラー**: #d32f2f (赤)

### レスポンシブ対応
- **デスクトップ**: 1200px+
- **タブレット**: 768px - 1199px
- **モバイル**: 767px以下

## 🔧 開発ガイド

### 新しいページの追加

1. `src/pages/` にコンポーネントを作成
2. `src/components/Layout.tsx` のメニューに追加
3. `src/App.tsx` にルートを追加

### API連携

RTK Queryを使用してAPI通信を行います：

```typescript
// services/api.ts
export const adminApi = createApi({
  // API設定
})

// コンポーネントでの使用
const { data, isLoading, error } = useGetWeaponsQuery()
```

### 型定義

`src/types/index.ts` で型を定義し、プロジェクト全体で使用：

```typescript
export interface WeaponMaster {
  id: number
  name: string
  // ...
}
```

## 🧪 テスト

```bash
# テスト実行
npm run test

# カバレッジ
npm run test:coverage
```

## 📦 ビルド・デプロイ

### 本番ビルド

```bash
npm run build
```

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

## 🐛 トラブルシューティング

### よくある問題

1. **TypeScriptエラー**: 型定義を確認
2. **API接続エラー**: バックエンドサーバーの起動を確認
3. **ビルドエラー**: 依存関係の再インストール

### デバッグ

```bash
# 詳細ログ
npm run dev -- --debug

# 型チェック
npx tsc --noEmit
```

## 📚 参考資料

- [React Documentation](https://react.dev/)
- [Material-UI](https://mui.com/)
- [Redux Toolkit](https://redux-toolkit.js.org/)
- [Vite](https://vitejs.dev/)

## 🤝 コントリビューション

1. 機能追加・修正は新しいブランチで作業
2. TypeScript型定義を適切に設定
3. コンポーネントは再利用可能に設計
4. レスポンシブ対応を考慮

---
最終更新: 2025/06/02 23:09
