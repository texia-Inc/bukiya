# 武器屋ゲーム API設計書

## 1. API基本設計

### ベースURL
```
開発環境: http://localhost:8000/api/v1
本番環境: https://api.weaponshop.game/v1
管理画面: https://api.weaponshop.game/admin/v1
```

### 認証方式
```python
# JWT Bearer Token認証
Authorization: Bearer <jwt_token>

# API Key認証（管理画面）
X-API-Key: <admin_api_key>
X-Admin-User: <admin_username>
```

### 共通レスポンス形式
```json
{
  "success": true,
  "data": {...},
  "message": "操作が成功しました",
  "timestamp": "2024-02-01T12:00:00Z",
  "request_id": "req_123456789"
}

// エラー時
{
  "success": false,
  "error": {
    "code": "INVALID_WEAPON_ID",
    "message": "指定された武器IDは存在しません",
    "details": {...}
  },
  "timestamp": "2024-02-01T12:00:00Z",
  "request_id": "req_123456789"
}
```

## 2. 認証・プレイヤー管理API

### 2.1 プレイヤー認証
```http
POST /auth/register
Content-Type: application/json

{
  "username": "player123",
  "email": "player@example.com",
  "password": "secure_password"
}

Response:
{
  "success": true,
  "data": {
    "player_id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "player123",
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "expires_in": 3600
  }
}
```

```http
POST /auth/login
Content-Type: application/json

{
  "email": "player@example.com",
  "password": "secure_password"
}

Response: (同上)
```

### 2.2 プレイヤー情報取得
```http
GET /players/me
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "username": "player123",
    "gold": 12450,
    "gems": 85,
    "shop_level": 7,
    "reputation": 65,
    "statistics": {
      "total_play_time_seconds": 45600,
      "weapons_crafted": 23,
      "trades_completed": 45,
      "highest_enchant_level": 12
    },
    "created_at": "2024-01-15T10:30:00Z",
    "last_login": "2024-02-01T09:15:00Z"
  }
}
```

## 3. 武器管理API

### 3.1 プレイヤー武器一覧
```http
GET /weapons?page=1&limit=20&sort=attack_desc&rarity=epic&weapon_type=sword
Authorization: Bearer <token>

Query Parameters:
- page: ページ番号 (default: 1)
- limit: 取得件数 (default: 20, max: 100)
- sort: ソート順 (attack_asc, attack_desc, name_asc, enchant_desc)
- rarity: レア度フィルター (common, rare, epic)
- weapon_type: 武器種フィルター (sword, bow, staff)
- search: 武器名検索

Response:
{
  "success": true,
  "data": {
    "weapons": [
      {
        "id": "weapon_123",
        "weapon_master_id": "flame_sword_epic",
        "name": "炎の剣",
        "weapon_type": {
          "id": "sword",
          "name": "剣",
          "emoji": "⚔️"
        },
        "rarity": {
          "id": "epic",
          "name": "Epic",
          "level": 3,
          "color_code": "#8040FF",
          "star_display": "★★★☆☆"
        },
        "attribute": {
          "id": "fire",
          "name": "火",
          "emoji": "🔥",
          "color_code": "#FF4500"
        },
        "base_attack": 350,
        "enchant_level": 8,
        "current_attack": 358,
        "abilities": [
          {
            "id": "fire_damage",
            "name": "火炎ダメージ",
            "description": "攻撃時に追加火属性ダメージ",
            "effect_value": 25
          }
        ],
        "durability": {
          "current": 95,
          "max": 100
        },
        "is_equipped": false,
        "is_favorite": true,
        "acquired_at": "2024-01-20T15:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 3,
      "total_items": 52,
      "items_per_page": 20
    }
  }
}
```

