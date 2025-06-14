from sqlalchemy.orm import Session
from typing import List, Dict, Optional
from app.models import Player


class ShopProgressionService:
    """ショップレベル進行管理サービス"""
    
    # 各行動で得られる経験値設定
    EXP_VALUES = {
        "weapon_procurement": 10,   # 武器仕入れ
        "weapon_sell": 5,           # 武器売却
        "weapon_craft": 15,         # 武器作成
        "enchant_success": 20,      # エンチャント成功
        "enchant_failure": 5,       # エンチャント失敗
        "quest_complete": 8,        # クエスト完了
        "mission_complete": 12,     # ミッション完了
        "trade_adventurer": 10,     # 冒険者取引
        "bulk_buyback": 3,          # 一括買取（アイテム1個あたり）
    }

    @classmethod
    def add_experience(
        cls, 
        player: Player, 
        action: str, 
        db: Session,
        multiplier: float = 1.0
    ) -> Dict[str, any]:
        """
        プレイヤーにショップ経験値を追加
        
        Args:
            player: プレイヤーオブジェクト
            action: 行動タイプ
            db: データベースセッション
            multiplier: 経験値倍率
            
        Returns:
            結果辞書 (leveled_up, new_level, exp_gained, etc.)
        """
        if action not in cls.EXP_VALUES:
            return {
                "success": False,
                "error": f"Unknown action: {action}"
            }
        
        base_exp = cls.EXP_VALUES[action]
        exp_gained = int(base_exp * multiplier)
        
        old_level = player.shop_level
        old_exp = player.shop_exp
        
        # 経験値追加とレベルアップチェック
        leveled_up = player.add_shop_exp(exp_gained)
        
        # データベース更新
        db.commit()
        
        result = {
            "success": True,
            "action": action,
            "exp_gained": exp_gained,
            "old_level": old_level,
            "new_level": player.shop_level,
            "leveled_up": leveled_up,
            "current_exp": player.shop_exp,
            "next_level_exp_required": player.next_level_exp_required,
            "progress_percentage": player.shop_level_progress_percentage
        }
        
        if leveled_up:
            result["level_up_message"] = f"ショップレベルが{old_level}から{player.shop_level}に上がりました！"
        
        return result

    @classmethod
    def bulk_add_experience(
        cls, 
        player: Player, 
        actions: List[Dict[str, any]], 
        db: Session
    ) -> Dict[str, any]:
        """
        複数の行動に対して経験値を一括追加
        
        Args:
            player: プレイヤーオブジェクト
            actions: 行動リスト [{"action": "weapon_purchase", "multiplier": 1.0}, ...]
            db: データベースセッション
            
        Returns:
            統合結果辞書
        """
        old_level = player.shop_level
        total_exp = 0
        processed_actions = []
        
        for action_data in actions:
            action = action_data.get("action")
            multiplier = action_data.get("multiplier", 1.0)
            
            if action in cls.EXP_VALUES:
                base_exp = cls.EXP_VALUES[action]
                exp_gained = int(base_exp * multiplier)
                player.add_shop_exp(exp_gained)
                total_exp += exp_gained
                processed_actions.append({
                    "action": action,
                    "exp_gained": exp_gained
                })
        
        db.commit()
        
        leveled_up = player.shop_level > old_level
        levels_gained = player.shop_level - old_level
        
        return {
            "success": True,
            "processed_actions": processed_actions,
            "total_exp_gained": total_exp,
            "old_level": old_level,
            "new_level": player.shop_level,
            "levels_gained": levels_gained,
            "leveled_up": leveled_up,
            "current_exp": player.shop_exp,
            "next_level_exp_required": player.next_level_exp_required,
            "progress_percentage": player.shop_level_progress_percentage
        }

    @classmethod
    def get_progression_info(cls, player: Player) -> Dict[str, any]:
        """
        プレイヤーのショップレベル進行情報を取得
        
        Args:
            player: プレイヤーオブジェクト
            
        Returns:
            進行情報辞書
        """
        return {
            "current_level": player.shop_level,
            "current_exp": player.shop_exp,
            "next_level_exp_required": player.next_level_exp_required,
            "progress_percentage": player.shop_level_progress_percentage,
            "total_exp_for_next_level": player.calculate_required_shop_exp(player.shop_level),
            "exp_values": cls.EXP_VALUES
        }

    @classmethod
    def calculate_exp_for_action(cls, action: str, multiplier: float = 1.0) -> int:
        """
        指定された行動で得られる経験値を計算
        
        Args:
            action: 行動タイプ
            multiplier: 経験値倍率
            
        Returns:
            得られる経験値
        """
        if action not in cls.EXP_VALUES:
            return 0
        return int(cls.EXP_VALUES[action] * multiplier)

    @classmethod
    def get_available_actions(cls) -> List[str]:
        """利用可能な行動タイプのリストを取得"""
        return list(cls.EXP_VALUES.keys())