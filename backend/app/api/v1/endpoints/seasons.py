from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional
import uuid

from app.core.database import get_db
from app.models.season_master import SeasonMaster
from app.schemas.season import Season as SeasonSchema, SeasonCreate, SeasonUpdate
from app.schemas.common import BaseResponse, PaginatedResponse

router = APIRouter()


@router.get("/", response_model=PaginatedResponse[SeasonSchema])
async def get_seasons(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    search: Optional[str] = Query(None, description="シーズン名での検索"),
    is_active: Optional[bool] = Query(None, description="有効フラグフィルター"),
    db: Session = Depends(get_db)
):
    """
    シーズン一覧を取得
    """
    query = db.query(SeasonMaster)
    
    # フィルター適用
    if search:
        query = query.filter(SeasonMaster.name.contains(search))
    if is_active is not None:
        query = query.filter(SeasonMaster.is_active == is_active)
    
    # 表示順でソート
    query = query.order_by(SeasonMaster.display_order.asc(), SeasonMaster.id.asc())
    
    # ページネーション
    from sqlalchemy import func
    total = query.count()
    offset = (page - 1) * limit
    seasons = query.offset(offset).limit(limit).all()
    
    return PaginatedResponse(
        success=True,
        data=seasons,
        message="シーズン一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )


@router.get("/{season_id}", response_model=BaseResponse[SeasonSchema])
async def get_season(
    season_id: int,
    db: Session = Depends(get_db)
):
    """
    シーズン詳細を取得
    """
    season = db.query(SeasonMaster).filter(SeasonMaster.id == season_id).first()
    
    if not season:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="シーズンが見つかりません"
        )
    
    return BaseResponse(
        success=True,
        data=season,
        message="シーズン詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )


@router.post("/admin/create", response_model=BaseResponse[SeasonSchema])
async def create_season(
    season_data: SeasonCreate,
    db: Session = Depends(get_db)
):
    """
    シーズンを作成
    """
    # 同じ名前のシーズンが存在しないかチェック
    existing_season = db.query(SeasonMaster).filter(
        SeasonMaster.name == season_data.name
    ).first()
    
    if existing_season:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="同じ名前のシーズンが既に存在します"
        )
    
    # 新しいシーズンを作成
    season = SeasonMaster(**season_data.dict())
    
    db.add(season)
    db.commit()
    db.refresh(season)
    
    return BaseResponse(
        success=True,
        data=season,
        message="シーズンを作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )


@router.put("/admin/{season_id}", response_model=BaseResponse[SeasonSchema])
async def update_season(
    season_id: int,
    season_data: SeasonUpdate,
    db: Session = Depends(get_db)
):
    """
    シーズンを更新
    """
    season = db.query(SeasonMaster).filter(SeasonMaster.id == season_id).first()
    
    if not season:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="シーズンが見つかりません"
        )
    
    # 名前の重複チェック（自分以外で同じ名前がないか）
    if season_data.name and season_data.name != season.name:
        existing_season = db.query(SeasonMaster).filter(
            SeasonMaster.name == season_data.name,
            SeasonMaster.id != season_id
        ).first()
        
        if existing_season:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="同じ名前のシーズンが既に存在します"
            )
    
    # 更新
    update_data = season_data.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(season, field, value)
    
    season.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(season)
    
    return BaseResponse(
        success=True,
        data=season,
        message="シーズンを更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )


@router.delete("/admin/{season_id}", response_model=BaseResponse[dict])
async def delete_season(
    season_id: int,
    db: Session = Depends(get_db)
):
    """
    シーズンを削除（論理削除）
    """
    season = db.query(SeasonMaster).filter(SeasonMaster.id == season_id).first()
    
    if not season:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="シーズンが見つかりません"
        )
    
    # このシーズンを使用している武器があるかチェック
    from app.models.weapon_master import WeaponMaster
    weapons_using_season = db.query(WeaponMaster).filter(
        WeaponMaster.season_id == season_id,
        WeaponMaster.is_active == True
    ).count()
    
    if weapons_using_season > 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"このシーズンを使用している武器が{weapons_using_season}個あるため削除できません"
        )
    
    # 論理削除（is_activeをFalseに設定）
    season.is_active = False
    season.updated_at = datetime.utcnow()
    
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"deleted_season_id": season_id},
        message="シーズンを削除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )