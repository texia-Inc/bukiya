# 武器屋放置ゲーム - ゲームデザイン設計書

## 🎯 基本コンセプト
プレイヤーが武器屋を経営し、冒険者との取引、武器作成、店舗拡張を通じて成長していく放置系ゲーム。

---

## 🚀 実装フェーズ計画

### **フェーズ1（基本システム強化）** ⭐ 現在対象
- [x] 訪問者クールダウン制御
- [x] 放置収入システム強化
- [x] ジェム導入（訪問者スポーン用）
- [ ] 基本バランス調整

### **フェーズ2（コンテンツ拡充）**
- [ ] 素材採集システム
- [ ] 武器改良・合成システム
- [ ] ミッション拡張
- [ ] 店舗アップグレード

### **フェーズ3（マネタイズ強化）**
- [ ] ジェム用途多様化
- [ ] ガチャシステム
- [ ] VIPシステム（月額）
- [ ] イベントシステム

---

## 💰 放置収入システム（フェーズ1実装対象）

### **基本設計**
```
店舗経営収入 = ベース収入 × ショップレベル補正 × 施設補正
- ベース収入: 10ゴールド/分
- ショップレベル補正: レベル × 1.2
- 最大蓄積時間: 12時間（720分）
- 最大蓄積量: ベース × 720
```

### **データベース設計**
```sql
-- playersテーブルに追加フィールド
ALTER TABLE players ADD COLUMN last_idle_collection_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE players ADD COLUMN idle_income_rate INTEGER DEFAULT 10; -- ゴールド/分
ALTER TABLE players ADD COLUMN idle_income_multiplier DECIMAL(3,2) DEFAULT 1.0;
```

### **計算ロジック**
```python
def calculate_idle_income(player):
    now = datetime.utcnow()
    last_collection = player.last_idle_collection_time or player.created_at
    
    # 経過時間（分）
    elapsed_minutes = min(720, (now - last_collection).total_seconds() / 60)
    
    # 収入計算
    base_rate = player.idle_income_rate  # 10ゴールド/分
    level_bonus = 1.0 + (player.shop_level * 0.2)  # レベル補正
    multiplier = player.idle_income_multiplier  # 施設補正
    
    total_income = int(elapsed_minutes * base_rate * level_bonus * multiplier)
    return total_income, elapsed_minutes
```

---

## ⏰ 訪問者スポーンクールダウン（フェーズ1実装対象）

### **基本設計**
```
クールダウン時間:
- 基本: 30分〜90分（ランダム）
- ショップレベル補正: -2分/レベル（最小15分）
- ジェム即時スポーン: 100ジェム
```

### **データベース設計**
```sql
-- playersテーブルに追加
ALTER TABLE players ADD COLUMN last_visitor_spawn_time TIMESTAMP;
ALTER TABLE players ADD COLUMN gems INTEGER DEFAULT 0; -- 課金通貨
```

### **スポーン制御ロジック**
```python
def can_spawn_visitors(player):
    if not player.last_visitor_spawn_time:
        return True, 0
    
    now = datetime.utcnow()
    elapsed = (now - player.last_visitor_spawn_time).total_seconds() / 60
    
    # クールダウン計算
    base_cooldown = random.randint(30, 90)  # 30-90分
    level_reduction = min(15, player.shop_level * 2)  # レベル補正
    required_cooldown = max(15, base_cooldown - level_reduction)
    
    if elapsed >= required_cooldown:
        return True, 0
    else:
        remaining = int(required_cooldown - elapsed)
        return False, remaining

def force_spawn_with_gems(player, db):
    gem_cost = 100
    if player.gems < gem_cost:
        raise HTTPException(400, "ジェムが不足しています")
    
    player.gems -= gem_cost
    # スポーン処理実行
    db.commit()
```

---

## 💎 ジェムシステム（フェーズ1実装対象）

### **ジェム獲得方法**
```
無料獲得:
- ログインボーナス: 10〜50ジェム/日
- レベルアップ: 25ジェム/レベル
- 実績達成: 50〜300ジェム（一回限り）
- 広告視聴: 20ジェム/回（1日3回まで）

課金獲得:
- スターターパック: 120円 = 100ジェム + おまけ
- お得パック: 250円 = 250ジェム
- 大容量パック: 500円 = 600ジェム
```

### **ジェム用途（フェーズ1）**
```
- 訪問者即時スポーン: 100ジェム
- 放置収入2倍化（1時間）: 50ジェム
- 経験値ブースト（1時間）: 80ジェム
```

---

## 🏪 店舗アップグレードシステム（フェーズ2予定）

### **アップグレード項目**
```
内装レベル:
- Lv1: 基本店舗（初期）
- Lv2: 清潔な店舗（放置収入 +20%）
- Lv3: 高級店舗（高級顧客出現率 +15%）
- Lv4: 豪華店舗（レア訪問者確率 +25%）

作業台レベル:
- Lv1: 1つまで同時作成
- Lv2: 2つまで同時作成
- Lv3: 3つまで同時作成 + 作成時間-10%

倉庫レベル:
- Lv1: 武器50個、素材100個
- Lv2: 武器75個、素材150個  
- Lv3: 武器100個、素材200個
```

---

## ⛏️ 素材採集システム（フェーズ2予定）

### **採集場タイプ**
```
鉱山:
- 初期投資: 1000ゴールド
- 産出: 鉄鉱石、銅鉱石、稀にミスリル
- 収集周期: 4時間
- アップグレード: 効率+25%/レベル

森林:
- 初期投資: 800ゴールド  
- 産出: 木材、稀に魔法の木材
- 収集周期: 3時間
- アップグレード: レア確率+5%/レベル

古代遺跡:
- 解放条件: ショップLv10
- 初期投資: 5000ゴールド
- 産出: 魔石、古代の素材
- 収集周期: 8時間
```

---

## 🔨 武器改良システム（フェーズ2予定）

### **改良タイプ**
```
エンチャント強化:
- 成功率: 90% → 70% → 50% → 30% → 10%
- 失敗時: 武器消失リスク（レベル5以上）
- 素材コスト: レベル × 特殊素材

武器合成:
- 同じ武器2本 → 1ランク上の武器
- 成功率: 80%（素材で上昇可能）
- 失敗時: 片方消失

レア効果付与:
- 特殊効果をランダム付与
- クリティカル率UP、属性ダメージ等
- 超レア素材が必要
```

---

## 📋 ミッション拡張（フェーズ2予定）

### **ミッションタイプ**
```
日次ミッション:
- 武器を3本販売せよ
- 素材を50個収集せよ  
- 冒険者と5回取引せよ

週次ミッション:
- 特定武器を10本作成せよ
- ショップレベルを1上げよ
- 総売上50000ゴールドを達成せよ

月次ミッション:
- レア武器を5本作成せよ
- 全ての採集場をレベル3にせよ
- 100人の冒険者と取引せよ

実績システム:
- 武器職人（武器作成数）
- 商売上手（売上金額）
- 冒険者の友（取引回数）
- 素材王（素材収集数）
```

---

## 🎮 ゲームループ設計

### **短期ループ（15分〜1時間）**
```
1. 放置収入回収
2. 採集場から素材回収
3. 武器作成・改良
4. 訪問者との取引
5. 次の準備
```

### **中期ループ（1日〜1週間）**
```
1. ミッション進行
2. 施設アップグレード検討
3. 新レシピ研究
4. 効率化戦略立案
```

### **長期ループ（1週間〜1ヶ月）**
```
1. ショップレベル上昇
2. 新コンテンツ解放
3. 高級顧客対応
4. エンドコンテンツ挑戦
```

---

## 💸 マネタイズ戦略

### **課金動機**
```
時短系:
- 訪問者スポーン時間短縮
- 作成時間短縮
- 放置収入時間短縮

効率系:
- 経験値ブースト
- 成功率アップアイテム
- レア素材獲得率UP

拡張系:
- 倉庫拡張
- 作業台追加
- 特別レシピ解放

ガチャ系:
- レア素材ガチャ
- 特殊効果武器ガチャ
- 見た目変更アイテム
```

### **課金パッケージ案**
```
スターターパック（120円）:
- ジェム100個
- 訪問者即時スポーン券×3
- 経験値ブースト1時間券×2

成長支援パック（250円）:
- ジェム250個
- レア素材ボックス×1
- 放置収入2倍券×5

本格プレイヤーパック（500円）:
- ジェム600個
- 倉庫拡張券×1
- 成功率UP薬×10
- 特別レシピ×1

VIP月額（980円）:
- 毎日ジェム50個配布
- 放置収入+50%
- 経験値+30%
- 専用顧客出現
```

---

## 📊 バランス調整ガイドライン

### **基本数値**
```
ゴールド獲得:
- 放置収入: 10G/分（序盤メイン）
- 武器販売: 100-2000G/回（中盤メイン）
- ミッション: 500-5000G/回（後半メイン）

経験値獲得:
- 武器販売: 5-20EXP/回
- 冒険者取引: 10-30EXP/回
- ミッション: 50-500EXP/回

レベルアップ必要EXP:
- Lv1→2: 100EXP
- Lv2→3: 150EXP  
- 計算式: 50 + (level × 50)
```

### **調整指針**
```
プレイ時間:
- 短期目標: 15分で達成感
- 中期目標: 1週間で新要素解放
- 長期目標: 1ヶ月で大きな成長実感

課金圧:
- 無課金でも楽しめる
- 課金で効率2-3倍程度
- Pay to Win要素は避ける
```

---

## 🔧 技術実装メモ

### **必要なテーブル追加**
```sql
-- プレイヤー拡張
ALTER TABLE players ADD COLUMN gems INTEGER DEFAULT 0;
ALTER TABLE players ADD COLUMN last_idle_collection_time TIMESTAMP;
ALTER TABLE players ADD COLUMN idle_income_rate INTEGER DEFAULT 10;
ALTER TABLE players ADD COLUMN last_visitor_spawn_time TIMESTAMP;

-- 新テーブル
CREATE TABLE player_facilities (
    id UUID PRIMARY KEY,
    player_id UUID REFERENCES players(id),
    facility_type VARCHAR(50), -- 'interior', 'workbench', 'storage'
    level INTEGER DEFAULT 1,
    last_upgrade_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mining_operations (
    id UUID PRIMARY KEY,
    player_id UUID REFERENCES players(id),
    mine_type VARCHAR(50), -- 'iron_mine', 'forest', 'ruins'
    level INTEGER DEFAULT 1,
    last_collection_time TIMESTAMP,
    total_produced INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### **実装優先度**
1. **HIGH**: 放置収入API、訪問者クールダウン、ジェム基本機能
2. **MEDIUM**: 施設アップグレード、採集システム
3. **LOW**: 武器改良、ガチャシステム、VIP機能

---

*このドキュメントは段階的実装の指針として使用し、フェーズごとに詳細を追加・修正していく。*