"""
エンチャントシステムのシードデータ作成スクリプト
"""

import asyncio
from sqlalchemy.orm import Session
from app.core.database import SessionLocal, engine
from app.models.enchantment import (
    EnchantmentType, EnchantmentMaterial, PlayerEnchantmentMaterial
)
from app.models.player import Player

def create_enchantment_seed_data():
    """エンチャントシステムのシードデータを作成"""
    db = SessionLocal()
    
    try:
        # エンチャントタイプの作成
        enchantment_types = [
            {
                "name": "攻撃力強化",
                "description": "武器の攻撃力を向上させます",
                "effect_type": "attack",
                "effect_value": 5.0,
                "max_level": 10,
                "base_success_rate": 0.8,
                "base_cost": 100,
                "required_materials": {"basic_stone": 1},
                "is_active": True
            },
            {
                "name": "防御力強化",
                "description": "武器の防御効果を向上させます",
                "effect_type": "defense",
                "effect_value": 3.0,
                "max_level": 10,
                "base_success_rate": 0.85,
                "base_cost": 80,
                "required_materials": {"defense_crystal": 1},
                "is_active": True
            },
            {
                "name": "速度強化",
                "description": "武器の攻撃速度を向上させます",
                "effect_type": "speed",
                "effect_value": 2.0,
                "max_level": 15,
                "base_success_rate": 0.75,
                "base_cost": 120,
                "required_materials": {"speed_gem": 1},
                "is_active": True
            },
            {
                "name": "クリティカル強化",
                "description": "クリティカル率を向上させます",
                "effect_type": "critical",
                "effect_value": 1.5,
                "max_level": 20,
                "base_success_rate": 0.7,
                "base_cost": 150,
                "required_materials": {"critical_shard": 1},
                "is_active": True
            },
            {
                "name": "命中強化",
                "description": "武器の命中率を向上させます",
                "effect_type": "accuracy",
                "effect_value": 2.5,
                "max_level": 12,
                "base_success_rate": 0.8,
                "base_cost": 90,
                "required_materials": {"accuracy_powder": 1},
                "is_active": True
            },
            {
                "name": "耐久強化",
                "description": "武器の耐久性を向上させます",
                "effect_type": "durability",
                "effect_value": 10.0,
                "max_level": 8,
                "base_success_rate": 0.9,
                "base_cost": 70,
                "required_materials": {"durability_ore": 1},
                "is_active": True
            }
        ]
        
        for enchant_data in enchantment_types:
            existing = db.query(EnchantmentType).filter(
                EnchantmentType.name == enchant_data["name"]
            ).first()
            
            if not existing:
                enchantment_type = EnchantmentType(**enchant_data)
                db.add(enchantment_type)
                print(f"エンチャントタイプ作成: {enchant_data['name']}")
        
        # エンチャント素材の作成
        enchantment_materials = [
            {
                "name": "基本強化石",
                "description": "最も基本的な強化素材",
                "rarity": "common",
                "effect_type": "attack",
                "success_rate_bonus": 0.05,
                "cost_multiplier": 1.0,
                "max_stack": 999,
                "is_active": True
            },
            {
                "name": "防御クリスタル",
                "description": "防御力強化に特化した素材",
                "rarity": "uncommon",
                "effect_type": "defense",
                "success_rate_bonus": 0.08,
                "cost_multiplier": 1.2,
                "max_stack": 500,
                "is_active": True
            },
            {
                "name": "速度ジェム",
                "description": "速度強化に特化した貴重な宝石",
                "rarity": "rare",
                "effect_type": "speed",
                "success_rate_bonus": 0.1,
                "cost_multiplier": 1.5,
                "max_stack": 200,
                "is_active": True
            },
            {
                "name": "クリティカルシャード",
                "description": "クリティカル強化の欠片",
                "rarity": "epic",
                "effect_type": "critical",
                "success_rate_bonus": 0.12,
                "cost_multiplier": 2.0,
                "max_stack": 100,
                "is_active": True
            },
            {
                "name": "命中パウダー",
                "description": "命中率を高める魔法の粉",
                "rarity": "uncommon",
                "effect_type": "accuracy",
                "success_rate_bonus": 0.07,
                "cost_multiplier": 1.1,
                "max_stack": 300,
                "is_active": True
            },
            {
                "name": "耐久鉱石",
                "description": "武器の耐久性を高める特殊鉱石",
                "rarity": "common",
                "effect_type": "durability",
                "success_rate_bonus": 0.06,
                "cost_multiplier": 0.9,
                "max_stack": 999,
                "is_active": True
            },
            {
                "name": "万能強化石",
                "description": "全ての強化に使える万能素材",
                "rarity": "legendary",
                "effect_type": None,
                "success_rate_bonus": 0.15,
                "cost_multiplier": 0.8,
                "max_stack": 50,
                "is_active": True
            },
            {
                "name": "保護の加護",
                "description": "強化失敗時の破壊を防ぐ",
                "rarity": "epic",
                "effect_type": "protection",
                "success_rate_bonus": 0.0,
                "cost_multiplier": 3.0,
                "max_stack": 10,
                "is_active": True
            }
        ]
        
        for material_data in enchantment_materials:
            existing = db.query(EnchantmentMaterial).filter(
                EnchantmentMaterial.name == material_data["name"]
            ).first()
            
            if not existing:
                material = EnchantmentMaterial(**material_data)
                db.add(material)
                print(f"エンチャント素材作成: {material_data['name']}")
        
        db.commit()
        
        # テストプレイヤーに素材を配布
        test_player = db.query(Player).filter(Player.username == "testuser").first()
        if test_player:
            materials = db.query(EnchantmentMaterial).all()
            
            for material in materials:
                existing_player_material = db.query(PlayerEnchantmentMaterial).filter(
                    PlayerEnchantmentMaterial.player_id == test_player.id,
                    PlayerEnchantmentMaterial.material_id == material.id
                ).first()
                
                if not existing_player_material:
                    # レアリティに応じて配布量を調整
                    quantity_map = {
                        "common": 50,
                        "uncommon": 20,
                        "rare": 10,
                        "epic": 5,
                        "legendary": 2
                    }
                    quantity = quantity_map.get(material.rarity, 10)
                    
                    player_material = PlayerEnchantmentMaterial(
                        player_id=test_player.id,
                        material_id=material.id,
                        quantity=quantity
                    )
                    db.add(player_material)
                    print(f"プレイヤーに素材配布: {material.name} x{quantity}")
            
            db.commit()
        
        print("エンチャントシステムのシードデータ作成完了！")
        
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    create_enchantment_seed_data()
