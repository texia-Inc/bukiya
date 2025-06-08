from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional
import uuid

from app.core.database import get_db
from app.models.adventurer_master import MonsterMaster
from app.schemas.adventurer import (
    MonsterMaster as MonsterMasterSchema,
    MonsterMasterCreate, MonsterMasterUpdate
)
from app.schemas.common import BaseResponse, PaginatedResponse

router = APIRouter()

@router.get("/", response_model=PaginatedResponse[MonsterMasterSchema])
async def get_monsters(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    monster_type: Optional[str] = Query(None, description="モンスタータイプフィルター"),
    level_min: Optional[int] = Query(None, ge=1, description="最小レベル"),
    level_max: Optional[int] = Query(None, ge=1, description="最大レベル"),
    db: Session = Depends(get_db)
):
    """
    モンスター一覧を取得
    """
    query = db.query(MonsterMaster).filter(MonsterMaster.is_active == True)
    
    # フィルター適用
    if monster_type:
        query = query.filter(MonsterMaster.monster_type == monster_type)
    if level_min:
        query = query.filter(MonsterMaster.level >= level_min)
    if level_max:
        query = query.filter(MonsterMaster.level <= level_max)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    monsters = query.offset(offset).limit(limit).all()
    
    return PaginatedResponse(
        success=True,
        data=monsters,
        message="モンスター一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.get("/{monster_id}", response_model=BaseResponse[MonsterMasterSchema])
async def get_monster_detail(
    monster_id: int,
    db: Session = Depends(get_db)
):
    """
    モンスター詳細を取得
    """
    monster = db.query(MonsterMaster).filter(
        MonsterMaster.id == monster_id,
        MonsterMaster.is_active == True
    ).first()
    
    if not monster:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="モンスターが見つかりません"
        )
    
    return BaseResponse(
        success=True,
        data=monster,
        message="モンスター詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/", response_model=BaseResponse[MonsterMasterSchema])
async def create_monster(
    monster_data: MonsterMasterCreate,
    db: Session = Depends(get_db)
):
    """
    モンスターを作成
    """
    monster = MonsterMaster(**monster_data.dict())
    
    db.add(monster)
    db.commit()
    db.refresh(monster)
    
    return BaseResponse(
        success=True,
        data=monster,
        message="モンスターを作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/{monster_id}", response_model=BaseResponse[MonsterMasterSchema])
async def update_monster(
    monster_id: int,
    monster_data: MonsterMasterUpdate,
    db: Session = Depends(get_db)
):
    """
    モンスターを更新
    """
    monster = db.query(MonsterMaster).filter(
        MonsterMaster.id == monster_id,
        MonsterMaster.is_active == True
    ).first()
    
    if not monster:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="モンスターが見つかりません"
        )
    
    # 更新
    for field, value in monster_data.dict(exclude_unset=True).items():
        setattr(monster, field, value)
    
    monster.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(monster)
    
    return BaseResponse(
        success=True,
        data=monster,
        message="モンスターを更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.delete("/{monster_id}", response_model=BaseResponse[dict])
async def delete_monster(
    monster_id: int,
    db: Session = Depends(get_db)
):
    """
    モンスターを削除
    """
    monster = db.query(MonsterMaster).filter(
        MonsterMaster.id == monster_id,
        MonsterMaster.is_active == True
    ).first()
    
    if not monster:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="モンスターが見つかりません"
        )
    
    # 論理削除（is_activeをFalseに設定）
    monster.is_active = False
    monster.updated_at = datetime.utcnow()
    
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"deleted_monster_id": monster_id},
        message="モンスターを削除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )