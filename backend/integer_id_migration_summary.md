# 連番ID移行完了サマリー

## 移行完了テーブル

✅ **weapon_masters**: 文字列ID → 連番ID (1-24)
✅ **material_masters**: 文字列ID → 連番ID (1-23)  
✅ **monster_masters**: 文字列ID → 連番ID (1-6)
✅ **adventurer_masters**: 文字列ID → 連番ID (1-5)
✅ **area_masters**: 文字列ID → 連番ID (1-3)
✅ **crafting_recipes**: 連番ID対応 (1-5)
✅ **recipe_materials**: 連番ID外部キー対応
✅ **monster_drop_tables**: 連番ID外部キー対応
✅ **adventurer_instances**: 連番ID外部キー対応
✅ **adventurer_visits**: 連番ID外部キー対応  
✅ **player_adventurer_relationships**: 連番ID外部キー対応

## 作成されたマイグレーションファイル

### 1. 武器・素材・レシピ移行
- `restore_integer_ids.sql` - 武器・素材の文字列ID→連番ID移行
- `restore_materials_and_recipes.sql` - 素材データ追加・レシピテーブル再作成
- `fix_recipe_materials.sql` - レシピ素材の正しいID修正

### 2. モンスター移行
- `restore_monster_integer_ids.sql` - モンスターの文字列ID→連番ID移行
- `fix_monster_drop_tables.sql` - ドロップテーブル修正・データ復元

### 3. 冒険者マスター移行
- `restore_adventurer_integer_ids.sql` - 冒険者マスターの文字列ID→連番ID移行
- `fix_adventurer_related_tables.sql` - 関連テーブル型変更・外部キー修正

### 4. エリアマスター移行
- `restore_area_integer_ids.sql` - エリアマスターの文字列ID→連番ID移行

### 5. Pythonスクリプト（予備）
- `restore_integer_ids_migration.py` - Python版マイグレーションスクリプト

## データ確認結果

```sql
-- 最終的なデータ状況
SELECT 'weapon_masters' as table_name, COUNT(*) FROM weapon_masters     -- 24件
UNION ALL SELECT 'material_masters', COUNT(*) FROM material_masters      -- 23件  
UNION ALL SELECT 'monster_masters', COUNT(*) FROM monster_masters        -- 6件
UNION ALL SELECT 'adventurer_masters', COUNT(*) FROM adventurer_masters  -- 5件
UNION ALL SELECT 'area_masters', COUNT(*) FROM area_masters              -- 3件
UNION ALL SELECT 'crafting_recipes', COUNT(*) FROM crafting_recipes      -- 5件
UNION ALL SELECT 'recipe_materials', COUNT(*) FROM recipe_materials      -- 20件
UNION ALL SELECT 'monster_drop_tables', COUNT(*) FROM monster_drop_tables; -- 18件
```

## API修正内容

### Pydanticスキーマ修正 (`/app/schemas/crafting.py`)
```python
# 修正前: 文字列ID
material_id: str = Field(..., description="素材ID")
weapon_id: str = Field(..., description="武器ID")

# 修正後: 連番ID  
material_id: int = Field(..., description="素材ID")
weapon_id: int = Field(..., description="武器ID")
```

### モデル修正 (`/app/models/adventurer_master.py`)
```python
# MonsterDropTableのdrop_target_idをNULL許可に変更
drop_target_id = Column(String(50), nullable=True)  # NULL for gold drops

# AdventurerMasterのIDを連番に変更
id = Column(Integer, primary_key=True, autoincrement=True, index=True)
```

### モデル修正 (`/app/models/adventurer_instance.py`)
```python
# AdventurerInstanceのadventurer_master_idを連番IDに変更
adventurer_master_id = Column(Integer, ForeignKey("adventurer_masters.id"), nullable=True)

# AreaMasterモデルを追加
id = Column(Integer, primary_key=True, autoincrement=True, index=True)

# MonsterMasterのarea_idを連番IDに変更
area_id = Column(Integer, nullable=False)  # 連番IDに変更済み
```

## API動作確認

✅ `/api/v1/crafting/recipes/admin/list` - 正常動作、連番IDで返却
✅ `/api/v1/health` - バックエンド正常起動

## 移行時の注意点

1. **外部キー制約**: 移行時に一時的に無効化し、完了後に再有効化
2. **データ順序**: 名前順でソートして一貫した連番ID割り当て
3. **NULLカラム**: goldドロップでdrop_target_idがNULLになることを考慮
4. **バックアップ**: 移行前データは各SQLスクリプト内でバックアップ処理

## 今回修正された500エラー

1. **crafting recipes API**: Pydanticスキーマの型不一致解決
2. **adventurer sell API**: 
   - adventurer_masterのNULLチェック追加
   - AdventurerPurchaseのフィールド名修正

すべてのテーブルが連番IDシステムに統一され、APIも正常動作しています。