### 3.2 武器詳細情報
```http
GET /weapons/{weapon_id}
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "id": "weapon_123",
    "weapon_master_id": "flame_sword_epic",
    "name": "炎の剣",
    "custom_name": "マイフレイムソード",
    "description": "古代の炎を宿した伝説の剣",
    "weapon_type": {
      "id": "sword",
      "name": "剣",
      "emoji": "⚔️",
      "base_multiplier": 1.0,
      "attack_speed_modifier": 1.0
    },
    "rarity": {
      "id": "epic",
      "name": "Epic",
      "level": 3,
      "color_code": "#8040FF",
      "star_display": "★★★☆☆",
      "max_enchant_level": 20
    },
    "attribute": {
      "id": "fire",
      "name": "火",
      "emoji": "🔥",
      "color_code": "#FF4500",
      "damage_bonus": 15,
      "effective_against": ["ice", "plant"],
      "weak_against": ["water", "earth"]
    },
    "stats": {
      "base_attack": 350,
      "enchant_level": 8,
      "current_attack": 358,
      "enchant_growth_rate": 1.0
    },
    "abilities": [...],
    "durability": {
      "current": 95,
      "max": 100
    },
    "enchant_effects": {
      "level": 8,
      "effect_name": "蒼の煌めき",
      "glow_color": "#0080FF",
      "has_special_effect": true
    },
    "usage_stats": {
      "expeditions_used": 12,
      "total_damage_dealt": 45670,
      "last_used_at": "2024-01-31T14:20:00Z"
    },
    "market_value": {
      "estimated_price": 15000,
      "price_range": {
        "min": 12000,
        "max": 18000
      }
    },
    "is_equipped": false,
    "is_favorite": true,
    "is_locked": false,
    "acquired_at": "2024-01-20T15:30:00Z"
  }
}
```

### 3.3 武器エンチャント
```http
POST /weapons/{weapon_id}/enchant
Authorization: Bearer <token>
Content-Type: application/json

{
  "materials": [
    {
      "material_id": "enhancement_stone",
      "quantity": 3
    },
    {
      "material_id": "fire_crystal",
      "quantity": 1
    }
  ],
  "use_protection_scroll": false
}

Response:
{
  "success": true,
  "data": {
    "result": "success", // success, failure
    "old_enchant_level": 8,
    "new_enchant_level": 9,
    "old_attack": 358,
    "new_attack": 359,
    "materials_consumed": [
      {
        "material_id": "enhancement_stone",
        "quantity": 3
      }
    ],
    "gold_cost": 4500,
    "success_rate": 0.75,
    "enchant_effects": {
      "level": 9,
      "effect_name": "蒼の煌めき",
      "glow_color": "#0080FF",
      "glow_intensity": 0.85
    },
    "message": "エンチャントに成功しました！攻撃力が1上昇しました。",
    "next_enchant_cost": {
      "gold": 5000,
      "materials": [...],
      "success_rate": 0.70
    }
  }
}
```

## 4. 合成・レシピAPI

### 4.1 利用可能レシピ一覧
```http
GET /crafting/recipes?weapon_type=sword&max_level=10
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "recipes": [
      {
        "id": "flame_sword_recipe",
        "result_weapon": {
          "id": "flame_sword_epic",
          "name": "炎の剣",
          "weapon_type": "sword",
          "rarity": "epic",
          "base_attack_range": [350, 450],
          "image_url": "/images/weapons/flame_sword.png"
        },
        "requirements": {
          "shop_level": 10,
          "facility_level": 3
        },
        "materials": [
          {
            "material_id": "iron_ore",
            "name": "鉄鉱石",
            "quantity": 5,
            "owned_quantity": 12,
            "is_sufficient": true
          },
          {
            "material_id": "fire_crystal",
            "name": "火の結晶",
            "quantity": 2,
            "owned_quantity": 1,
            "is_sufficient": false
          }
        ],
        "crafting": {
          "gold_cost": 2500,
          "time_minutes": 120,
          "success_rate": 0.85
        },
        "can_craft": false,
        "missing_materials": ["fire_crystal"],
        "unlocked": true
      }
    ],
    "total_recipes": 15,
    "unlocked_recipes": 12
  }
}
```

### 4.2 武器合成実行
```http
POST /crafting/craft
Authorization: Bearer <token>
Content-Type: application/json

{
  "recipe_id": "flame_sword_recipe",
  "quantity": 1,
  "use_speed_boost": false
}

Response:
{
  "success": true,
  "data": {
    "process_id": "process_789",
    "recipe": {
      "id": "flame_sword_recipe",
      "name": "炎の剣の錬成"
    },
    "materials_consumed": [...],
    "gold_spent": 2500,
    "crafting_time_minutes": 120,
    "estimated_completion": "2024-02-01T14:00:00Z",
    "success_rate": 0.85,
    "message": "合成を開始しました。完了まで約2時間です。"
  }
}
```

