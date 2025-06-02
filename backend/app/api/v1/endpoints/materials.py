from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session, joinedload
from datetime import datetime
from typing import Optional, List
from uuid import UUID
import uuid

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.models import Player, MaterialMaster, RarityLevel, PlayerMaterial
from app.schemas import (
    MaterialMasterListResponse, MaterialMasterResponse,
    PlayerMaterialListResponse, PlayerMaterialResponse,
    MaterialAddRequest, MaterialRemoveRequest, MaterialSellRequest,
    MaterialOperationResponse, MaterialSellResponse,
    MaterialOperationResult, MaterialSellResult,
    MaterialMasterCreate, MaterialMasterUpdate,
    BaseResponse
)

router = APIRouter()

# 管理画面用の認証不要エンドポイント
@router.get("/admin/list", response_model=MaterialMasterListResponse)
async def get_materials_admin(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    min_price: Optional[int] = Query(None, description="最小価格"),
    max_price: Optional[int] = Query(None, description="最大価格"),
    db: Session = Depends(get_db)
):
    """
    管理画面用：素材マスター一覧を取得（認証不要）
    """
    query = db.query(MaterialMaster).options(
        joinedload(MaterialMaster.rarity)
    ).filter(MaterialMaster.is_active == True)
    
    # フィルター適用
    if rarity_id:
        query = query.filter(MaterialMaster.rarity_id == rarity_id)
    if min_price:
        query = query.filter(MaterialMaster.base_price >= min_price)
    if max_price:
        query = query.filter(MaterialMaster.base_price <= max_price)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    materials = query.offset(offset).limit(limit).all()
    
    return MaterialMasterListResponse(
        success=True,
        data=materials,
        message="素材一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.post("/admin/create", response_model=MaterialMasterResponse)
async def create_material_admin(
    material_data: MaterialMasterCreate,
    db: Session = Depends(get_db)
):
    """
    管理画面用：素材マスターを作成（認証不要）
    """
    # レアリティの存在確認
    rarity = db.query(RarityLevel).filter(
        RarityLevel.id == material_data.rarity_id,
        RarityLevel.is_active == True
    ).first()
    
    if not rarity:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="レアリティが見つかりません"
        )
    
    # 素材マスター作成
    material_master = MaterialMaster(
        name=material_data.name,
        description=material_data.description,
        rarity_id=material_data.rarity_id,
        base_price=material_data.base_price,
        max_stack=material_data.max_stack,
        image_url=material_data.image_url
    )
    
    db.add(material_master)
    db.commit()
    db.refresh(material_master)
    
    # リレーションシップをロード
    material_master = db.query(MaterialMaster).options(
        joinedload(MaterialMaster.rarity)
    ).filter(MaterialMaster.id == material_master.id).first()
    
    return MaterialMasterResponse(
        success=True,
        data=material_master,
        message="素材を作成しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/admin/{material_id}", response_model=MaterialMasterResponse)
