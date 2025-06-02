from sqlalchemy import Column, Integer, String, Text, Boolean, DateTime, ForeignKey, Float, CheckConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.core.database import Base

class CraftingRecipe(Base):
    __tablename__ = "crafting_recipes"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    weapon_id = Column(Integer, ForeignKey("weapon_masters.id"), nullable=False)
    name = Column(String(100), nullable=False)
    description = Column(Text)
    gold_cost = Column(Integer, default=0, nullable=False)
    success_rate = Column(Float, default=1.0, nullable=False)
    required_level = Column(Integer, default=1, nullable=False)
    is_active = Column(Boolean, default=True, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 制約
    __table_args__ = (
        CheckConstraint('gold_cost >= 0', name='crafting_recipes_gold_cost_check'),
        CheckConstraint('success_rate >= 0 AND success_rate <= 1', name='crafting_recipes_success_rate_check'),
        CheckConstraint('required_level >= 1', name='crafting_recipes_required_level_check'),
    )
    
    # リレーションシップ
    weapon = relationship("WeaponMaster", back_populates="crafting_recipes")
    materials = relationship("RecipeMaterial", back_populates="recipe")
    
    def __repr__(self):
        return f"<CraftingRecipe(id={self.id}, name='{self.name}', success_rate={self.success_rate})>"
    
    def can_craft(self, player):
        """プレイヤーが合成可能かチェック"""
        # レベルチェック
        if player.shop_level < self.required_level:
            return False, "ショップレベルが不足しています"
        
        # ゴールドチェック
        if not player.can_afford(self.gold_cost):
            return False, "ゴールドが不足しています"
        
        # 素材チェック
        for recipe_material in self.materials:
            player_material = next(
                (pm for pm in player.materials if pm.material_id == recipe_material.material_id),
                None
            )
            if not player_material or player_material.quantity < recipe_material.quantity:
                return False, f"{recipe_material.material.name}が不足しています"
        
        return True, "合成可能です"
    
    def get_required_materials(self):
        """必要素材のリストを取得"""
        return [
            {
                "material_id": rm.material_id,
                "material_name": rm.material.name,
                "quantity": rm.quantity
            }
            for rm in self.materials
        ]