## 5. 冒険者・取引API

### 5.1 現在の冒険者訪問一覧
```http
GET /adventurers/visits
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "active_visits": [
      {
        "id": "visit_456",
        "adventurer": {
          "id": "warrior_rick",
          "name": "戦士リック",
          "class": "warrior",
          "level": 23,
          "avatar_image": "/images/adventurers/rick.png",
          "personality": "cautious",
          "trust_level": 65
        },
        "purpose": "buy_weapon",
        "requirements": {
          "weapon_type": "sword",
          "min_attack": 500,
          "max_price": 3000,
          "preferred_attributes": ["fire", "lightning"]
        },
        "available_gold": 3000,
        "time_remaining_minutes": 25,
        "arrived_at": "2024-02-01T11:30:00Z",
        "departure_time": "2024-02-01T12:30:00Z",
        "status": "waiting",
        "relationship": {
          "trust_level": 65,
          "total_trades": 12,
          "successful_expeditions": 8,
          "average_satisfaction": 4.2
        }
      }
    ],
    "returning_adventurers": [
      {
        "id": "return_789",
        "adventurer": {
          "id": "mage_elena",
          "name": "魔法使いエリナ",
          "class": "mage",
          "level": 18
        },
        "expedition_result": {
          "target": "フレイムドラゴン",
          "success_level": "great_success",
          "completion_time": "2024-02-01T12:15:00Z"
        },
        "materials_to_sell": [
          {
            "material_id": "dragon_scale",
            "name": "ドラゴンスケール",
            "quantity": 1,
            "unit_price": 5000,
            "total_price": 5000,
            "market_price_range": [4000, 6000]
          },
          {
            "material_id": "fire_crystal",
            "name": "火の結晶",
            "quantity": 3,
            "unit_price": 800,
            "total_price": 2400,
            "market_price_range": [600, 1000]
          }
        ],
        "total_offer_price": 7400,
        "buyout_deadline": "2024-02-01T14:15:00Z",
        "time_remaining_minutes": 47
      }
    ]
  }
}
```

### 5.2 武器販売
```http
POST /adventurers/visits/{visit_id}/sell-weapon
Authorization: Bearer <token>
Content-Type: application/json

{
  "weapon_id": "weapon_123",
  "asking_price": 2800,
  "allow_negotiation": true
}

Response:
{
  "success": true,
  "data": {
    "transaction_id": "trade_654",
    "final_price": 2800,
    "negotiation_result": {
      "initial_offer": 2500,
      "final_offer": 2800,
      "negotiation_success": true,
      "adventurer_satisfaction": "satisfied"
    },
    "adventurer_response": {
      "message": "良い武器ですね！この価格で購入します。",
      "trust_change": +2,
      "new_trust_level": 67
    },
    "expedition": {
      "target_monster": "オークキング",
      "estimated_duration_minutes": 180,
      "success_probability": 0.78,
      "estimated_return": "2024-02-01T15:45:00Z"
    },
    "player_gold_change": +2800,
    "new_gold_balance": 15250
  }
}
```

### 5.3 素材買取
```http
POST /adventurers/returns/{return_id}/purchase
Authorization: Bearer <token>
Content-Type: application/json

{
  "purchase_items": [
    {
      "material_id": "dragon_scale",
      "quantity": 1,
      "agreed_price": 5000
    }
  ],
  "negotiate_price": false,
  "partial_purchase": true
}

Response:
{
  "success": true,
  "data": {
    "transaction_id": "trade_987",
    "purchased_items": [
      {
        "material_id": "dragon_scale",
        "quantity": 1,
        "unit_price": 5000,
        "total_cost": 5000
      }
    ],
    "unpurchased_items": [
      {
        "material_id": "fire_crystal",
        "quantity": 3,
        "reason": "insufficient_gold"
      }
    ],
    "total_cost": 5000,
    "player_gold_change": -5000,
    "new_gold_balance": 10250,
    "materials_gained": [
      {
        "material_id": "dragon_scale",
        "quantity_before": 0,
        "quantity_after": 1
      }
    ],
    "adventurer_response": {
      "satisfaction": "satisfied",
      "message": "ありがとうございます！また良い素材を持ってきますね。",
      "trust_change": +1
    }
  }
}
```

## 6. プロセス管理API

### 6.1 進行中プロセス一覧
```http
GET /processes/active
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "processes": [
      {
        "id": "process_789",
        "type": "crafting",
        "name": "炎の剣の錬成",
        "status": "in_progress",
        "progress_percentage": 65,
        "started_at": "2024-02-01T10:00:00Z",
        "estimated_completion": "2024-02-01T12:00:00Z",
        "time_remaining_minutes": 42,
        "can_speed_up": true,
        "speed_up_cost_gems": 84,
        "details": {
          "recipe_name": "炎の剣",
          "success_rate": 0.85,
          "materials_used": [...]
        }
      },
      {
        "id": "process_456",
        "type": "expedition",
        "name": "戦士リック - オークキング討伐",
        "status": "in_progress",
        "progress_percentage": 30,
        "started_at": "2024-02-01T09:45:00Z",
        "estimated_completion": "2024-02-01T12:45:00Z",
        "time_remaining_minutes": 178,
        "can_speed_up": false,
        "details": {
          "adventurer_name": "戦士リック",
          "target_monster": "オークキング",
          "weapon_used": "炎の剣+8",
          "success_probability": 0.78
        }
      }
    ],
    "completed_processes": [
      {
        "id": "process_321",
        "type": "crafting",
        "name": "ミスリル弓の錬成",
        "status": "completed",
        "completed_at": "2024-02-01T11:30:00Z",
        "result": "success",
        "rewards_claimed": false,
        "results": {
          "weapon_created": {
            "id": "weapon_new_456",
            "name": "ミスリル弓",
            "attack": 280,
            "rarity": "rare"
          }
        }
      }
    ]
  }
}
```

### 6.2 プロセス結果回収
```http
POST /processes/{process_id}/claim
Authorization: Bearer <token>

Response:
{
  "success": true,
  "data": {
    "process_id": "process_321",
    "result": "success",
    "rewards": {
      "weapons_gained": [
        {
          "id": "weapon_new_456",
          "name": "ミスリル弓",
          "weapon_type": "bow",
          "rarity": "rare",
          "attack": 280
        }
      ],
      "materials_gained": [],
      "gold_gained": 0,
      "experience_gained": 150
    },
    "message": "ミスリル弓の錬成に成功しました！",
    "achievement_unlocked": null,
    "new_recipe_unlocked": null
  }
}
```

## 7. 管理画面API

### 7.1 武器マスタ管理
```http
GET /admin/weapons/masters?page=1&limit=50&search=炎
Authorization: Bearer <admin_token>
X-Admin-User: admin_user

Response:
{
  "success": true,
  "data": {
    "weapons": [
      {
        "id": "flame_sword_epic",
        "name": "炎の剣",
        "weapon_type": {
          "id": "sword",
          "name": "剣"
        },
        "rarity": {
          "id": "epic",
          "name": "Epic",
          "level": 3
        },
        "base_attack_range": [350, 450],
        "is_active": true,
        "is_test_only": false,
        "version": 1,
        "players_owned_count": 23,
        "total_crafted": 45,
        "average_market_price": 15000,
        "created_at": "2024-01-15T10:00:00Z",
        "updated_at": "2024-01-20T14:30:00Z"
      }
    ],
    "pagination": {
      "current_page": 1,
      "total_pages": 8,
      "total_items": 156
    },
    "statistics": {
      "total_weapons": 156,
      "active_weapons": 142,
      "test_weapons": 14,
      "by_rarity": {
        "common": 45,
        "rare": 38,
        "epic": 32,
        "legendary": 15,
        "mythic": 3
      }
    }
  }
}
```

### 7.2 武器マスタ作成・更新
```http
POST /admin/weapons/masters
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "id": "ice_sword_rare",
  "name": "氷の剣",
  "weapon_type_id": "sword",
  "rarity_id": "rare",
  "attribute_id": "ice",
  "base_attack_min": 200,
  "base_attack_max": 300,
  "enchant_growth_rate": 1.0,
  "max_enchant_level": 15,
  "base_price_min": 1500,
  "base_price_max": 2500,
  "crafting_time_minutes": 90,
  "required_shop_level": 8,
  "description": "氷の力を宿した美しい剣",
  "abilities": [
    {
      "ability_id": "ice_damage",
      "slot_number": 1,
      "probability": 1.0
    }
  ],
  "is_active": true,
  "is_test_only": false
}

Response:
{
  "success": true,
  "data": {
    "weapon_master": {
      "id": "ice_sword_rare",
      "name": "氷の剣",
      // ... 作成されたデータの詳細
    },
    "validation_results": {
      "balance_check": "passed",
      "price_balance": "appropriate",
      "power_level": "within_range",
      "warnings": []
    }
  },
  "message": "武器マスタ「氷の剣」を作成しました"
}
```

### 7.3 バランス検証
```http
POST /admin/balance/verify
Authorization: Bearer <admin_token>
Content-Type: application/json

{
  "check_type": "weapon_addition",
  "target_id": "ice_sword_rare",
  "scenario": "normal_gameplay"
}

Response:
{
  "success": true,
  "data": {
    "verification_id": "verify_123",
    "overall_status": "warning",
    "checks": [
      {
        "check_name": "attack_power_balance",
        "status": "pass",
        "message": "攻撃力は適正範囲内です",
        "details": {
          "weapon_attack": 250,
          "tier_average": 240,
          "deviation_percentage": 4.2
        }
      },
      {
        "check_name": "material_supply",
        "status": "warning",
        "message": "氷の結晶の供給不足が予想されます",
        "details": {
          "material": "ice_crystal",
          "current_daily_supply": 50,
          "estimated_daily_demand": 75,
          "shortage_percentage": 50
        },
        "recommendations": [
          "氷の結晶のドロップ率を5%上昇",
          "代替レシピの追加検討"
        ]
      }
    ],
    "economic_impact": {
      "price_effect": "minimal",
      "market_disruption": "low",
      "player_progression": "appropriate"
    },
    "recommendations": [
      "氷の結晶の供給量調整を推奨",
      "リリース後1週間でのバランス再評価"
    ]
  }
}
```

## 8. エラーコード定義

### 8.1 認証関連エラー
```json
{
  "INVALID_TOKEN": "トークンが無効です",
  "TOKEN_EXPIRED": "トークンの有効期限が切れています",
  "INSUFFICIENT_PERMISSION": "この操作を実行する権限がありません",
  "ACCOUNT_BANNED": "アカウントが停止されています"
}
```

### 8.2 ゲームロジックエラー
```json
{
  "INSUFFICIENT_GOLD": "ゴールドが不足しています",
  "INSUFFICIENT_MATERIALS": "必要な素材が不足しています",
  "WEAPON_NOT_FOUND": "指定された武器が見つかりません",
  "ENCHANT_FAILED": "エンチャントに失敗しました",
  "PROCESS_ALREADY_RUNNING": "既に同じタイプの処理が実行中です",
  "ADVENTURER_NOT_AVAILABLE": "冒険者は現在利用できません",
  "INVALID_TRADE_OFFER": "無効な取引提案です"
}
```

### 8.3 管理画面エラー
```json
{
  "MASTER_DATA_CONFLICT": "マスタデータに競合があります",
  "BALANCE_VALIDATION_FAILED": "バランス検証に失敗しました",
  "DEPENDENCY_EXISTS": "削除対象に依存関係があります",
  "INVALID_ADMIN_OPERATION": "無効な管理操作です"
}
```

## 9. レスポンス時間とパフォーマンス目標

### 9.1 パフォーマンス目標
```
一般API:
- 95%ile: 200ms以下
- 99%ile: 500ms以下
- 平均: 100ms以下

管理画面API:
- 95%ile: 500ms以下
- 99%ile: 1000ms以下
- 平均: 300ms以下

リアルタイム系:
- WebSocket応答: 50ms以下
- プッシュ通知: 3秒以内
```

### 9.2 キャッシュ戦略
```python
# マスタデータ: 長期キャッシュ
weapon_masters: 1時間
material_masters: 1時間
monster_masters: 1時間

# プレイヤーデータ: 短期キャッシュ
player_info: 5分
player_weapons: 1分
active_processes: 30秒

# 動的データ: キャッシュなし
adventurer_visits: リアルタイム
trade_transactions: リアルタイム
```

---

この包括的なAPI設計により、フロントエンド開発者は迷うことなく効率的にアプリケーションを構築でき、管理画面開発者も強力なコンテンツ管理機能を実装できます。次は、この設計を元にしたFlutterアプリのアーキテクチャ設計に進みましょうか？