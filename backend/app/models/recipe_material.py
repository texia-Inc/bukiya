from sqlalchemy import Column, Integer, String, ForeignKey, CheckConstraint
from sqlalchemy.orm import relationship

from app.core.database import Base

class RecipeMaterial(Base):
    __tablename__ = "recipe_materials"
    
    recipe_id = Column(Integer, ForeignKey("crafting_recipes.id", ondelete="CASCADE"), primary_key=True)
    material_id = Column(Integer, ForeignKey("material_masters.id"), primary_key=True)
    quantity = Column(Integer, nullable=False)
    
    # 制約
    __table_args__ = (
        CheckConstraint('quantity > 0', name='recipe_materials_quantity_check'),
    )
    
    # リレーションシップ
    recipe = relationship("CraftingRecipe", back_populates="materials")
    material = relationship("MaterialMaster", back_populates="recipe_materials")
    
    def __repr__(self):
        return f"<RecipeMaterial(recipe_id={self.recipe_id}, material='{self.material.name if self.material else 'Unknown'}', quantity={self.quantity})>"
