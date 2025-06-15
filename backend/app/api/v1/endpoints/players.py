from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
from typing import Optional, List
import uuid

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.core.shop_progression import ShopProgressionService
from app.schemas.common import APIResponse
from app.schemas.player import (
    PlayerResponse, 
    PlayerDetailResponse, 
    PlayerStatisticsResponse,
    PlayerUpdateRequest,
    PlayerGoldRequest,
    PlayerGemsRequest,
    PlayerAdminUpdateRequest,
    PlayerBanRequest
)
from app.models.player import Player
from app.models.player_statistics import PlayerStatistics
from app.models.player_weapon import PlayerWeapon
from app.models.player_material import PlayerMaterial
from sqlalchemy.orm import joinedload

router = APIRouter()

# 管理画面用の認証不要エンドポイント
@router.get("/admin")
async def get_players_admin_default(
    db: Session = Depends(get_db)
):
    """
    管理画面用：プレイヤー一覧を取得（認証不要）- デフォルトエンドポイント
    """
    return await get_players_admin(db)

@router.get("/admin/list")
async def get_players_admin(
    db: Session = Depends(get_db)
):
    """
    管理画面用：プレイヤー一覧を取得（認証不要）
    """
    players = db.query(Player).limit(100).all()  # 最大100件
    
    player_responses = [
        PlayerResponse(
            id=str(player.id),
            username=player.username,
            email=player.email,
            gold=player.gold,
            gems=player.gems,
            shop_level=player.shop_level,
            shop_exp=player.shop_exp,
            reputation=player.reputation,
            created_at=player.created_at,
            last_login=player.last_login,
            is_active=player.is_active
        )
        for player in players
    ]
    
    return APIResponse(
        success=True,
        data=player_responses,
        message="プレイヤー一覧を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/admin/{player_id}")
async def get_player_detail_admin(
    player_id: str,
    db: Session = Depends(get_db)
):
    """
    管理画面用：プレイヤー詳細を取得（認証不要）
    """
    try:
        player_uuid = uuid.UUID(player_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="無効なプレイヤーIDです"
        )
    
    # プレイヤー情報を取得
    player = db.query(Player).filter(Player.id == player_uuid).first()
    if not player:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="プレイヤーが見つかりません"
        )
    
    # 統計情報を取得
    statistics = db.query(PlayerStatistics).filter(
        PlayerStatistics.player_id == player.id
    ).first()
    
    # 所持武器を取得
    weapons = db.query(PlayerWeapon).options(
        joinedload(PlayerWeapon.weapon_master)
    ).filter(
        PlayerWeapon.player_id == player.id
    ).limit(10).all()
    
    # 所持素材を取得
    materials = db.query(PlayerMaterial).options(
        joinedload(PlayerMaterial.material)
    ).filter(
        PlayerMaterial.player_id == player.id
    ).limit(10).all()
    
    # レスポンス作成
    player_response = PlayerResponse(
        id=str(player.id),
        username=player.username,
        email=player.email,
        gold=player.gold,
        gems=player.gems,
        shop_level=player.shop_level,
        shop_exp=player.shop_exp,
        reputation=player.reputation,
        created_at=player.created_at,
        last_login=player.last_login,
        is_active=player.is_active
    )
    
    statistics_response = None
    if statistics:
        statistics_response = PlayerStatisticsResponse(
            player_id=str(statistics.player_id),
            total_play_time_seconds=statistics.total_play_time_seconds,
            session_count=statistics.session_count,
            last_session_duration=statistics.last_session_duration,
            total_gold_earned=statistics.total_gold_earned,
            total_gold_spent=statistics.total_gold_spent,
            total_gems_purchased=statistics.total_gems_purchased,
            total_gems_spent=statistics.total_gems_spent,
            weapons_crafted=statistics.weapons_crafted,
            enchants_attempted=statistics.enchants_attempted,
            enchants_succeeded=statistics.enchants_succeeded,
            trades_completed=statistics.trades_completed,
            expeditions_sent=statistics.expeditions_sent,
            highest_weapon_attack=statistics.highest_weapon_attack,
            highest_enchant_level=statistics.highest_enchant_level,
            max_daily_gold=statistics.max_daily_gold,
            enchant_success_rate=statistics.enchants_succeeded / statistics.enchants_attempted if statistics.enchants_attempted > 0 else 0.0,
            average_session_duration=statistics.total_play_time_seconds / statistics.session_count if statistics.session_count > 0 else 0.0,
            updated_at=statistics.updated_at
        )
    
    # 武器情報
    weapon_list = []
    for weapon in weapons:
        weapon_list.append({
            "id": str(weapon.id),
            "weapon_name": weapon.weapon_master.name,
            "attack": weapon.total_attack,
            "enchant_level": weapon.enchant_level,
            "created_at": weapon.created_at
        })
    
    # 素材情報
    material_list = []
    for material in materials:
        material_list.append({
            "id": material.material_id,
            "material_name": material.material.name,
            "quantity": material.quantity,
            "updated_at": material.updated_at
        })
    
    detail_response = {
        "player": player_response,
        "statistics": statistics_response,
        "total_weapons": player.total_weapons,
        "total_materials": player.total_materials,
        "weapons": weapon_list,
        "materials": material_list
    }
    
    return APIResponse(
        success=True,
        data=detail_response,
        message="プレイヤー詳細を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/admin/{player_id}")
async def update_player_admin(
    player_id: str,
    update_data: PlayerAdminUpdateRequest,
    db: Session = Depends(get_db)
):
    """
    管理画面用：プレイヤー情報を更新（認証不要）
    """
    try:
        player_uuid = uuid.UUID(player_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="無効なプレイヤーIDです"
        )
    
    player = db.query(Player).filter(Player.id == player_uuid).first()
    if not player:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="プレイヤーが見つかりません"
        )
    
    # 更新可能なフィールドを更新
    for field, value in update_data.dict(exclude_unset=True).items():
        if hasattr(player, field):
            setattr(player, field, value)
    
    db.commit()
    db.refresh(player)
    
    player_response = PlayerResponse(
        id=str(player.id),
        username=player.username,
        email=player.email,
        gold=player.gold,
        gems=player.gems,
        shop_level=player.shop_level,
        shop_exp=player.shop_exp,
        reputation=player.reputation,
        created_at=player.created_at,
        last_login=player.last_login,
        is_active=player.is_active
    )
    
    return APIResponse(
        success=True,
        data=player_response,
        message="プレイヤー情報を更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/admin/{player_id}/ban")
async def ban_player_admin(
    player_id: str,
    ban_data: PlayerBanRequest,
    db: Session = Depends(get_db)
):
    """
    管理画面用：プレイヤーをBANする（認証不要）
    """
    try:
        player_uuid = uuid.UUID(player_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="無効なプレイヤーIDです"
        )
    
    player = db.query(Player).filter(Player.id == player_uuid).first()
    if not player:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="プレイヤーが見つかりません"
        )
    
    # BANの実行
    player.is_active = False
    player.ban_reason = ban_data.reason
    player.banned_at = datetime.utcnow()
    player.ban_expires_at = ban_data.expires_at
    
    db.commit()
    db.refresh(player)
    
    return APIResponse(
        success=True,
        data={"player_id": player_id, "banned": True},
        message=f"プレイヤーをBANしました: {ban_data.reason}",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/admin/{player_id}/unban")
async def unban_player_admin(
    player_id: str,
    db: Session = Depends(get_db)
):
    """
    管理画面用：プレイヤーのBANを解除する（認証不要）
    """
    try:
        player_uuid = uuid.UUID(player_id)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="無効なプレイヤーIDです"
        )
    
    player = db.query(Player).filter(Player.id == player_uuid).first()
    if not player:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="プレイヤーが見つかりません"
        )
    
    # BANの解除
    player.is_active = True
    player.ban_reason = None
    player.banned_at = None
    player.ban_expires_at = None
    
    db.commit()
    db.refresh(player)
    
    return APIResponse(
        success=True,
        data={"player_id": player_id, "banned": False},
        message="プレイヤーのBANを解除しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/me", response_model=APIResponse[PlayerDetailResponse])
async def get_current_player_info(
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    現在のプレイヤー情報を取得
    """
    # 統計情報を取得
    statistics = db.query(PlayerStatistics).filter(
        PlayerStatistics.player_id == current_user.id
    ).first()
    
    # レスポンス作成
    player_response = PlayerResponse(
        id=str(current_user.id),
        username=current_user.username,
        email=current_user.email,
        gold=current_user.gold,
        gems=current_user.gems,
        shop_level=current_user.shop_level,
        shop_exp=current_user.shop_exp,
        reputation=current_user.reputation,
        created_at=current_user.created_at,
        last_login=current_user.last_login,
        is_active=current_user.is_active
    )
    
    statistics_response = None
    if statistics:
        statistics_response = PlayerStatisticsResponse(
            player_id=str(statistics.player_id),
            total_play_time_seconds=statistics.total_play_time_seconds,
            session_count=statistics.session_count,
            last_session_duration=statistics.last_session_duration,
            total_gold_earned=statistics.total_gold_earned,
            total_gold_spent=statistics.total_gold_spent,
            total_gems_purchased=statistics.total_gems_purchased,
            total_gems_spent=statistics.total_gems_spent,
            weapons_crafted=statistics.weapons_crafted,
            enchants_attempted=statistics.enchants_attempted,
            enchants_succeeded=statistics.enchants_succeeded,
            trades_completed=statistics.trades_completed,
            expeditions_sent=statistics.expeditions_sent,
            highest_weapon_attack=statistics.highest_weapon_attack,
            highest_enchant_level=statistics.highest_enchant_level,
            max_daily_gold=statistics.max_daily_gold,
            enchant_success_rate=statistics.enchants_succeeded / statistics.enchants_attempted if statistics.enchants_attempted > 0 else 0.0,
            average_session_duration=statistics.total_play_time_seconds / statistics.session_count if statistics.session_count > 0 else 0.0,
            updated_at=statistics.updated_at
        )
    
    detail_response = PlayerDetailResponse(
        player=player_response,
        statistics=statistics_response,
        total_weapons=current_user.total_weapons,
        total_materials=current_user.total_materials
    )
    
    return APIResponse(
        success=True,
        data=detail_response,
        message="プレイヤー情報を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.put("/me", response_model=APIResponse[PlayerResponse])
async def update_current_player(
    update_data: PlayerUpdateRequest,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    現在のプレイヤー情報を更新
    """
    # ユーザー名の重複チェック
    if update_data.username and update_data.username != current_user.username:
        existing_user = db.query(Player).filter(
            Player.username == update_data.username,
            Player.id != current_user.id
        ).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="このユーザー名は既に使用されています"
            )
        current_user.username = update_data.username
    
    # メールアドレスの重複チェック
    if update_data.email and update_data.email != current_user.email:
        existing_user = db.query(Player).filter(
            Player.email == update_data.email,
            Player.id != current_user.id
        ).first()
        if existing_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="このメールアドレスは既に使用されています"
            )
        current_user.email = update_data.email
    
    db.commit()
    db.refresh(current_user)
    
    player_response = PlayerResponse(
        id=str(current_user.id),
        username=current_user.username,
        email=current_user.email,
        gold=current_user.gold,
        gems=current_user.gems,
        shop_level=current_user.shop_level,
        shop_exp=current_user.shop_exp,
        reputation=current_user.reputation,
        created_at=current_user.created_at,
        last_login=current_user.last_login,
        is_active=current_user.is_active
    )
    
    return APIResponse(
        success=True,
        data=player_response,
        message="プレイヤー情報を更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/me/gold/add", response_model=APIResponse[PlayerResponse])
async def add_gold(
    request: PlayerGoldRequest,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    ゴールドを追加（デバッグ用）
    """
    current_user.add_gold(request.amount)
    
    # 統計更新
    statistics = db.query(PlayerStatistics).filter(
        PlayerStatistics.player_id == current_user.id
    ).first()
    if statistics:
        statistics.total_gold_earned += request.amount
    
    db.commit()
    db.refresh(current_user)
    
    player_response = PlayerResponse(
        id=str(current_user.id),
        username=current_user.username,
        email=current_user.email,
        gold=current_user.gold,
        gems=current_user.gems,
        shop_level=current_user.shop_level,
        shop_exp=current_user.shop_exp,
        reputation=current_user.reputation,
        created_at=current_user.created_at,
        last_login=current_user.last_login,
        is_active=current_user.is_active
    )
    
    return APIResponse(
        success=True,
        data=player_response,
        message=f"{request.amount}ゴールドを追加しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/me/gems/add", response_model=APIResponse[PlayerResponse])
async def add_gems(
    request: PlayerGemsRequest,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    ジェムを追加（デバッグ用）
    """
    current_user.add_gems(request.amount)
    
    # 統計更新
    statistics = db.query(PlayerStatistics).filter(
        PlayerStatistics.player_id == current_user.id
    ).first()
    if statistics:
        statistics.total_gems_purchased += request.amount
    
    db.commit()
    db.refresh(current_user)
    
    player_response = PlayerResponse(
        id=str(current_user.id),
        username=current_user.username,
        email=current_user.email,
        gold=current_user.gold,
        gems=current_user.gems,
        shop_level=current_user.shop_level,
        shop_exp=current_user.shop_exp,
        reputation=current_user.reputation,
        created_at=current_user.created_at,
        last_login=current_user.last_login,
        is_active=current_user.is_active
    )
    
    return APIResponse(
        success=True,
        data=player_response,
        message=f"{request.amount}ジェムを追加しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/me/statistics", response_model=APIResponse[PlayerStatisticsResponse])
async def get_player_statistics(
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    プレイヤー統計情報を取得
    """
    statistics = db.query(PlayerStatistics).filter(
        PlayerStatistics.player_id == current_user.id
    ).first()
    
    if not statistics:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="統計情報が見つかりません"
        )
    
    statistics_response = PlayerStatisticsResponse(
        player_id=str(statistics.player_id),
        total_play_time_seconds=statistics.total_play_time_seconds,
        session_count=statistics.session_count,
        last_session_duration=statistics.last_session_duration,
        total_gold_earned=statistics.total_gold_earned,
        total_gold_spent=statistics.total_gold_spent,
        total_gems_purchased=statistics.total_gems_purchased,
        total_gems_spent=statistics.total_gems_spent,
        weapons_crafted=statistics.weapons_crafted,
        enchants_attempted=statistics.enchants_attempted,
        enchants_succeeded=statistics.enchants_succeeded,
        trades_completed=statistics.trades_completed,
        expeditions_sent=statistics.expeditions_sent,
        highest_weapon_attack=statistics.highest_weapon_attack,
        highest_enchant_level=statistics.highest_enchant_level,
        max_daily_gold=statistics.max_daily_gold,
        enchant_success_rate=statistics.enchant_success_rate,
        average_session_duration=statistics.average_session_duration,
        updated_at=statistics.updated_at
    )
    
    return APIResponse(
        success=True,
        data=statistics_response,
        message="統計情報を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.get("/shop-progression")
async def get_shop_progression(
    player_id: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    ショップレベル進行情報を取得
    
    管理画面用：player_idを指定可能
    ゲーム用：認証されたプレイヤーの情報を取得
    """
    if player_id:
        # 管理画面用（player_id指定）
        player = db.query(Player).filter(Player.id == player_id).first()
        if not player:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="プレイヤーが見つかりません"
            )
    else:
        # ゲーム用（認証必要）
        from app.core.dependencies import get_current_player
        player = Depends(get_current_player)
    
    progression_info = ShopProgressionService.get_progression_info(player)
    
    return APIResponse(
        success=True,
        data=progression_info,
        message="ショップ進行情報を取得しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )
