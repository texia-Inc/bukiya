# 武器屋放置ゲーム API

武器屋を経営する放置系ゲームのバックエンドAPIです。プレイヤーは武器を合成し、冒険者に販売してゴールドを稼ぎ、ショップを成長させていきます。

## 🎮 ゲーム概要

- **ジャンル**: 放置系経営シミュレーション
- **テーマ**: 武器屋経営
- **プラットフォーム**: Web（React + FastAPI）

## 🏗️ アーキテクチャ

### バックエンド
- **フレームワーク**: FastAPI (Python 3.11)
- **データベース**: PostgreSQL 15
- **キャッシュ**: Redis 7
- **ORM**: SQLAlchemy 2.0
- **認証**: JWT Bearer Token
- **コンテナ**: Docker + Docker Compose

### フロントエンド（予定）
- **フレームワーク**: React + TypeScript
- **状態管理**: Redux Toolkit
- **UI**: Material-UI

## 🚀 クイックスタート

### 前提条件
- Docker & Docker Compose
- Git

### セットアップ

```bash
# リポジトリクローン
git clone <repository-url>
cd bukiya

# Docker環境起動
docker-compose up -d

# API動作確認
curl http://localhost:8000/health
```

### アクセス情報
- **API**: http://localhost:8000
- **API ドキュメント**: http://localhost:8000/docs
- **pgAdmin**: http://localhost:5050 (admin@example.com / admin_password)
- **PostgreSQL**: localhost:5432 (bukiya_user / bukiya_password)

## 📊 データベース設計

### マスターデータ
- `weapon_types` - 武器種別（剣、斧、弓等）
- `rarity_levels` - レアリティ（Common, Uncommon, Rare等）
- `weapon_masters` - 武器マスター（24種類）
- `material_masters` - 素材マスター（10種類）
- `crafting_recipes` - 合成レシピ

### プレイヤーデータ
- `players` - プレイヤー基本情報
- `player_statistics` - プレイヤー統計
- `player_weapons` - 所持武器
- `player_materials` - 所持素材

## 🔧 API エンドポイント

### 認証
- `POST /api/v1/auth/register` - プレイヤー登録
- `POST /api/v1/auth/login` - ログイン
- `POST /api/v1/auth/refresh` - トークン更新

### プレイヤー
- `GET /api/v1/players/me` - プレイヤー情報取得
- `PUT /api/v1/players/me` - プレイヤー情報更新

### 武器
- `GET /api/v1/weapons/` - 武器マスター一覧
- `GET /api/v1/weapons/{weapon_id}` - 武器詳細
- `GET /api/v1/weapons/player/inventory` - 所持武器一覧
- `POST /api/v1/weapons/player/create` - 武器作成
- `PUT /api/v1/weapons/player/{weapon_id}` - 武器更新
- `POST /api/v1/weapons/player/{weapon_id}/enchant` - エンチャント
- `DELETE /api/v1/weapons/player/{weapon_id}` - 武器売却

### 素材
- `GET /api/v1/materials/` - 素材マスター一覧
- `GET /api/v1/materials/{material_id}` - 素材詳細
- `GET /api/v1/materials/player/inventory` - 所持素材一覧
- `POST /api/v1/materials/player/add` - 素材追加
- `POST /api/v1/materials/player/remove` - 素材消費
- `POST /api/v1/materials/player/sell` - 素材売却

### 合成
- `GET /api/v1/crafting/recipes` - 合成レシピ一覧
- `GET /api/v1/crafting/recipes/{recipe_id}` - レシピ詳細
- `GET /api/v1/crafting/recipes/available` - 合成可能レシピ
- `GET /api/v1/crafting/recipes/{recipe_id}/availability` - 合成可能性チェック
- `POST /api/v1/crafting/craft` - 武器合成

## 🎯 ゲーム機能

### 武器システム
- **24種類の武器**: 剣、斧、弓、杖の4カテゴリ
- **6段階レアリティ**: Common → Legendary
- **エンチャントシステム**: 最大+10まで強化可能
- **カスタム名**: プレイヤーが武器に名前を付与可能

### 素材システム
- **10種類の素材**: 鉄鉱石、魔法石、ドラゴンの鱗等
- **スタック管理**: 素材ごとに最大999個まで所持
- **売却システム**: 基本価格の80%で売却可能

### 合成システム
- **レシピベース**: 事前定義されたレシピで武器を合成
- **成功率**: レシピごとに異なる成功率
- **必要素材**: 複数素材の組み合わせ
- **レベル制限**: ショップレベルによる制限

### エンチャントシステム
- **成功率変動**: レベルが上がるほど成功率低下
- **コスト増加**: エンチャントレベル × 1000G
- **攻撃力ボーナス**: +1レベルあたり+5攻撃力

## 🛠️ 開発環境

### ローカル開発

```bash
# バックエンド開発
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload

# データベース接続（Postico2等）
Host: localhost
Port: 5432
Database: bukiya_game
User: bukiya_user
Password: bukiya_password
```

### テスト

```bash
# APIテスト
curl -X GET http://localhost:8000/health

# 認証テスト（要実装）
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"test","email":"test@example.com","password":"password"}'
```

## 📁 プロジェクト構造

```
bukiya/
├── backend/                 # FastAPI バックエンド
│   ├── app/
│   │   ├── api/v1/         # APIエンドポイント
│   │   ├── core/           # 設定・データベース・セキュリティ
│   │   ├── models/         # SQLAlchemyモデル
│   │   └── schemas/        # Pydanticスキーマ
│   ├── Dockerfile
│   └── requirements.txt
├── database/               # データベース初期化
│   ├── init.sql           # スキーマ定義
│   ├── seed_data.sql      # 基本データ
│   └── seed_data_complete.sql # 完全データセット
├── document/              # 設計書
│   ├── description.md     # ゲーム仕様
│   ├── db_schema.md      # DB設計
│   └── mvp設計.md        # MVP仕様
├── docker-compose.yml    # 本番環境
├── docker-compose.light.yml # 軽量環境
└── README.md
```

## 🎮 ゲームフロー

1. **プレイヤー登録・ログイン**
2. **初期武器・素材の取得**
3. **武器合成**: 素材を消費して新しい武器を作成
4. **武器エンチャント**: ゴールドを消費して武器を強化
5. **冒険者への販売**: 武器を売却してゴールドを獲得
6. **ショップ拡張**: レベルアップで新しいレシピ解放

## 🔮 今後の実装予定

### Phase 1: 管理画面
- React + TypeScript管理画面
- マスターデータ管理機能
- プレイヤーデータ管理機能

### Phase 2: ゲーム画面
- プレイヤー向けWebアプリ
- リアルタイム更新
- レスポンシブデザイン

### Phase 3: 拡張機能
- 冒険者システム
- モンスター討伐
- 武器エンチャント拡張
- ギルドシステム

## 📝 ライセンス

MIT License

## 🤝 コントリビューション

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 サポート

- **Issues**: GitHub Issues
- **Documentation**: `/docs` エンドポイント
- **API Reference**: http://localhost:8000/docs