async def update_material_admin(
    material_id: int,
    material_data: MaterialMasterUpdate,
    db: Session = Depends(get_db)
):
    """
    管理画面用：素材マスターを更新（認証不要）
    """
    # 素材マスターの存在確認
    material_master = db.query(MaterialMaster).filter(
        MaterialMaster.id == material_id,
        MaterialMaster.is_active == True
    ).first()
    
    if not material_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="素材が見つかりません"
        )
    
    # レアリティの存在確認（変更される場合）
    if material_data.rarity_id:
        rarity = db.query(RarityLevel).filter(
            RarityLevel.id == material_data.rarity_id,
            RarityLevel.is_active == True
        ).first()
        
        if not rarity:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="レアリティが見つかりません"
            )
    
    # 素材マスター更新
    for field, value in material_data.dict(exclude_unset=True).items():
        setattr(material_master, field, value)
    
    material_master.updated_at = datetime.utcnow()
    
    db.commit()
    db.refresh(material_master)
    
    # リレーションシップをロード
    material_master = db.query(MaterialMaster).options(
        joinedload(MaterialMaster.rarity)
    ).filter(MaterialMaster.id == material_master.id).first()
    
    return MaterialMasterResponse(
        success=True,
        data=material_master,
        message="素材を更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.delete("/admin/{material_id}", response_model=BaseResponse[dict])
async def delete_material_admin(
    material_id: int,
    db: Session = Depends(get_db)
):
    """
    管理画面用：素材マスターを削除（認証不要）
    """
    # 素材マスターの存在確認
    material_master = db.query(MaterialMaster).filter(
        MaterialMaster.id == material_id,
        MaterialMaster.is_active == True
    ).first()
    
    if not material_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="素材が見つかりません"
        )
    
    # 論理削除（is_activeをFalseに設定）
    material_master.is_active = False
    material_master.updated_at = datetime.utcnow()
    
    db.commit()
    
    return BaseResponse(
        success=True,
        data={"deleted_material_id": material_id},
        message="素材を削除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/", response_model=MaterialMasterListResponse)
async def get_materials(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりのアイテム数"),
    rarity_id: Optional[int] = Query(None, description="レアリティIDフィルター"),
    min_price: Optional[int] = Query(None, description="最小価格"),
    max_price: Optional[int] = Query(None, description="最大価格"),
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    素材マスター一覧を取得
    """
    query = db.query(MaterialMaster).options(
        joinedload(MaterialMaster.rarity)
    ).filter(MaterialMaster.is_active == True)
    
    # フィルター適用
    if rarity_id:
        query = query.filter(MaterialMaster.rarity_id == rarity_id)
    if min_price:
        query = query.filter(MaterialMaster.base_price >= min_price)
    if max_price:
        query = query.filter(MaterialMaster.base_price <= max_price)
    
    # ページネーション
    total = query.count()
    offset = (page - 1) * limit
    materials = query.offset(offset).limit(limit).all()
    
    return MaterialMasterListResponse(
        success=True,
        data=materials,
        message="素材一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4()),
        pagination={
            "page": page,
            "limit": limit,
            "total": total,
            "pages": (total + limit - 1) // limit
        }
    )

@router.get("/{material_id}", response_model=MaterialMasterResponse)
async def get_material_detail(
    material_id: int,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    素材詳細を取得
    """
    material = db.query(MaterialMaster).options(
        joinedload(MaterialMaster.rarity)
    ).filter(
        MaterialMaster.id == material_id,
        MaterialMaster.is_active == True
    ).first()
    
    if not material:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="素材が見つかりません"
        )
    
    return MaterialMasterResponse(
        success=True,
        data=material,
        message="素材詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/player/inventory", response_model=PlayerMaterialListResponse)
async def get_player_materials(
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤーの所持素材一覧を取得
    """
    player_materials = db.query(PlayerMaterial).options(
        joinedload(PlayerMaterial.material).joinedload(MaterialMaster.rarity)
    ).filter(
        PlayerMaterial.player_id == current_player.id,
        PlayerMaterial.quantity > 0
    ).all()
    
    return PlayerMaterialListResponse(
        success=True,
        data=player_materials,
        message="所持素材一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/player/add", response_model=MaterialOperationResponse)
async def add_player_material(
    material_data: MaterialAddRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤー素材を追加（ドロップ・購入時に使用）
    """
    # 素材マスターの存在確認
    material_master = db.query(MaterialMaster).filter(
        MaterialMaster.id == material_data.material_id,
        MaterialMaster.is_active == True
    ).first()
    
    if not material_master:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="素材マスターが見つかりません"
        )
    
    # プレイヤー素材の取得または作成
    player_material = db.query(PlayerMaterial).filter(
        PlayerMaterial.player_id == current_player.id,
        PlayerMaterial.material_id == material_data.material_id
    ).first()
    
    if not player_material:
        player_material = PlayerMaterial(
            player_id=current_player.id,
            material_id=material_data.material_id,
            quantity=0
        )
        db.add(player_material)
    
    # 素材追加（スタック上限チェック）
    added_quantity = player_material.add_quantity(material_data.quantity)
    
    if added_quantity == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="スタック上限に達しているため追加できません"
        )
    
    db.commit()
    db.refresh(player_material)
    
    result = MaterialOperationResult(
        success=True,
        new_quantity=player_material.quantity,
        message=f"{material_master.name}を{added_quantity}個追加しました"
    )
    
    return MaterialOperationResponse(
        success=True,
        data=result,
        message="素材を追加しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/player/remove", response_model=MaterialOperationResponse)
async def remove_player_material(
    material_data: MaterialRemoveRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤー素材を消費（合成時に使用）
    """
    player_material = db.query(PlayerMaterial).options(
        joinedload(PlayerMaterial.material)
    ).filter(
        PlayerMaterial.player_id == current_player.id,
        PlayerMaterial.material_id == material_data.material_id
    ).first()
    
    if not player_material:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="素材を所持していません"
        )
    
    if not player_material.can_remove(material_data.quantity):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"素材が不足しています（所持数: {player_material.quantity}）"
        )
    
    # 素材消費
    player_material.remove_quantity(material_data.quantity)
    
    db.commit()
    db.refresh(player_material)
    
    result = MaterialOperationResult(
        success=True,
        new_quantity=player_material.quantity,
        message=f"{player_material.material.name}を{material_data.quantity}個消費しました"
    )
    
    return MaterialOperationResponse(
        success=True,
        data=result,
        message="素材を消費しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/player/sell", response_model=MaterialSellResponse)
async def sell_player_material(
    sell_data: MaterialSellRequest,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤー素材を売却
    """
    player_material = db.query(PlayerMaterial).options(
        joinedload(PlayerMaterial.material).joinedload(MaterialMaster.rarity)
    ).filter(
        PlayerMaterial.player_id == current_player.id,
        PlayerMaterial.material_id == sell_data.material_id
    ).first()
    
    if not player_material:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="素材を所持していません"
        )
    
    if not player_material.can_remove(sell_data.quantity):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"素材が不足しています（所持数: {player_material.quantity}）"
        )
    
    # 売却価格計算（基本価格の80%）
    unit_price = int(player_material.material.calculated_price * 0.8)
    total_gold = unit_price * sell_data.quantity
    
    # 素材消費とゴールド追加
    player_material.remove_quantity(sell_data.quantity)
    current_player.add_gold(total_gold)
    
    db.commit()
    
    result = MaterialSellResult(
        success=True,
        sold_quantity=sell_data.quantity,
        gold_earned=total_gold,
        new_quantity=player_material.quantity,
        message=f"{player_material.material.name}を{sell_data.quantity}個売却しました（{total_gold}G獲得）"
    )
    
    return MaterialSellResponse(
        success=True,
        data=result,
        message="素材を売却しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/player/inventory/{material_id}", response_model=PlayerMaterialResponse)
async def get_player_material_detail(
    material_id: int,
    current_player: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """
    プレイヤーの特定素材詳細を取得
    """
    player_material = db.query(PlayerMaterial).options(
        joinedload(PlayerMaterial.material).joinedload(MaterialMaster.rarity)
    ).filter(
        PlayerMaterial.player_id == current_player.id,
        PlayerMaterial.material_id == material_id
    ).first()
    
    if not player_material:
        # 素材を所持していない場合は0個として扱う
        material_master = db.query(MaterialMaster).filter(
            MaterialMaster.id == material_id,
            MaterialMaster.is_active == True
        ).first()
        
        if not material_master:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="素材が見つかりません"
            )
        
        # 0個の素材データを作成
        player_material = PlayerMaterial(
            player_id=current_player.id,
            material_id=material_id,
            quantity=0
        )
        player_material.material = material_master
    
    return PlayerMaterialResponse(
        success=True,
        data=player_material,
        message="素材詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )
