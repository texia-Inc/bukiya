#!/usr/bin/env python3
"""
ミッションテンプレートのサンプルデータを作成するスクリプト
"""

import sys
import os
from datetime import datetime

# プロジェクトルートをPythonパスに追加
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models import MissionTemplate

def create_sample_mission_templates():
    """サンプルミッションテンプレートを作成"""
    
    # データベースセッション取得
    db_gen = get_db()
    db: Session = next(db_gen)
    
    try:
        # 既存のテンプレートをチェック
        existing_count = db.query(MissionTemplate).count()
        if existing_count > 0:
            print(f"既に {existing_count} 個のミッションテンプレートが存在します。")
            return
        
        # デイリーミッション
        daily_missions = [
            {
                "name": "武器を1個作成",
                "description": "合成で武器を1個作成しよう",
                "mission_type": "daily",
                "target_type": "craft_weapon",
                "target_count": 1,
                "reward_gold": 100,
                "reward_exp": 50,
                "required_level": 1,
                "display_order": 1
            },
            {
                "name": "武器を2個販売",
                "description": "冒険者に武器を2個販売しよう",
                "mission_type": "daily",
                "target_type": "sell_weapon",
                "target_count": 2,
                "reward_gold": 200,
                "reward_exp": 75,
                "required_level": 1,
                "display_order": 2
            },
            {
                "name": "500ゴールド獲得",
                "description": "合計500ゴールドを獲得しよう",
                "mission_type": "daily",
                "target_type": "earn_gold",
                "target_count": 500,
                "reward_gold": 150,
                "reward_exp": 60,
                "required_level": 1,
                "display_order": 3
            }
        ]
        
        # ウィークリーミッション
        weekly_missions = [
            {
                "name": "武器を10個作成",
                "description": "週間で武器を10個作成しよう",
                "mission_type": "weekly",
                "target_type": "craft_weapon",
                "target_count": 10,
                "reward_gold": 1000,
                "reward_exp": 500,
                "required_level": 1,
                "display_order": 1
            },
            {
                "name": "武器を15個販売",
                "description": "週間で武器を15個販売しよう",
                "mission_type": "weekly",
                "target_type": "sell_weapon",
                "target_count": 15,
                "reward_gold": 1500,
                "reward_exp": 750,
                "required_level": 1,
                "display_order": 2
            },
            {
                "name": "5000ゴールド獲得",
                "description": "週間で5000ゴールドを獲得しよう",
                "mission_type": "weekly",
                "target_type": "earn_gold",
                "target_count": 5000,
                "reward_gold": 2000,
                "reward_exp": 1000,
                "required_level": 1,
                "display_order": 3
            }
        ]
        
        # アチーブメント
        achievements = [
            {
                "name": "初めての武器作成",
                "description": "初めて武器を作成する",
                "mission_type": "achievement",
                "target_type": "craft_weapon",
                "target_count": 1,
                "reward_gold": 500,
                "reward_exp": 200,
                "required_level": 1,
                "display_order": 1
            },
            {
                "name": "武器作成マスター",
                "description": "武器を100個作成する",
                "mission_type": "achievement",
                "target_type": "craft_weapon",
                "target_count": 100,
                "reward_gold": 10000,
                "reward_exp": 5000,
                "required_level": 1,
                "display_order": 2
            },
            {
                "name": "商売の天才",
                "description": "武器を500個販売する",
                "mission_type": "achievement",
                "target_type": "sell_weapon",
                "target_count": 500,
                "reward_gold": 25000,
                "reward_exp": 10000,
                "required_level": 5,
                "display_order": 3
            },
            {
                "name": "大富豪",
                "description": "合計100,000ゴールドを獲得する",
                "mission_type": "achievement",
                "target_type": "earn_gold",
                "target_count": 100000,
                "reward_gold": 50000,
                "reward_exp": 20000,
                "required_level": 10,
                "display_order": 4
            }
        ]
        
        all_missions = daily_missions + weekly_missions + achievements
        
        # ミッションテンプレートを作成
        for mission_data in all_missions:
            mission_template = MissionTemplate(
                name=mission_data["name"],
                description=mission_data["description"],
                mission_type=mission_data["mission_type"],
                target_type=mission_data["target_type"],
                target_count=mission_data["target_count"],
                reward_gold=mission_data["reward_gold"],
                reward_exp=mission_data["reward_exp"],
                required_level=mission_data["required_level"],
                display_order=mission_data["display_order"],
                is_active=True,
                created_at=datetime.utcnow(),
                updated_at=datetime.utcnow()
            )
            db.add(mission_template)
        
        db.commit()
        print(f"✅ {len(all_missions)} 個のミッションテンプレートを作成しました")
        
        # 作成結果を表示
        total_templates = db.query(MissionTemplate).count()
        daily_count = db.query(MissionTemplate).filter(MissionTemplate.mission_type == "daily").count()
        weekly_count = db.query(MissionTemplate).filter(MissionTemplate.mission_type == "weekly").count()
        achievement_count = db.query(MissionTemplate).filter(MissionTemplate.mission_type == "achievement").count()
        
        print(f"📊 合計: {total_templates} 個")
        print(f"   - デイリー: {daily_count} 個")
        print(f"   - ウィークリー: {weekly_count} 個") 
        print(f"   - アチーブメント: {achievement_count} 個")
        
    except Exception as e:
        print(f"❌ エラーが発生しました: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("🎯 ミッションテンプレートのサンプルデータを作成中...")
    create_sample_mission_templates()
    print("✨ 完了しました！")