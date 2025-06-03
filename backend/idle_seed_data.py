"""
放置システム用のシードデータ
"""

from sqlalchemy.orm import Session
from app.core.database import SessionLocal
from app.models.idle_system import IdleUpgradeMaster, IdleBonusMaster


def create_idle_upgrade_masters(db: Session):
    """放置システムアップグレードマスターデータを作成"""
    
    upgrades = [
        {
            "id": "efficiency_boost",
            "name": "効率向上",
            "description": "武器製造の効率を向上させ、収益を増加させます",
            "base_cost": 100,
            "income_multiplier": 1.2,
            "max_level": 20,
            "icon_name": "efficiency",
            "unlock_level": 1,
            "is_active": True
        },
        {
            "id": "automation",
            "name": "自動化システム",
            "description": "製造プロセスを自動化し、大幅な収益向上を実現します",
            "base_cost": 500,
            "income_multiplier": 1.5,
            "max_level": 15,
            "icon_name": "automation",
            "unlock_level": 3,
            "is_active": True
        },
        {
            "id": "quality_control",
            "name": "品質管理",
            "description": "武器の品質を向上させ、より高い価格で販売できます",
            "base_cost": 250,
            "income_multiplier": 1.3,
            "max_level": 18,
            "icon_name": "quality",
            "unlock_level": 2,
            "is_active": True
        },
        {
            "id": "speed_enhancement",
            "name": "製造速度向上",
            "description": "製造速度を向上させ、より多くの武器を生産できます",
            "base_cost": 150,
            "income_multiplier": 1.15,
            "max_level": 25,
            "icon_name": "speed",
            "unlock_level": 1,
            "is_active": True
        },
        {
            "id": "material_efficiency",
            "name": "素材効率化",
            "description": "素材の使用効率を向上させ、コストを削減します",
            "base_cost": 300,
            "income_multiplier": 1.25,
            "max_level": 12,
            "icon_name": "materials",
            "unlock_level": 4,
            "is_active": True
        },
        {
            "id": "advanced_tools",
            "name": "高級工具",
            "description": "高品質な工具を使用し、製造効率を大幅に向上させます",
            "base_cost": 1000,
            "income_multiplier": 2.0,
            "max_level": 10,
            "icon_name": "tools",
            "unlock_level": 5,
            "is_active": True
        }
    ]
    
    for upgrade_data in upgrades:
        existing = db.query(IdleUpgradeMaster).filter(
            IdleUpgradeMaster.id == upgrade_data["id"]
        ).first()
        
        if not existing:
            upgrade = IdleUpgradeMaster(**upgrade_data)
            db.add(upgrade)
    
    db.commit()
    print("放置システムアップグレードマスターデータを作成しました")


def create_idle_bonus_masters(db: Session):
    """放置システムボーナスマスターデータを作成"""
    
    bonuses = [
        {
            "id": "double_income",
            "name": "収益2倍ブースト",
            "description": "1時間の間、収益が2倍になります",
            "multiplier": 2.0,
            "duration_seconds": 3600,  # 1時間
            "icon_name": "income_boost",
            "bonus_type": "income",
            "is_active": True
        },
        {
            "id": "mega_boost",
            "name": "メガブースト",
            "description": "30分間、収益が3倍になります",
            "multiplier": 3.0,
            "duration_seconds": 1800,  # 30分
            "icon_name": "mega_boost",
            "bonus_type": "income",
            "is_active": True
        },
        {
            "id": "experience_boost",
            "name": "経験値ブースト",
            "description": "2時間の間、経験値獲得量が2倍になります",
            "multiplier": 2.0,
            "duration_seconds": 7200,  # 2時間
            "icon_name": "exp_boost",
            "bonus_type": "experience",
            "is_active": True
        },
        {
            "id": "crafting_boost",
            "name": "錬成効率ブースト",
            "description": "1時間の間、錬成効率が1.5倍になります",
            "multiplier": 1.5,
            "duration_seconds": 3600,  # 1時間
            "icon_name": "crafting_boost",
            "bonus_type": "crafting",
            "is_active": True
        },
        {
            "id": "super_income",
            "name": "スーパー収益ブースト",
            "description": "15分間、収益が5倍になります",
            "multiplier": 5.0,
            "duration_seconds": 900,  # 15分
            "icon_name": "super_boost",
            "bonus_type": "income",
            "is_active": True
        }
    ]
    
    for bonus_data in bonuses:
        existing = db.query(IdleBonusMaster).filter(
            IdleBonusMaster.id == bonus_data["id"]
        ).first()
        
        if not existing:
            bonus = IdleBonusMaster(**bonus_data)
            db.add(bonus)
    
    db.commit()
    print("放置システムボーナスマスターデータを作成しました")


def main():
    """メイン関数"""
    db = SessionLocal()
    try:
        print("放置システムのシードデータを作成中...")
        create_idle_upgrade_masters(db)
        create_idle_bonus_masters(db)
        print("放置システムのシードデータ作成完了！")
    except Exception as e:
        print(f"エラーが発生しました: {e}")
        db.rollback()
    finally:
        db.close()


if __name__ == "__main__":
    main()
