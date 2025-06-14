#!/usr/bin/env python3
from app.core.database import SessionLocal
from app.models import WeaponType, RarityLevel, WeaponMaster, MaterialMaster

def main():
    print('シードデータを投入中...')
    db = SessionLocal()

    try:
        # 既存データを削除
        db.query(WeaponMaster).delete()
        db.query(MaterialMaster).delete()
        db.query(WeaponType).delete()
        db.query(RarityLevel).delete()
        db.commit()
        print('既存データ削除完了')
        
        # 武器タイプ
        weapon_types = [
            WeaponType(id='sword', name='剣', description='近接武器'),
            WeaponType(id='staff', name='杖', description='魔法武器'),
            WeaponType(id='bow', name='弓', description='遠距離武器'),
            WeaponType(id='axe', name='斧', description='重武器'),
            WeaponType(id='dagger', name='短剣', description='軽武器')
        ]
        db.add_all(weapon_types)
        db.commit()
        print(f'武器タイプ {len(weapon_types)} 件作成')
        
        # レアリティ
        rarities = [
            RarityLevel(id='1', name='Common', level=1, color_code='#9e9e9e', attack_multiplier=1.0, base_drop_rate=0.6),
            RarityLevel(id='2', name='Rare', level=2, color_code='#2196f3', attack_multiplier=1.5, base_drop_rate=0.3),
            RarityLevel(id='3', name='Epic', level=3, color_code='#9c27b0', attack_multiplier=2.0, base_drop_rate=0.1),
            RarityLevel(id='4', name='Legendary', level=4, color_code='#ff9800', attack_multiplier=3.0, base_drop_rate=0.05)
        ]
        db.add_all(rarities)
        db.commit()
        print(f'レアリティ {len(rarities)} 件作成')
        
        # 武器マスター
        weapons = [
            WeaponMaster(id='iron_sword', name='鉄の剣', weapon_type_id='sword', rarity_id='1', base_attack_min=8, base_attack_max=12, base_price_min=80, base_price_max=120),
            WeaponMaster(id='fire_staff', name='炎の杖', weapon_type_id='staff', rarity_id='2', base_attack_min=12, base_attack_max=18, base_price_min=160, base_price_max=240),
            WeaponMaster(id='ice_bow', name='氷の弓', weapon_type_id='bow', rarity_id='2', base_attack_min=10, base_attack_max=14, base_price_min=144, base_price_max=216),
            WeaponMaster(id='steel_sword', name='鋼の剣', weapon_type_id='sword', rarity_id='2', base_attack_min=16, base_attack_max=24, base_price_min=240, base_price_max=360),
            WeaponMaster(id='magic_staff', name='魔法の杖', weapon_type_id='staff', rarity_id='3', base_attack_min=24, base_attack_max=36, base_price_min=400, base_price_max=600),
            WeaponMaster(id='battle_axe', name='戦斧', weapon_type_id='axe', rarity_id='1', base_attack_min=14, base_attack_max=22, base_price_min=120, base_price_max=180),
            WeaponMaster(id='poison_dagger', name='毒の短剣', weapon_type_id='dagger', rarity_id='2', base_attack_min=6, base_attack_max=10, base_price_min=96, base_price_max=144),
            WeaponMaster(id='legendary_sword', name='伝説の剣', weapon_type_id='sword', rarity_id='4', base_attack_min=40, base_attack_max=60, base_price_min=800, base_price_max=1200)
        ]
        db.add_all(weapons)
        db.commit()
        print(f'武器マスター {len(weapons)} 件作成')
        
        # 素材マスター
        materials = [
            MaterialMaster(id='iron_ore', name='鉄鉱石', rarity_id='1', base_price=10),
            MaterialMaster(id='magic_crystal', name='魔法の水晶', rarity_id='2', base_price=50),
            MaterialMaster(id='ancient_wood', name='古代の木材', rarity_id='1', base_price=20),
            MaterialMaster(id='rare_gem', name='希少な宝石', rarity_id='3', base_price=100),
            MaterialMaster(id='dragon_scale', name='ドラゴンの鱗', rarity_id='3', base_price=200),
            MaterialMaster(id='mithril_ore', name='ミスリル鉱石', rarity_id='4', base_price=500),
            MaterialMaster(id='poison_herb', name='毒草', rarity_id='1', base_price=5),
            MaterialMaster(id='holy_water', name='聖なる水', rarity_id='2', base_price=80)
        ]
        db.add_all(materials)
        db.commit()
        print(f'素材マスター {len(materials)} 件作成')
        
        # 確認
        weapon_count = db.query(WeaponMaster).count()
        material_count = db.query(MaterialMaster).count()
        weapon_type_count = db.query(WeaponType).count()
        rarity_count = db.query(RarityLevel).count()
        
        print(f'\n=== データ投入結果 ===')
        print(f'武器タイプ: {weapon_type_count} 件')
        print(f'レアリティ: {rarity_count} 件')
        print(f'武器マスター: {weapon_count} 件')
        print(f'素材マスター: {material_count} 件')
        print('\nシードデータ投入完了！')
        
    except Exception as e:
        print(f'エラー: {e}')
        import traceback
        traceback.print_exc()
        db.rollback()
    finally:
        db.close()

if __name__ == '__main__':
    main()
