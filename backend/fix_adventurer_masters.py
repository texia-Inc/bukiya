#!/usr/bin/env python3
"""
冒険者マスターデータを初心者向けに修正するスクリプト
"""
import os
import sys
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy import create_engine, text
from app.core.config import settings

def main():
    print('冒険者マスターデータを修正中...')
    # Use localhost instead of postgres hostname for local script
    db_url = "postgresql://bukiya_user:bukiya_password@localhost:5432/bukiya_game"
    engine = create_engine(db_url)
    
    with engine.begin() as conn:
        try:
            # 既存の冒険者マスターを初心者向けに修正
            updates = [
                ("新米剣士アレン", 5, 100, 500),
                ("見習い弓使いリリー", 8, 80, 400),
                ("駆け出し魔法使いミナ", 6, 90, 450),
                ("熟練戦士ガルド", 25, 500, 2000),
                ("狩人マスターエリオット", 30, 800, 2500),
                ("大魔道士セレナ", 35, 1000, 3000),
            ]
            
            for name, min_attack, budget_min, budget_max in updates:
                result = conn.execute(text(f"""
                    UPDATE adventurer_masters SET 
                        min_attack_requirement = {min_attack},
                        budget_min = {budget_min},
                        budget_max = {budget_max}
                    WHERE name = '{name}'
                """))
                print(f'Updated {name}: {result.rowcount} rows affected')
            
            # 新しい超初心者向け冒険者を追加（既存チェック付き）
            new_adventurers = [
                ("村の少年タム", "warrior", 1, "friendly", 10, 50, 200, "sword", 
                 "村で冒険を始めたばかりの少年。どんな武器でも喜んで使う。", 1, 1.0, 1, 50, 1, 3),
                ("見習い狩人サラ", "archer", 2, "normal", 15, 60, 250, "bow",
                 "弓の練習をしている見習い。安い弓を探している。", 3, 1.2, 2, 40, 1, 5),
                ("魔法学校の生徒リオ", "mage", 2, "stingy", 20, 40, 180, "staff",
                 "魔法学校の1年生。お小遣いで買える杖を探している。", 2, 0.8, 1, 35, 1, 4),
            ]
            
            for adv in new_adventurers:
                # Check if exists first
                check = conn.execute(text(f"SELECT COUNT(*) FROM adventurer_masters WHERE name = '{adv[0]}'"))
                if check.scalar() == 0:
                    conn.execute(text(f"""
                        INSERT INTO adventurer_masters (
                            name, profession, level, personality, trust_level, 
                            budget_min, budget_max, preferred_weapon_type, 
                            description, min_attack_requirement, max_budget_multiplier, 
                            urgency_tendency, spawn_weight, min_player_level, max_player_level, 
                            is_active, created_at, updated_at
                        ) VALUES (
                            '{adv[0]}', '{adv[1]}', {adv[2]}, '{adv[3]}', {adv[4]}, 
                            {adv[5]}, {adv[6]}, '{adv[7]}', 
                            '{adv[8]}', {adv[9]}, {adv[10]}, 
                            {adv[11]}, {adv[12]}, {adv[13]}, {adv[14]}, 
                            true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                        )
                    """))
                    print(f'Added new adventurer: {adv[0]}')
                else:
                    print(f'Adventurer {adv[0]} already exists')
            
            print('冒険者マスターデータの修正完了')
            
            # 確認
            result = conn.execute(text("""
                SELECT name, min_attack_requirement, budget_min, budget_max, min_player_level 
                FROM adventurer_masters 
                WHERE min_player_level <= 5 
                ORDER BY min_player_level, min_attack_requirement
            """))
            
            print('\n=== 初心者向け冒険者一覧 ===')
            for row in result:
                print(f'{row[0]}: 攻撃力{row[1]}以上, 予算{row[2]}-{row[3]}G, プレイヤーLv{row[4]}')
            
        except Exception as e:
            print(f'エラー: {e}')
            import traceback
            traceback.print_exc()

if __name__ == '__main__':
    main()