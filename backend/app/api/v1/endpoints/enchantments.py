from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import random
import math

from app.core.database import get_db
from app.core.dependencies import get_current_player
from app.models.player import Player
from app.models.enchantment import (
    EnchantmentType, WeaponEnchantment, EnchantmentLog, 
    EnchantmentMaterial, PlayerEnchantmentMaterial
)
from app.models.player_weapon import PlayerWeapon
from app.schemas import enchantment as schemas
from app.schemas.enchantment import (
    EnchantmentListResponse, EnchantmentRequest, EnchantmentResponse,
    EnchantmentStats, EnchantmentResult, EnchantmentType as EnchantmentTypeSchema,
    EnchantmentMaterial as EnchantmentMaterialSchema,
    PlayerEnchantmentMaterial as PlayerEnchantmentMaterialSchema,
    EnchantmentLog as EnchantmentLogSchema
)
from app.schemas.common import BaseResponse

router = APIRouter()

@router.get("/", response_model=BaseResponse[EnchantmentListResponse])
async def get_enchantments(
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """エンチャント一覧を取得"""
    try:
        # エンチャントタイプ一覧
        enchantment_types = db.query(EnchantmentType).filter(
            EnchantmentType.is_active == True
        ).all()
        
        # エンチャント素材一覧
        materials = db.query(EnchantmentMaterial).filter(
            EnchantmentMaterial.is_active == True
        ).all()
        
        # プレイヤーの所持素材
        player_materials = db.query(PlayerEnchantmentMaterial).filter(
            PlayerEnchantmentMaterial.player_id == current_player.id,
            PlayerEnchantmentMaterial.quantity > 0
        ).all()
        
        # エンチャント統計
        enchantment_logs = db.query(EnchantmentLog).filter(
            EnchantmentLog.player_id == current_player.id
        ).all()
        
        total_enchantments = len(enchantment_logs)
        success_count = len([log for log in enchantment_logs if log.result == EnchantmentResult.SUCCESS])
        failure_count = len([log for log in enchantment_logs if log.result == EnchantmentResult.FAILURE])
        destroy_count = len([log for log in enchantment_logs if log.result == EnchantmentResult.DESTROY])
        success_rate = success_count / total_enchantments if total_enchantments > 0 else 0.0
        total_cost = sum(log.cost for log in enchantment_logs)
        
        # 平均レベル計算
        weapon_enchantments = db.query(WeaponEnchantment).join(PlayerWeapon).filter(
            PlayerWeapon.player_id == current_player.id
        ).all()
        average_level = sum(we.level for we in weapon_enchantments) / len(weapon_enchantments) if weapon_enchantments else 0.0
        
        stats = EnchantmentStats(
            total_enchantments=total_enchantments,
            success_count=success_count,
            failure_count=failure_count,
            destroy_count=destroy_count,
            success_rate=success_rate,
            total_cost=total_cost,
            average_level=average_level
        )
        
        response_data = EnchantmentListResponse(
            enchantment_types=enchantment_types,
            materials=materials,
            player_materials=player_materials,
            stats=stats
        )
        
        return BaseResponse(
            success=True,
            data=response_data,
            message="エンチャント一覧を取得しました"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"エンチャント一覧の取得に失敗しました: {str(e)}")

@router.post("/enchant", response_model=BaseResponse[EnchantmentResponse])
async def enchant_weapon(
    request: EnchantmentRequest,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """武器をエンチャント"""
    try:
        # 武器の存在確認
        weapon = db.query(PlayerWeapon).filter(
            PlayerWeapon.id == request.weapon_id,
            PlayerWeapon.player_id == current_player.id
        ).first()
        
        if not weapon:
            raise HTTPException(status_code=404, detail="武器が見つかりません")
        
        # エンチャントタイプの存在確認
        enchantment_type = db.query(EnchantmentType).filter(
            EnchantmentType.id == request.enchantment_type_id,
            EnchantmentType.is_active == True
        ).first()
        
        if not enchantment_type:
            raise HTTPException(status_code=404, detail="エンチャントタイプが見つかりません")
        
        # 既存のエンチャント確認
        existing_enchantment = db.query(WeaponEnchantment).filter(
            WeaponEnchantment.weapon_id == weapon.id,
            WeaponEnchantment.enchantment_type_id == enchantment_type.id
        ).first()
        
        before_level = existing_enchantment.level if existing_enchantment else 0
        
        # 最大レベルチェック
        if before_level >= enchantment_type.max_level:
            raise HTTPException(status_code=400, detail="既に最大レベルです")
        
        # コスト計算
        level_multiplier = math.pow(1.5, before_level)
        base_cost = int(enchantment_type.base_cost * level_multiplier)
        
        # 素材ボーナス計算
        success_rate_bonus = 0.0
        cost_multiplier = 1.0
        materials_used = {}
        
        if request.use_materials:
            for material_data in request.use_materials:
                material_id = material_data.get("material_id")
                quantity = material_data.get("quantity", 1)
                
                # プレイヤーの所持確認
                player_material = db.query(PlayerEnchantmentMaterial).filter(
                    PlayerEnchantmentMaterial.player_id == current_player.id,
                    PlayerEnchantmentMaterial.material_id == material_id
                ).first()
                
                if not player_material or player_material.quantity < quantity:
                    raise HTTPException(status_code=400, detail="素材が不足しています")
                
                # 素材効果を適用
                material = db.query(EnchantmentMaterial).filter(
                    EnchantmentMaterial.id == material_id
                ).first()
                
                if material:
                    success_rate_bonus += material.success_rate_bonus * quantity
                    cost_multiplier *= material.cost_multiplier
                    materials_used[str(material_id)] = quantity
                    
                    # 素材を消費
                    player_material.quantity -= quantity
        
        final_cost = int(base_cost * cost_multiplier)
        
        # ゴールドチェック
        if current_player.gold < final_cost:
            raise HTTPException(status_code=400, detail="ゴールドが不足しています")
        
        # 成功率計算
        base_success_rate = enchantment_type.base_success_rate
        level_penalty = before_level * 0.05  # レベルが上がるごとに5%減少
        final_success_rate = min(0.95, max(0.05, base_success_rate - level_penalty + success_rate_bonus))
        
        # エンチャント実行
        random_value = random.random()
        
        if random_value <= final_success_rate:
            # 成功
            result = EnchantmentResult.SUCCESS
            after_level = before_level + 1
            message = f"エンチャントに成功しました！ +{after_level}"
            
            if existing_enchantment:
                existing_enchantment.level = after_level
                existing_enchantment.success_count += 1
                existing_enchantment.total_cost += final_cost
            else:
                new_enchantment = WeaponEnchantment(
                    weapon_id=weapon.id,
                    enchantment_type_id=enchantment_type.id,
                    level=after_level,
                    success_count=1,
                    total_cost=final_cost
                )
                db.add(new_enchantment)
                
        elif random_value <= final_success_rate + 0.1 and not request.use_protection:
            # 破壊（保護アイテム未使用時のみ）
            result = EnchantmentResult.DESTROY
            after_level = 0
            message = "エンチャントに失敗し、武器が破壊されました..."
            
            # 武器を削除
            db.delete(weapon)
            
        else:
            # 失敗
            result = EnchantmentResult.FAILURE
            after_level = before_level
            message = "エンチャントに失敗しました"
            
            if existing_enchantment:
                existing_enchantment.failure_count += 1
                existing_enchantment.total_cost += final_cost
        
        # ゴールドを消費
        current_player.gold -= final_cost
        
        # ログを記録
        enchantment_log = EnchantmentLog(
            player_id=current_player.id,
            weapon_id=weapon.id,
            enchantment_type_id=enchantment_type.id,
            before_level=before_level,
            after_level=after_level,
            result=result,
            cost=final_cost,
            materials_used=materials_used,
            success_rate=final_success_rate
        )
        db.add(enchantment_log)
        
        db.commit()
        
        response_data = EnchantmentResponse(
            result=result,
            before_level=before_level,
            after_level=after_level,
            cost=final_cost,
            success_rate=final_success_rate,
            materials_used=materials_used,
            message=message
        )
        
        return BaseResponse(
            success=True,
            data=response_data,
            message=message
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"エンチャントに失敗しました: {str(e)}")

@router.get("/history", response_model=BaseResponse[List[EnchantmentLogSchema]])
async def get_enchantment_history(
    limit: int = Query(50, ge=1, le=100, description="取得件数"),
    offset: int = Query(0, ge=0, description="オフセット"),
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """エンチャント履歴を取得"""
    try:
        logs = db.query(EnchantmentLog).filter(
            EnchantmentLog.player_id == current_player.id
        ).order_by(EnchantmentLog.created_at.desc()).offset(offset).limit(limit).all()
        
        return BaseResponse(
            success=True,
            data=logs,
            message="エンチャント履歴を取得しました"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"エンチャント履歴の取得に失敗しました: {str(e)}")

@router.get("/weapon/{weapon_id}/enchantments", response_model=BaseResponse[List[schemas.WeaponEnchantment]])
async def get_weapon_enchantments(
    weapon_id: int,
    db: Session = Depends(get_db),
    current_player: Player = Depends(get_current_player)
):
    """武器のエンチャント一覧を取得"""
    try:
        # 武器の所有確認
        weapon = db.query(PlayerWeapon).filter(
            PlayerWeapon.id == weapon_id,
            PlayerWeapon.player_id == current_player.id
        ).first()
        
        if not weapon:
            raise HTTPException(status_code=404, detail="武器が見つかりません")
        
        enchantments = db.query(WeaponEnchantment).filter(
            WeaponEnchantment.weapon_id == weapon_id
        ).all()
        
        return BaseResponse(
            success=True,
            data=enchantments,
            message="武器のエンチャント一覧を取得しました"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"武器のエンチャント一覧の取得に失敗しました: {str(e)}")

# 管理画面用エンドポイント
@router.get("/admin/types", response_model=BaseResponse[List[EnchantmentTypeSchema]])
async def admin_get_enchantment_types(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    search: Optional[str] = Query(None),
    effect_type: Optional[str] = Query(None),
    is_active: Optional[bool] = Query(None),
    db: Session = Depends(get_db)
):
    """管理画面：エンチャントタイプ一覧"""
    try:
        query = db.query(EnchantmentType)
        
        if search:
            query = query.filter(EnchantmentType.name.contains(search))
        if effect_type:
            query = query.filter(EnchantmentType.effect_type == effect_type)
        if is_active is not None:
            query = query.filter(EnchantmentType.is_active == is_active)
        
        offset = (page - 1) * limit
        enchantment_types = query.offset(offset).limit(limit).all()
        
        return BaseResponse(
            success=True,
            data=enchantment_types,
            message="エンチャントタイプ一覧を取得しました"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"エンチャントタイプ一覧の取得に失敗しました: {str(e)}")

@router.get("/admin/materials", response_model=BaseResponse[List[EnchantmentMaterialSchema]])
async def admin_get_enchantment_materials(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    search: Optional[str] = Query(None),
    rarity: Optional[str] = Query(None),
    is_active: Optional[bool] = Query(None),
    db: Session = Depends(get_db)
):
    """管理画面：エンチャント素材一覧"""
    try:
        query = db.query(EnchantmentMaterial)
        
        if search:
            query = query.filter(EnchantmentMaterial.name.contains(search))
        if rarity:
            query = query.filter(EnchantmentMaterial.rarity == rarity)
        if is_active is not None:
            query = query.filter(EnchantmentMaterial.is_active == is_active)
        
        offset = (page - 1) * limit
        materials = query.offset(offset).limit(limit).all()
        
        return BaseResponse(
            success=True,
            data=materials,
            message="エンチャント素材一覧を取得しました"
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"エンチャント素材一覧の取得に失敗しました: {str(e)}")

# エンチャントタイプのCRUD操作
@router.post("/admin/types", response_model=BaseResponse[EnchantmentTypeSchema])
async def admin_create_enchantment_type(
    enchantment_type: dict,
    db: Session = Depends(get_db)
):
    """管理画面：エンチャントタイプ作成"""
    try:
        db_enchantment_type = EnchantmentType(**enchantment_type)
        db.add(db_enchantment_type)
        db.commit()
        db.refresh(db_enchantment_type)
        
        return BaseResponse(
            success=True,
            data=db_enchantment_type,
            message="エンチャントタイプを作成しました"
        )
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"エンチャントタイプの作成に失敗しました: {str(e)}")

@router.put("/admin/types/{type_id}", response_model=BaseResponse[EnchantmentTypeSchema])
async def admin_update_enchantment_type(
    type_id: int,
    enchantment_type: dict,
    db: Session = Depends(get_db)
):
    """管理画面：エンチャントタイプ更新"""
    try:
        db_enchantment_type = db.query(EnchantmentType).filter(
            EnchantmentType.id == type_id
        ).first()
        
        if not db_enchantment_type:
            raise HTTPException(status_code=404, detail="エンチャントタイプが見つかりません")
        
        for field, value in enchantment_type.items():
            if hasattr(db_enchantment_type, field):
                setattr(db_enchantment_type, field, value)
        
        db.commit()
        db.refresh(db_enchantment_type)
        
        return BaseResponse(
            success=True,
            data=db_enchantment_type,
            message="エンチャントタイプを更新しました"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"エンチャントタイプの更新に失敗しました: {str(e)}")

@router.delete("/admin/types/{type_id}", response_model=BaseResponse[None])
async def admin_delete_enchantment_type(
    type_id: int,
    db: Session = Depends(get_db)
):
    """管理画面：エンチャントタイプ削除"""
    try:
        db_enchantment_type = db.query(EnchantmentType).filter(
            EnchantmentType.id == type_id
        ).first()
        
        if not db_enchantment_type:
            raise HTTPException(status_code=404, detail="エンチャントタイプが見つかりません")
        
        db.delete(db_enchantment_type)
        db.commit()
        
        return BaseResponse(
            success=True,
            data=None,
            message="エンチャントタイプを削除しました"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"エンチャントタイプの削除に失敗しました: {str(e)}")

# エンチャント素材のCRUD操作
@router.post("/admin/materials", response_model=BaseResponse[EnchantmentMaterialSchema])
async def admin_create_enchantment_material(
    material: dict,
    db: Session = Depends(get_db)
):
    """管理画面：エンチャント素材作成"""
    try:
        db_material = EnchantmentMaterial(**material)
        db.add(db_material)
        db.commit()
        db.refresh(db_material)
        
        return BaseResponse(
            success=True,
            data=db_material,
            message="エンチャント素材を作成しました"
        )
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"エンチャント素材の作成に失敗しました: {str(e)}")

@router.put("/admin/materials/{material_id}", response_model=BaseResponse[EnchantmentMaterialSchema])
async def admin_update_enchantment_material(
    material_id: int,
    material: dict,
    db: Session = Depends(get_db)
):
    """管理画面：エンチャント素材更新"""
    try:
        db_material = db.query(EnchantmentMaterial).filter(
            EnchantmentMaterial.id == material_id
        ).first()
        
        if not db_material:
            raise HTTPException(status_code=404, detail="エンチャント素材が見つかりません")
        
        for field, value in material.items():
            if hasattr(db_material, field):
                setattr(db_material, field, value)
        
        db.commit()
        db.refresh(db_material)
        
        return BaseResponse(
            success=True,
            data=db_material,
            message="エンチャント素材を更新しました"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"エンチャント素材の更新に失敗しました: {str(e)}")

@router.delete("/admin/materials/{material_id}", response_model=BaseResponse[None])
async def admin_delete_enchantment_material(
    material_id: int,
    db: Session = Depends(get_db)
):
    """管理画面：エンチャント素材削除"""
    try:
        db_material = db.query(EnchantmentMaterial).filter(
            EnchantmentMaterial.id == material_id
        ).first()
        
        if not db_material:
            raise HTTPException(status_code=404, detail="エンチャント素材が見つかりません")
        
        db.delete(db_material)
        db.commit()
        
        return BaseResponse(
            success=True,
            data=None,
            message="エンチャント素材を削除しました"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"エンチャント素材の削除に失敗しました: {str(e)}")
