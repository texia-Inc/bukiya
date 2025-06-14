from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional
import uuid

from app.core.database import get_db
from app.models.adventurer_master import MonsterMaster, MonsterDropTable
from app.models.material_master import MaterialMaster
from app.models.weapon_master import WeaponMaster
from app.schemas.adventurer import (
    MonsterMaster as MonsterMasterSchema,
    MonsterMasterCreate, MonsterMasterUpdate,
    MonsterDropTable as MonsterDropTableSchema,
    MonsterDropTableCreate, MonsterDropTableUpdate
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
    from sqlalchemy import func
    total = db.query(func.count(MonsterMaster.id)).filter(MonsterMaster.is_active == True).scalar()
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
    monster_id: str,
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
    monster_id: str,
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
    monster_id: str,
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

# モンスタードロップテーブル関連のエンドポイント

@router.get("/{monster_id}/drops", response_model=PaginatedResponse[MonsterDropTableSchema])
async def get_monster_drops(
    monster_id: str,
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    item_type: Optional[str] = Query(None, description="アイテムタイプフィルター"),
    db: Session = Depends(get_db)
):
    """
    モンスターのドロップテーブルを取得
    """
    # モンスターの存在確認
    monster = db.query(MonsterMaster).filter(
        MonsterMaster.id == monster_id,
        MonsterMaster.is_active == True
    ).first()
    
    if not monster:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="モンスターが見つかりません"
        )
    
    # JOINして関連アイテムの名前も取得
    from sqlalchemy.orm import joinedload
    
    query = db.query(MonsterDropTable).filter(
        MonsterDropTable.monster_master_id == monster_id,
        MonsterDropTable.is_active == True
    )
    
    # フィルター適用
    if item_type:
        query = query.filter(MonsterDropTable.drop_type == item_type)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    drops = query.offset(offset).limit(limit).all()
    
    # 各ドロップアイテムの名前を取得
    for drop in drops:
        if not drop.drop_target_id:
            drop.item_name = "Unknown item"
        elif drop.drop_type == 'material':
            material = db.query(MaterialMaster).filter(MaterialMaster.id == drop.drop_target_id).first()
            if material:
                drop.item_name = material.name
            else:
                drop.item_name = f"material ID:{drop.drop_target_id}"
        elif drop.drop_type == 'weapon':
            weapon = db.query(WeaponMaster).filter(WeaponMaster.id == drop.drop_target_id).first()
            if weapon:
                drop.item_name = weapon.name
            else:
                drop.item_name = f"weapon ID:{drop.drop_target_id}"
        else:
            drop.item_name = f"{drop.drop_type} ID:{drop.drop_target_id}"
    
    return PaginatedResponse(
        success=True,
        data=drops,
        message="モンスタードロップテーブルを取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.post("/{monster_id}/drops", response_model=BaseResponse[MonsterDropTableSchema])
async def create_monster_drop(
    monster_id: str,
    drop_data: MonsterDropTableCreate,
    db: Session = Depends(get_db)
):
    """
    モンスターのドロップアイテムを作成
    """
    # モンスターの存在確認
    monster = db.query(MonsterMaster).filter(
        MonsterMaster.id == monster_id,
        MonsterMaster.is_active == True
    ).first()
    
    if not monster:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="モンスターが見つかりません"
        )
    
    # ドロップデータのmonster_master_idを設定
    drop_dict = drop_data.dict()
    drop_dict["monster_master_id"] = monster_id
    
    drop = MonsterDropTable(**drop_dict)
    
    db.add(drop)
    db.commit()
    db.refresh(drop)
    
    return BaseResponse(
        success=True,
        data=drop,
        message="モンスタードロップアイテムを作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/drops/{drop_id}", response_model=BaseResponse[MonsterDropTableSchema])
async def get_monster_drop_detail(
    drop_id: int,
    db: Session = Depends(get_db)
):
    """
    モンスタードロップアイテムの詳細を取得
    """
    drop = db.query(MonsterDropTable).filter(
        MonsterDropTable.id == drop_id,
        MonsterDropTable.is_active == True
    ).first()
    
    if not drop:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="ドロップアイテムが見つかりません"
        )
    
    return BaseResponse(
        success=True,
        data=drop,
        message="ドロップアイテム詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/drops/{drop_id}", response_model=BaseResponse[MonsterDropTableSchema])
async def update_monster_drop(
    drop_id: int,
    drop_data: MonsterDropTableUpdate,
    db: Session = Depends(get_db)
):
    """
    モンスタードロップアイテムを更新
    """
    drop = db.query(MonsterDropTable).filter(
        MonsterDropTable.id == drop_id,
        MonsterDropTable.is_active == True
    ).first()
    
    if not drop:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="ドロップアイテムが見つかりません"
        )
    
    # 更新
    for field, value in drop_data.dict(exclude_unset=True).items():
        setattr(drop, field, value)
    
    db.commit()
    db.refresh(drop)
    
    return BaseResponse(
        success=True,
        data=drop,
        message="ドロップアイテムを更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.delete("/drops/{drop_id}", response_model=BaseResponse[dict])
async def delete_monster_drop(
    drop_id: int,
    db: Session = Depends(get_db)
):
    """
    モンスタードロップアイテムを削除
    """
    drop = db.query(MonsterDropTable).filter(
        MonsterDropTable.id == drop_id,
        MonsterDropTable.is_active == True
    ).first()
    
    if not drop:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="ドロップアイテムが見つかりません"
        )
    
    # 論理削除（is_activeをFalseに設定）
    drop.is_active = False
    
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"deleted_drop_id": drop_id},
        message="ドロップアイテムを削除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )