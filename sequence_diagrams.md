# 武器屋放置ゲーム - 処理シーケンス図

このファイルは武器屋放置ゲームの主要な処理フローをMermaid記法で表現したシーケンス図です。

## 1. 認証フロー（ログイン・登録）

```mermaid
sequenceDiagram
    participant Client as Flutter Client
    participant AuthProvider as AuthProvider
    participant API as FastAPI Backend
    participant DB as PostgreSQL
    participant Cache as Redis Cache

    Note over Client, Cache: ユーザー認証フロー

    Client->>AuthProvider: login(email, password)
    AuthProvider->>API: POST /api/v1/auth/login
    API->>DB: SELECT * FROM players WHERE email = ?
    DB-->>API: Player data
    API->>API: verify_password(password, hashed_password)
    API->>DB: UPDATE players SET last_login_at = NOW()
    API->>Cache: store_refresh_token(user_id, token)
    API-->>AuthProvider: {access_token, refresh_token, user_data}
    AuthProvider->>AuthProvider: store_tokens_securely()
    AuthProvider-->>Client: Authentication Success
    
    Note over Client, Cache: 自動トークンリフレッシュ
    
    Client->>AuthProvider: API request with expired token
    AuthProvider->>API: POST /api/v1/auth/refresh
    API->>Cache: validate_refresh_token()
    Cache-->>API: Token valid
    API-->>AuthProvider: {new_access_token}
    AuthProvider->>AuthProvider: update_stored_token()
    AuthProvider-->>Client: Request completed with new token
```

## 2. 武器購入フロー

```mermaid
sequenceDiagram
    participant Client as Flutter Shop
    participant ShopProvider as ShopProvider
    participant API as FastAPI Backend
    participant DB as PostgreSQL

    Note over Client, DB: 武器購入処理

    Client->>ShopProvider: loadShopWeapons()
    ShopProvider->>API: GET /api/v1/weapons/shop
    API->>DB: SELECT * FROM weapon_masters WHERE shop_level <= player_level
    DB-->>API: Available weapons
    API-->>ShopProvider: Weapon catalog
    ShopProvider-->>Client: Display shop inventory

    Client->>ShopProvider: purchaseWeapon(weapon_id)
    ShopProvider->>API: POST /api/v1/shop/purchase
    API->>DB: BEGIN TRANSACTION
    API->>DB: SELECT gold FROM players WHERE id = ?
    DB-->>API: Current gold amount
    API->>API: validate_purchase(gold, weapon_cost)
    API->>DB: UPDATE players SET gold = gold - weapon_cost
    API->>DB: INSERT INTO player_weapons (player_id, weapon_id, acquired_at)
    API->>DB: UPDATE player_statistics SET weapons_purchased += 1
    API->>DB: COMMIT TRANSACTION
    API-->>ShopProvider: Purchase successful
    ShopProvider->>ShopProvider: updatePlayerGold()
    ShopProvider->>ShopProvider: addWeaponToInventory()
    ShopProvider-->>Client: Show purchase success dialog
```

## 3. クラフティング（武器作成）フロー

```mermaid
sequenceDiagram
    participant Client as Flutter Crafting
    participant CraftingProvider as CraftingProvider
    participant API as FastAPI Backend
    participant DB as PostgreSQL
    participant RNG as RNG System

    Note over Client, RNG: 武器クラフティング処理

    Client->>CraftingProvider: loadRecipes()
    CraftingProvider->>API: GET /api/v1/crafting/recipes
    API->>DB: SELECT * FROM crafting_recipes WITH materials
    DB-->>API: Recipe data with material requirements
    API-->>CraftingProvider: Available recipes
    CraftingProvider-->>Client: Display craftable recipes

    Client->>CraftingProvider: startCrafting(recipe_id)
    CraftingProvider->>API: POST /api/v1/crafting/craft
    API->>DB: BEGIN TRANSACTION
    API->>DB: SELECT materials FROM player_materials WHERE player_id = ?
    DB-->>API: Player's material inventory
    API->>API: validate_materials(required, available)
    API->>DB: UPDATE player_materials SET quantity = quantity - required
    API->>DB: UPDATE players SET gold = gold - crafting_cost
    API->>RNG: calculate_success_rate(recipe, player_level)
    RNG-->>API: Success/Failure result
    
    alt Crafting Success
        API->>DB: INSERT INTO player_weapons (crafted weapon)
        API->>DB: UPDATE player_statistics SET crafting_success += 1
        API->>DB: COMMIT TRANSACTION
        API-->>CraftingProvider: {success: true, weapon_data}
        CraftingProvider-->>Client: Show crafting success animation
    else Crafting Failure
        API->>DB: UPDATE player_statistics SET crafting_attempts += 1
        API->>DB: COMMIT TRANSACTION
        API-->>CraftingProvider: {success: false}
        CraftingProvider-->>Client: Show crafting failure message
    end
```

## 4. エンチャント（武器強化）フロー

```mermaid
sequenceDiagram
    participant Client as Flutter Enchantment
    participant EnchantmentProvider as EnchantmentProvider
    participant API as FastAPI Backend
    participant DB as PostgreSQL
    participant RNG as RNG System

    Note over Client, RNG: 武器エンチャント処理

    Client->>EnchantmentProvider: selectWeapon(weapon_id)
    EnchantmentProvider->>API: GET /api/v1/weapons/{weapon_id}/enchant-info
    API->>DB: SELECT weapon WITH current enchantments
    DB-->>API: Weapon and enchantment data
    API-->>EnchantmentProvider: Current enchantment levels
    EnchantmentProvider-->>Client: Display weapon enchantment UI

    Client->>EnchantmentProvider: startEnchantment(enchant_type, materials)
    EnchantmentProvider->>API: POST /api/v1/enchantments/enhance
    API->>DB: BEGIN TRANSACTION
    API->>DB: SELECT current_level FROM weapon_enchantments
    DB-->>API: Current enchantment level
    API->>API: calculate_success_rate(level, materials, enchant_type)
    API->>DB: UPDATE player_materials (consume materials)
    API->>RNG: determine_enchantment_result(success_rate)
    RNG-->>API: Success/Failure/Destroy result

    alt Enhancement Success
        API->>DB: UPDATE weapon_enchantments SET level = level + 1
        API->>DB: INSERT INTO enchantment_logs (success)
        API->>DB: COMMIT TRANSACTION
        API-->>EnchantmentProvider: {result: "success", new_level}
        EnchantmentProvider-->>Client: Show success animation
    else Enhancement Failure
        API->>DB: INSERT INTO enchantment_logs (failure)
        API->>DB: COMMIT TRANSACTION
        API-->>EnchantmentProvider: {result: "failure"}
        EnchantmentProvider-->>Client: Show failure message
    else Weapon Destroyed
        API->>DB: DELETE FROM player_weapons WHERE id = weapon_id
        API->>DB: INSERT INTO enchantment_logs (destroyed)
        API->>DB: COMMIT TRANSACTION
        API-->>EnchantmentProvider: {result: "destroyed"}
        EnchantmentProvider-->>Client: Show destruction animation
    end
```

## 5. ミッション進行フロー

```mermaid
sequenceDiagram
    participant Client as Flutter Mission
    participant MissionProvider as MissionProvider
    participant API as FastAPI Backend
    participant DB as PostgreSQL
    participant AutoProgress as Auto Progress Service

    Note over Client, AutoProgress: ミッション進行・報酬システム

    Client->>MissionProvider: loadActiveMissions()
    MissionProvider->>API: GET /api/v1/missions/active
    API->>DB: SELECT * FROM player_missions WHERE status = 'active'
    DB-->>API: Active mission data
    API-->>MissionProvider: Current missions with progress
    MissionProvider-->>Client: Display mission list

    Note over Client, AutoProgress: プレイヤーアクション（例：武器販売）

    Client->>ShopProvider: sellWeapon(weapon_id)
    ShopProvider->>API: POST /api/v1/shop/sell
    API->>DB: Process weapon sale...
    API->>AutoProgress: trigger_mission_progress("weapon_sell", 1)
    AutoProgress->>DB: UPDATE player_missions SET progress = progress + 1
    AutoProgress->>DB: SELECT missions WHERE progress >= target_amount
    DB-->>AutoProgress: Completed missions
    
    loop For each completed mission
        AutoProgress->>DB: UPDATE player_missions SET status = 'completed'
        AutoProgress->>DB: INSERT INTO mission_rewards (gold, exp, items)
    end

    AutoProgress-->>API: Mission progress updated
    API-->>ShopProvider: Sale completed with mission updates

    Note over Client, AutoProgress: ミッション報酬受取

    Client->>MissionProvider: claimRewards(mission_id)
    MissionProvider->>API: POST /api/v1/missions/{mission_id}/claim
    API->>DB: BEGIN TRANSACTION
    API->>DB: SELECT rewards FROM player_missions WHERE id = ?
    DB-->>API: Mission reward data
    API->>DB: UPDATE players SET gold = gold + reward_gold, exp = exp + reward_exp
    API->>DB: INSERT INTO player_materials (reward materials)
    API->>DB: UPDATE player_missions SET status = 'claimed'
    API->>DB: COMMIT TRANSACTION
    API-->>MissionProvider: Rewards claimed successfully
    MissionProvider-->>Client: Show reward animation
```

## 6. 放置収入システムフロー

```mermaid
sequenceDiagram
    participant Client as Flutter Idle
    participant IdleProvider as IdleProvider
    participant API as FastAPI Backend
    participant DB as PostgreSQL
    participant TimeCalc as Time Calculator

    Note over Client, TimeCalc: 放置収入計算・回収

    Client->>IdleProvider: calculateOfflineIncome()
    IdleProvider->>API: GET /api/v1/idle/offline-income
    API->>DB: SELECT last_collected_at, idle_upgrades FROM players
    DB-->>API: Last collection time and upgrades
    API->>TimeCalc: calculate_offline_duration(last_collected_at, now)
    TimeCalc-->>API: Offline duration in seconds
    API->>API: calculate_income(duration, upgrades, multipliers)
    API-->>IdleProvider: {offline_income, duration}
    IdleProvider-->>Client: Show offline income dialog

    Client->>IdleProvider: collectOfflineIncome()
    IdleProvider->>API: POST /api/v1/idle/collect
    API->>DB: BEGIN TRANSACTION
    API->>DB: UPDATE players SET gold = gold + offline_income
    API->>DB: UPDATE players SET last_collected_at = NOW()
    API->>DB: UPDATE player_statistics SET total_idle_income += offline_income
    API->>DB: COMMIT TRANSACTION
    API-->>IdleProvider: Income collected
    IdleProvider-->>Client: Update gold display
```

## システム全体のアーキテクチャ概要

```mermaid
graph TB
    subgraph "Client Layer"
        A[Flutter Mobile App]
        B[React Admin Panel]
    end
    
    subgraph "Application Layer"
        C[Provider State Management]
        D[API Services]
    end
    
    subgraph "Server Layer"
        E[FastAPI Backend]
        F[JWT Authentication]
        G[Pydantic Validation]
    end
    
    subgraph "Data Layer"
        H[PostgreSQL Database]
        I[Redis Cache]
        J[SQLAlchemy ORM]
    end
    
    A --> C
    B --> D
    C --> D
    D --> E
    E --> F
    E --> G
    F --> I
    G --> J
    J --> H
```