from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from datetime import datetime
from typing import List
import uuid

from app.core.database import get_db
from app.models.weapon_type import WeaponType
from app.models.rarity_level import RarityLevel
from app.schemas.common import BaseResponse
from pydantic import BaseModel

router = APIRouter()

class WeaponTypeSchema(BaseModel):
    id: str
    name: str
    description: str
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class RarityLevelSchema(BaseModel):
    id: str
    name: str
    description: str = None
    color_code: str = None
    level: int
    star_display: str = None
    attack_multiplier: float
    max_enchant_level: int
    ability_slots: int
    base_drop_rate: float
    price_multiplier: float
    is_active: bool
    created_at: datetime
    updated_at: datetime = None

    class Config:
        from_attributes = True

@router.get("/weapon-types", response_model=BaseResponse[List[WeaponTypeSchema]])
async def get_weapon_types(db: Session = Depends(get_db)):
    """
    武器タイプ一覧を取得
    """
    weapon_types = db.query(WeaponType).filter(WeaponType.is_active == True).all()
    
    return BaseResponse(
        success=True,
        data=weapon_types,
        message="武器タイプ一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/rarity-levels", response_model=BaseResponse[List[RarityLevelSchema]])
async def get_rarity_levels(db: Session = Depends(get_db)):
    """
    レアリティレベル一覧を取得
    """
    rarity_levels = db.query(RarityLevel).filter(RarityLevel.is_active == True).all()
    
    return BaseResponse(
        success=True,
        data=rarity_levels,
        message="レアリティレベル一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )