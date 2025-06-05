"""
冒険者インスタンスAPIエンドポイント
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import List, Optional
from datetime import datetime, timedelta
from uuid import UUID
import random

from ....core.dependencies import get_db, get_current_user
from ....core.security import get_password_hash
from ....models import (
    Player, AdventurerInstance, AdventurerRequest, AdventurerQuest,
    QuestReward, AdventurerPurchase, PlayerWeapon, WeaponMaster, MaterialMaster
)
from ....models.adventurer_master import AdventurerMaster, QuestAreaMaster
from ....schemas.adventurer_instance import (
    AdventurerInstance as AdventurerInstanceSchema,
    AdventurerInstanceCreate, AdventurerInstanceDetail,
    AdventurerListResponse, QuestResultResponse,
    WeaponSaleRequest, QuestDispatchRequest, BuybackRequest,
    AdventurerQuest as AdventurerQuestSchema
)

router = APIRouter()


@router.get("/visiting", response_model=AdventurerListResponse)
def get_visiting_adventurers(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """訪問中の冒険者一覧を取得"""
    # 訪問時間が過ぎた冒険者を自動的にidleに戻す
    now = datetime.utcnow()
    expired_visits = db.query(AdventurerInstance).filter(
        and_(
            AdventurerInstance.status == "visiting",
            AdventurerInstance.visit_end_time < now
        )
    ).all()
    
    for adventurer in expired_visits:
        adventurer.status = "idle"
        adventurer.visit_start_time = None
        adventurer.visit_end_time = None
    
    db.commit()
    
    # 訪問中の冒険者を取得
    query = db.query(AdventurerInstance).filter(
        AdventurerInstance.status == "visiting"
    )
    
    total = query.count()
    adventurers = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "adventurers": adventurers,
        "total": total,
        "page": page,
        "limit": limit
    }


@router.get("/on-quest", response_model=AdventurerListResponse)
def get_on_quest_adventurers(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """冒険中の冒険者一覧を取得"""
    # プレイヤーの武器を持って冒険中の冒険者を取得
    query = db.query(AdventurerInstance).join(
        AdventurerQuest,
        and_(
            AdventurerInstance.current_quest_id == AdventurerQuest.id,
            AdventurerQuest.status == "in_progress"
        )
    ).join(
        PlayerWeapon,
        AdventurerQuest.player_weapon_id == PlayerWeapon.id
    ).filter(
        PlayerWeapon.player_id == current_user.id
    )
    
    total = query.count()
    adventurers = query.offset((page - 1) * limit).limit(limit).all()
    
    return {
        "adventurers": adventurers,
        "total": total,
        "page": page,
        "limit": limit
    }


@router.get("/buybacks", response_model=QuestResultResponse)
def get_pending_buybacks(
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """買取待ちのクエスト結果一覧を取得"""
    now = datetime.utcnow()
    
    # 買取期限内のクエスト結果を取得
    quests = db.query(AdventurerQuest).join(
        QuestReward
    ).join(
        AdventurerInstance
    ).join(
        PlayerWeapon,
        AdventurerQuest.player_weapon_id == PlayerWeapon.id
    ).filter(
        and_(
            PlayerWeapon.player_id == current_user.id,
            AdventurerQuest.status == "completed",
            QuestReward.is_bought == False,
            QuestReward.buyback_deadline > now
        )
    ).distinct().all()
    
    return {
        "results": quests,
        "total": len(quests)
    }


@router.get("/quest-areas")
def get_quest_areas(
    db: Session = Depends(get_db)
):
    """クエストエリア一覧を取得"""
    areas = db.query(QuestAreaMaster).filter(
        QuestAreaMaster.is_active == True
    ).all()
    
    return {"areas": areas}


@router.post("/{adventurer_id}/sell")
def sell_weapon_to_adventurer(
    adventurer_id: UUID,
    request: WeaponSaleRequest,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """冒険者に武器を販売"""
    # 冒険者の確認
    adventurer = db.query(AdventurerInstance).filter(
        AdventurerInstance.id == adventurer_id
    ).first()
    
    if not adventurer:
        raise HTTPException(status_code=404, detail="冒険者が見つかりません")
    
    if adventurer.status != "visiting":
        raise HTTPException(status_code=400, detail="この冒険者は訪問中ではありません")
    
    # プレイヤーの武器確認
    player_weapon = db.query(PlayerWeapon).filter(
        and_(
            PlayerWeapon.id == request.weapon_id,
            PlayerWeapon.player_id == current_user.id
        )
    ).first()
    
    if not player_weapon:
        raise HTTPException(status_code=404, detail="武器が見つかりません")
    
    # 冒険者の予算確認
    adventurer_budget = adventurer.adventurer_master.budget_max
    if request.price > adventurer_budget:
        raise HTTPException(status_code=400, detail="冒険者の予算を超えています")
    
    # 購入記録を作成
    purchase = AdventurerPurchase(
        adventurer_instance_id=adventurer_id,
        player_weapon_id=request.weapon_id,
        price=request.price
    )
    db.add(purchase)
    
    # プレイヤーにゴールドを追加
    current_user.gold += request.price
    
    # 武器の所有者を変更（冒険者が持って行く）
    player_weapon.player_id = None
    
    # 冒険者の信頼度を上げる
    adventurer.trust_level = min(100, adventurer.trust_level + 5)
    
    # 冒険者を帰らせる
    adventurer.status = "idle"
    adventurer.visit_start_time = None
    adventurer.visit_end_time = None
    
    db.commit()
    
    return {"message": "武器を販売しました", "gold_earned": request.price}


@router.post("/{adventurer_id}/quest")
def send_adventurer_on_quest(
    adventurer_id: UUID,
    request: QuestDispatchRequest,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """冒険者をクエストに派遣"""
    # 冒険者の確認
    adventurer = db.query(AdventurerInstance).filter(
        AdventurerInstance.id == adventurer_id
    ).first()
    
    if not adventurer:
        raise HTTPException(status_code=404, detail="冒険者が見つかりません")
    
    if adventurer.status != "visiting":
        raise HTTPException(status_code=400, detail="この冒険者は訪問中ではありません")
    
    # クエストエリアの確認
    quest_area = db.query(QuestAreaMaster).filter(
        QuestAreaMaster.id == request.quest_area_id
    ).first()
    
    if not quest_area:
        raise HTTPException(status_code=404, detail="クエストエリアが見つかりません")
    
    # レベル要件の確認
    if adventurer.level < quest_area.required_level:
        raise HTTPException(status_code=400, detail="冒険者のレベルが不足しています")
    
    # クエストを作成
    quest = AdventurerQuest(
        adventurer_instance_id=adventurer_id,
        quest_area_id=request.quest_area_id,
        status="in_progress",
        start_time=datetime.utcnow(),
        end_time=datetime.utcnow() + timedelta(minutes=quest_area.duration_minutes)
    )
    db.add(quest)
    db.flush()
    
    # 冒険者のステータスを更新
    adventurer.status = "on_quest"
    adventurer.current_quest_id = quest.id
    adventurer.visit_start_time = None
    adventurer.visit_end_time = None
    
    db.commit()
    
    return {"message": "冒険者を派遣しました", "quest_id": quest.id}


@router.post("/buyback")
def buyback_items(
    request: BuybackRequest,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """クエスト報酬を買い取る"""
    # クエスト結果の確認
    quest = db.query(AdventurerQuest).filter(
        AdventurerQuest.id == request.quest_result_id
    ).first()
    
    if not quest:
        raise HTTPException(status_code=404, detail="クエスト結果が見つかりません")
    
    # 報酬の確認と合計価格計算
    total_price = 0
    rewards_to_buy = []
    
    for item_id in request.item_ids:
        reward = db.query(QuestReward).filter(
            and_(
                QuestReward.id == item_id,
                QuestReward.adventurer_quest_id == quest.id,
                QuestReward.is_bought == False
            )
        ).first()
        
        if not reward:
            raise HTTPException(status_code=404, detail=f"報酬アイテム {item_id} が見つかりません")
        
        if reward.buyback_deadline < datetime.utcnow():
            raise HTTPException(status_code=400, detail="買取期限が過ぎています")
        
        total_price += reward.buyback_price
        rewards_to_buy.append(reward)
    
    # プレイヤーのゴールド確認
    if current_user.gold < total_price:
        raise HTTPException(status_code=400, detail="ゴールドが不足しています")
    
    # 買取処理
    current_user.gold -= total_price
    
    for reward in rewards_to_buy:
        reward.is_bought = True
        
        # プレイヤーのインベントリに追加
        if reward.item_type == "material":
            # 素材の場合
            from ....models import PlayerMaterial
            player_material = db.query(PlayerMaterial).filter(
                and_(
                    PlayerMaterial.player_id == current_user.id,
                    PlayerMaterial.material_id == reward.item_id
                )
            ).first()
            
            if player_material:
                player_material.quantity += reward.quantity
            else:
                player_material = PlayerMaterial(
                    player_id=current_user.id,
                    material_id=reward.item_id,
                    quantity=reward.quantity
                )
                db.add(player_material)
    
    db.commit()
    
    return {"message": "アイテムを買い取りました", "total_cost": total_price}


@router.delete("/buyback/{quest_result_id}")
def reject_buyback(
    quest_result_id: UUID,
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """買取を拒否"""
    # クエスト結果の確認
    quest = db.query(AdventurerQuest).filter(
        AdventurerQuest.id == quest_result_id
    ).first()
    
    if not quest:
        raise HTTPException(status_code=404, detail="クエスト結果が見つかりません")
    
    # 報酬を全て拒否済みにする
    db.query(QuestReward).filter(
        QuestReward.adventurer_quest_id == quest_result_id
    ).update({"is_bought": True})
    
    db.commit()
    
    return {"message": "買取を拒否しました"}


@router.post("/spawn-visitors")
def spawn_visiting_adventurers(
    current_user: Player = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """訪問者を生成（デバッグ用）"""
    # アクティブな冒険者マスターを取得
    masters = db.query(AdventurerMaster).filter(
        AdventurerMaster.is_active == True
    ).all()
    
    if not masters:
        raise HTTPException(status_code=404, detail="冒険者マスターが登録されていません")
    
    # ランダムに1-3人の冒険者を生成
    num_visitors = random.randint(1, min(3, len(masters)))
    selected_masters = random.sample(masters, num_visitors)
    
    now = datetime.utcnow()
    created_adventurers = []
    
    for master in selected_masters:
        # 冒険者インスタンスを作成
        adventurer = AdventurerInstance(
            adventurer_master_id=int(master.id),
            name=f"{master.name}_{random.randint(1, 999)}",
            level=random.randint(master.min_player_level, min(master.min_player_level + 10, 50)),
            trust_level=random.randint(0, 50),
            status="visiting",
            visit_start_time=now,
            visit_end_time=now + timedelta(minutes=random.randint(30, 120))
        )
        db.add(adventurer)
        db.flush()
        
        # 武器リクエストを作成
        request = AdventurerRequest(
            adventurer_instance_id=adventurer.id,
            weapon_type=random.choice(["sword", "axe", "bow", "staff", "dagger"]),
            min_attack=adventurer.level * 10,
            max_budget=master.budget_max,
            preferred_rarity=random.choice(["common", "rare", "epic"]),
            urgency=random.randint(1, 5),
            description=f"{master.personality}な冒険者からのリクエスト",
            deadline=now + timedelta(hours=random.randint(2, 24))
        )
        db.add(request)
        
        created_adventurers.append(adventurer)
    
    db.commit()
    
    return {
        "message": f"{len(created_adventurers)}人の冒険者が訪問しました",
        "adventurers": [a.id for a in created_adventurers]
    }