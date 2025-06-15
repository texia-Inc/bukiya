"""
冒険者インスタンスAPIエンドポイント
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import and_, or_
from typing import List, Optional
from datetime import datetime, timedelta, timezone
from uuid import UUID
import random
from pydantic import BaseModel

from app.core.dependencies import get_db, get_current_player
from app.core.security import get_password_hash
from app.models import (
    Player, AdventurerInstance, AdventurerRequest, AdventurerQuest,
    QuestReward, AdventurerPurchase, PlayerWeapon, WeaponMaster, MaterialMaster,
    PlayerMaterial, AdventurerCharacter, PlayerCharacterBond
)
from app.models.adventurer_master import AdventurerMaster, QuestAreaMaster
from app.schemas.adventurer_instance import (
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
    current_user: Player = Depends(get_current_player),
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


@router.get("/on-quest/test")  
def get_on_quest_adventurers_test(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    db: Session = Depends(get_db)
):
    """冒険中の冒険者一覧をテスト用に取得（認証不要）"""
    # 実際のデータ構造に合わせたテストデータを返す
    adventurers = []
    return {
        "success": True,
        "adventurers": adventurers,
        "total": 0,
        "page": page,
        "limit": limit
    }

# 認証不要版のエンドポイントを追加
@router.get("/on-quest-noauth")
def get_on_quest_adventurers_no_auth(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100), 
    db: Session = Depends(get_db)
):
    """冒険中の冒険者一覧を取得（認証不要）"""
    try:
        # 実際のデータベースクエリを実行（認証なし）
        adventurers_with_quests = db.query(
            AdventurerInstance,
            AdventurerQuest,
            PlayerWeapon,
            WeaponMaster,
            QuestAreaMaster
        ).join(
            AdventurerQuest,
            and_(
                AdventurerInstance.current_quest_id == AdventurerQuest.id,
                AdventurerQuest.status == "in_progress"
            )
        ).join(
            PlayerWeapon,
            AdventurerQuest.player_weapon_id == PlayerWeapon.id
        ).join(
            WeaponMaster,
            PlayerWeapon.weapon_master_id == WeaponMaster.id
        ).join(
            QuestAreaMaster,
            AdventurerQuest.quest_area_id == QuestAreaMaster.id
        ).limit(limit).all()

        # 詳細情報を含む結果を構築
        detailed_adventurers = []
        from datetime import timezone
        current_time = datetime.now(timezone.utc)
        
        for adventurer, quest, weapon, weapon_master, quest_area in adventurers_with_quests:
            # 進捗計算
            total_duration = (quest.end_time - quest.start_time).total_seconds()
            elapsed_time = (current_time - quest.start_time).total_seconds()
            progress_percentage = min(100, max(0, (elapsed_time / total_duration) * 100))
            
            # 残り時間計算
            remaining_seconds = max(0, (quest.end_time - current_time).total_seconds())
            remaining_minutes = int(remaining_seconds / 60)
            remaining_hours = int(remaining_minutes / 60)
            remaining_minutes = remaining_minutes % 60
            
            # クエスト完了判定
            is_completed = current_time >= quest.end_time
            
            # クエストが完了した場合、ステータスを更新して買取待ちに移動
            if is_completed and quest.status == "in_progress":
                quest.status = "completed"
                adventurer.status = "returning"
                adventurer.current_quest_id = None
                
                # 報酬を生成（簡単な例）
                from ....models import QuestReward
                import uuid
                
                # ゴールド報酬
                gold_reward = QuestReward(
                    adventurer_quest_id=quest.id,
                    item_type="gold",
                    item_id="gold",
                    quantity=weapon.attack * 2,  # 攻撃力の2倍のゴールド
                    buyback_price=weapon.attack * 2,
                    buyback_deadline=current_time + timedelta(hours=24),
                    is_bought=False
                )
                db.add(gold_reward)
                
                # 素材報酬（ランダム）
                material_reward = QuestReward(
                    adventurer_quest_id=quest.id,
                    item_type="material", 
                    item_id="1",  # 基本的な素材ID
                    quantity=random.randint(1, 3),
                    buyback_price=50,
                    buyback_deadline=current_time + timedelta(hours=24),
                    is_bought=False
                )
                db.add(material_reward)
                
                db.commit()
                continue  # 完了したクエストは冒険中リストから除外
            
            detailed_adventurer = {
                "id": str(adventurer.id),
                "name": adventurer.name,
                "level": adventurer.level,
                "trust_level": adventurer.trust_level,
                "status": "completed" if is_completed else "on_quest",
                "adventurer_master": {
                    "name": adventurer.adventurer_master.name if adventurer.adventurer_master else "Unknown",
                    "profession": adventurer.adventurer_master.profession if adventurer.adventurer_master else "unknown",
                    "personality": adventurer.adventurer_master.personality if adventurer.adventurer_master else "normal",
                },
                "current_quest": {
                    "id": str(quest.id),
                    "status": quest.status,
                    "start_time": quest.start_time.isoformat(),
                    "end_time": quest.end_time.isoformat(),
                    "progress_percentage": round(progress_percentage, 1),
                    "remaining_time": {
                        "hours": remaining_hours,
                        "minutes": remaining_minutes,
                        "total_minutes": int(remaining_seconds / 60)
                    },
                    "is_completed": is_completed,
                    "quest_area": {
                        "id": quest_area.id,
                        "name": quest_area.name,
                        "area_type": quest_area.area_type,
                        "difficulty": quest_area.difficulty,
                        "duration_minutes": quest_area.duration_minutes,
                        "description": quest_area.description,
                        "background_color": quest_area.background_color
                    },
                    "weapon_used": {
                        "id": str(weapon.id),
                        "name": weapon_master.name,
                        "attack": weapon.attack,
                        "enchant_level": weapon.enchant_level,
                        "weapon_type": weapon_master.weapon_type_id,
                        "display_name": weapon.custom_name or weapon_master.name
                    }
                }
            }
            detailed_adventurers.append(detailed_adventurer)

        return {
            "success": True,
            "adventurers": detailed_adventurers,
            "total": len(adventurers_with_quests),
            "page": page,
            "limit": limit
        }
    except Exception as e:
        print(f"ERROR in on-quest-noauth: {e}")
        return {
            "success": True,
            "adventurers": [],
            "total": 0,
            "page": page,
            "limit": limit
        }

@router.get("/on-quest")
def get_on_quest_adventurers(
    page: int = Query(1, ge=1),
    limit: int = Query(20, ge=1, le=100),
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """冒険中の冒険者一覧を詳細情報付きで取得"""
    print(f"DEBUG: 冒険中冒険者取得開始 - プレイヤーID: {current_user.id}")
    # プレイヤーの武器を持って冒険中の冒険者を取得
    adventurers_with_quests = db.query(
        AdventurerInstance,
        AdventurerQuest,
        PlayerWeapon,
        WeaponMaster,
        QuestAreaMaster
    ).join(
        AdventurerQuest,
        and_(
            AdventurerInstance.current_quest_id == AdventurerQuest.id,
            AdventurerQuest.status == "in_progress"
        )
    ).join(
        PlayerWeapon,
        AdventurerQuest.player_weapon_id == PlayerWeapon.id
    ).join(
        WeaponMaster,
        PlayerWeapon.weapon_master_id == WeaponMaster.id
    ).join(
        QuestAreaMaster,
        AdventurerQuest.quest_area_id == QuestAreaMaster.id
    ).filter(
        AdventurerInstance.player_id == current_user.id
    ).offset((page - 1) * limit).limit(limit).all()
    
    print(f"DEBUG: 冒険中冒険者クエリ結果: {len(adventurers_with_quests)}件")
    
    # 詳細情報を含む結果を構築
    detailed_adventurers = []
    from datetime import timezone
    current_time = datetime.now(timezone.utc)
    
    for adventurer, quest, weapon, weapon_master, quest_area in adventurers_with_quests:
        # 進捗計算
        total_duration = (quest.end_time - quest.start_time).total_seconds()
        elapsed_time = (current_time - quest.start_time).total_seconds()
        progress_percentage = min(100, max(0, (elapsed_time / total_duration) * 100))
        
        # 残り時間計算
        remaining_seconds = max(0, (quest.end_time - current_time).total_seconds())
        remaining_minutes = int(remaining_seconds / 60)
        remaining_hours = int(remaining_minutes / 60)
        remaining_minutes = remaining_minutes % 60
        
        # クエスト完了判定
        is_completed = current_time >= quest.end_time
        
        # クエストが完了した場合、ステータスを更新して買取待ちに移動
        if is_completed and quest.status == "in_progress":
            quest.status = "completed"
            adventurer.status = "returning"
            adventurer.current_quest_id = None
            
            # 報酬を生成（簡単な例）
            from ....models import QuestReward
            import uuid
            
            # ゴールド報酬
            gold_reward = QuestReward(
                adventurer_quest_id=quest.id,
                item_type="gold",
                item_id="gold",
                quantity=weapon.attack * 2,  # 攻撃力の2倍のゴールド
                buyback_price=weapon.attack * 2,
                buyback_deadline=current_time + timedelta(hours=24),
                is_bought=False
            )
            db.add(gold_reward)
            
            # 素材報酬（ランダム）
            material_reward = QuestReward(
                adventurer_quest_id=quest.id,
                item_type="material", 
                item_id="1",  # 基本的な素材ID
                quantity=random.randint(1, 3),
                buyback_price=50,
                buyback_deadline=current_time + timedelta(hours=24),
                is_bought=False
            )
            db.add(material_reward)
            
            db.commit()
            continue  # 完了したクエストは冒険中リストから除外
        
        detailed_adventurer = {
            "id": str(adventurer.id),
            "name": adventurer.name,
            "level": adventurer.level,
            "trust_level": adventurer.trust_level,
            "status": "completed" if is_completed else "on_quest",
            "adventurer_master": {
                "name": adventurer.adventurer_master.name if adventurer.adventurer_master else "Unknown",
                "profession": adventurer.adventurer_master.profession if adventurer.adventurer_master else "unknown",
                "personality": adventurer.adventurer_master.personality if adventurer.adventurer_master else "normal",
            },
            "current_quest": {
                "id": str(quest.id),
                "status": quest.status,
                "start_time": quest.start_time.isoformat(),
                "end_time": quest.end_time.isoformat(),
                "progress_percentage": round(progress_percentage, 1),
                "remaining_time": {
                    "hours": remaining_hours,
                    "minutes": remaining_minutes,
                    "total_minutes": int(remaining_seconds / 60)
                },
                "is_completed": is_completed,
                "quest_area": {
                    "id": quest_area.id,
                    "name": quest_area.name,
                    "area_type": quest_area.area_type,
                    "difficulty": quest_area.difficulty,
                    "duration_minutes": quest_area.duration_minutes,
                    "description": quest_area.description,
                    "background_color": quest_area.background_color
                },
                "weapon_used": {
                    "id": str(weapon.id),
                    "name": weapon_master.name,
                    "attack": weapon.attack,
                    "enchant_level": weapon.enchant_level,
                    "weapon_type": weapon_master.weapon_type_id,
                    "display_name": weapon.custom_name or weapon_master.name
                }
            }
        }
        detailed_adventurers.append(detailed_adventurer)
    
    # 総数を取得
    total_query = db.query(AdventurerInstance).join(
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
    total = total_query.count()
    
    return {
        "adventurers": detailed_adventurers,
        "total": total,
        "page": page,
        "limit": limit
    }


@router.get("/buybacks", response_model=QuestResultResponse)
def get_pending_buybacks(
    current_user: Player = Depends(get_current_player),
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
    print(f"DEBUG: クエストエリア一覧取得開始")
    areas = db.query(QuestAreaMaster).filter(
        QuestAreaMaster.is_active == True
    ).all()
    print(f"DEBUG: 取得したクエストエリア数: {len(areas)}")
    for area in areas:
        print(f"  - {area.name} (必要レベル: {area.required_level})")
    
    return {"areas": areas}


def _find_suitable_quest_area(db: Session, adventurer_level: int) -> Optional[QuestAreaMaster]:
    """冒険者のレベルに適したクエストエリアを見つける"""
    try:
        # 冒険者のレベル以下で、最も高いレベル要求のクエストエリアを選択
        quest_areas = db.query(QuestAreaMaster).filter(
            and_(
                QuestAreaMaster.is_active == True,
                QuestAreaMaster.required_level <= adventurer_level
            )
        ).order_by(QuestAreaMaster.required_level.desc()).all()
        
        print(f"DEBUG: 冒険者レベル{adventurer_level}で利用可能なクエストエリア数: {len(quest_areas)}")
        
        if not quest_areas:
            print("DEBUG: 適切なクエストエリアが見つかりません")
            return None
        
        # レベルに最も適したエリアを選択（難易度調整）
        # 冒険者レベルが要求レベルより3以上高い場合は、より高難易度のエリアを選ぶ
        for area in quest_areas:
            if adventurer_level >= area.required_level:
                print(f"DEBUG: 選択されたクエストエリア: {area.name}")
                return area
        
        selected_area = quest_areas[0] if quest_areas else None
        print(f"DEBUG: フォールバック選択: {selected_area.name if selected_area else 'なし'}")
        return selected_area
    except Exception as e:
        print(f"DEBUG: クエストエリア検索でエラー: {e}")
        return None


@router.post("/{adventurer_id}/sell")
def sell_weapon_to_adventurer(
    adventurer_id: UUID,
    request: WeaponSaleRequest,
    current_user: Player = Depends(get_current_player),
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
    if adventurer.adventurer_master:
        adventurer_budget = adventurer.adventurer_master.budget_max
    else:
        # Named characters or adventurers without master data use a default budget
        adventurer_budget = 10000  # Default budget for named characters
    
    if request.price > adventurer_budget:
        raise HTTPException(status_code=400, detail="冒険者の予算を超えています")
    
    # 購入記録を作成
    purchase = AdventurerPurchase(
        adventurer_instance_id=adventurer_id,
        weapon_id=request.weapon_id,
        purchase_price=request.price
    )
    db.add(purchase)
    
    # プレイヤーにゴールドを追加
    current_user.gold += request.price
    
    # 武器を冒険者に譲渡（売却フラグをセット）
    player_weapon.is_sold = True
    
    # 冒険者の信頼度を上げる
    adventurer.trust_level = min(100, adventurer.trust_level + 5)
    
    # 冒険者に適したクエストエリアを自動選択して派遣
    suitable_quest_area = _find_suitable_quest_area(db, adventurer.level)
    print(f"DEBUG: 冒険者 {adventurer.name} (Lv.{adventurer.level}) のクエストエリア検索結果: {suitable_quest_area.name if suitable_quest_area else 'なし'}")
    
    if suitable_quest_area:
        # クエストを作成
        quest = AdventurerQuest(
            adventurer_instance_id=adventurer_id,
            quest_area_id=suitable_quest_area.id,
            player_weapon_id=request.weapon_id,  # 購入した武器をクエストに紐付け
            status="in_progress",
            start_time=datetime.utcnow(),
            end_time=datetime.utcnow() + timedelta(minutes=suitable_quest_area.duration_minutes)
        )
        db.add(quest)
        db.flush()
        
        # 冒険者のステータスを「冒険中」に更新
        adventurer.status = "on_quest"
        adventurer.current_quest_id = quest.id
        adventurer.visit_start_time = None
        adventurer.visit_end_time = None
        print(f"DEBUG: 冒険者 {adventurer.name} を {suitable_quest_area.name} に派遣しました。クエストID: {quest.id}")
    else:
        # 適切なクエストエリアが見つからない場合は待機状態
        adventurer.status = "idle"
        adventurer.visit_start_time = None
        adventurer.visit_end_time = None
        print(f"DEBUG: 冒険者 {adventurer.name} 用のクエストエリアが見つからないため、アイドル状態にしました")
    
    db.commit()
    
    # レスポンス作成
    response = {
        "success": True,
        "message": "武器を販売しました", 
        "gold_earned": request.price,
        "weapon_name": player_weapon.weapon_master.name,
        "adventurer_name": adventurer.name,
        "trust_gained": 5,
        "new_trust_level": adventurer.trust_level,
        "sale_reason": f"{adventurer.name}が{player_weapon.weapon_master.name}を{request.price}ゴールドで購入しました"
    }
    
    # クエスト情報を追加
    if suitable_quest_area:
        response.update({
            "quest_dispatched": True,
            "quest_area_name": suitable_quest_area.name,
            "quest_duration_minutes": suitable_quest_area.duration_minutes,
            "quest_end_time": quest.end_time.isoformat() if quest.end_time else None
        })
    else:
        response.update({
            "quest_dispatched": False,
            "reason": "適切なクエストエリアが見つかりませんでした"
        })
    
    return response


@router.post("/{adventurer_id}/quest")
def send_adventurer_on_quest(
    adventurer_id: UUID,
    request: QuestDispatchRequest,
    current_user: Player = Depends(get_current_player),
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
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """クエスト報酬を買い取る"""
    try:
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
                raise HTTPException(status_code=404, detail=f"報酬アイテム {item_id} が見つかりません（既に購入済みまたは存在しません）")
            
            # Use timezone-aware datetime for comparison
            current_time = datetime.now(timezone.utc)
            if reward.buyback_deadline < current_time:
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
                player_material = db.query(PlayerMaterial).filter(
                    and_(
                        PlayerMaterial.player_id == current_user.id,
                        PlayerMaterial.material_master_id == reward.item_id
                    )
                ).first()
                
                if player_material:
                    player_material.quantity += reward.quantity
                else:
                    player_material = PlayerMaterial(
                        player_id=current_user.id,
                        material_master_id=reward.item_id,
                        quantity=reward.quantity
                    )
                    db.add(player_material)
            
            elif reward.item_type == "weapon":
                # 武器の場合
                player_weapon = PlayerWeapon(
                    player_id=current_user.id,
                    weapon_id=reward.item_id,
                    acquisition_method="buyback"
                )
                db.add(player_weapon)
        
        db.commit()
        
        return {"message": "アイテムを買い取りました", "total_cost": total_price}
    
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    except Exception as e:
        # Log the actual error and return a generic 500 error
        import logging
        logging.error(f"Buyback error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"予期しないエラーが発生しました: {str(e)}")


@router.delete("/buyback/{quest_result_id}")
def reject_buyback(
    quest_result_id: UUID,
    current_user: Player = Depends(get_current_player),
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


@router.get("/buyback-summary")
def get_buyback_summary(
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """買取可能なアイテムの概要を取得"""
    try:
        now = datetime.now(timezone.utc)
        
        # 買取期限内の未購入報酬を取得
        rewards = db.query(QuestReward).join(
            AdventurerQuest
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
        ).all()
        
        # 概要情報を計算
        total_items = len(rewards)
        total_cost = sum(reward.buyback_price for reward in rewards)
        
        # アイテムタイプ別の統計
        item_types = {}
        for reward in rewards:
            item_type = reward.item_type
            if item_type not in item_types:
                item_types[item_type] = {"count": 0, "total_cost": 0}
            item_types[item_type]["count"] += 1
            item_types[item_type]["total_cost"] += reward.buyback_price
        
        # プレイヤーのゴールド残高で購入可能なアイテムを計算
        affordable_items = 0
        affordable_cost = 0
        current_gold = current_user.gold
        
        # 安い順にソートして、購入可能なアイテムを計算
        sorted_rewards = sorted(rewards, key=lambda r: r.buyback_price)
        for reward in sorted_rewards:
            if affordable_cost + reward.buyback_price <= current_gold:
                affordable_items += 1
                affordable_cost += reward.buyback_price
            else:
                break
        
        # 購入効率を計算（購入可能アイテム数 / 総アイテム数 * 100）
        efficiency_percentage = (affordable_items / total_items * 100) if total_items > 0 else 0.0
        
        # プレイヤーのゴールド残高
        can_afford_all = current_user.gold >= total_cost
        
        return {
            "success": True,
            "total_items": total_items,
            "total_cost": total_cost,
            "affordable_items": affordable_items,  # Flutter側が期待するフィールド
            "affordable_cost": affordable_cost,    # Flutter側が期待するフィールド
            "efficiency_percentage": efficiency_percentage,  # Flutter側が期待するフィールド
            "summary": {
                "total_items": total_items,
                "total_cost": total_cost,
                "can_afford_all": can_afford_all,
                "player_gold": current_user.gold,
                "item_types": item_types
            },
            "message": f"{total_items}個のアイテムが買取可能です（合計{total_cost}ゴールド）"
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"買取概要の取得でエラーが発生しました: {str(e)}")


class BulkBuybackRequest(BaseModel):
    max_gold: Optional[int] = None

@router.post("/bulk-buyback")
def execute_bulk_buyback(
    request: BulkBuybackRequest,
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """一括買取を実行"""
    try:
        now = datetime.now(timezone.utc)
        
        # 買取期限内の未購入報酬を取得
        rewards = db.query(QuestReward).join(
            AdventurerQuest
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
        ).order_by(QuestReward.buyback_price.asc()).all()  # 安い順に処理
        
        if not rewards:
            return {
                "success": True,
                "message": "買取可能なアイテムがありません",
                "purchased_items": [],
                "total_cost": 0,
                "total_items": 0
            }
        
        # 予算制限がある場合は適用
        available_gold = min(current_user.gold, request.max_gold) if request.max_gold else current_user.gold
        
        purchased_items = []
        total_cost = 0
        total_gold_gained = 0
        
        # 素材数量をまとめるための辞書
        material_quantities = {}
        
        for reward in rewards:
            net_cost = reward.buyback_price
            if reward.item_type == "gold":
                # ゴールド報酬の場合、実際のコストは buyback_price - reward_quantity
                net_cost = reward.buyback_price - reward.quantity
            
            if total_cost + net_cost <= available_gold:
                # 買取実行
                total_cost += net_cost
                reward.is_bought = True
                
                # プレイヤーのインベントリに追加
                if reward.item_type == "material" and reward.item_id:
                    # 素材の場合（item_idがNoneでない場合のみ）
                    # item_id = "1" の場合は、特定の素材IDに変換する必要がある
                    material_id = reward.item_id
                    if material_id == "1":
                        # "1" は鉄鉱石として扱う（デフォルト素材）
                        material_id = "iron_ore"
                    
                    # 該当する素材マスターが存在するかチェック
                    material_master = db.query(MaterialMaster).filter(
                        MaterialMaster.id == material_id
                    ).first()
                    
                    if material_master:
                        # 素材数量を累積
                        if material_id not in material_quantities:
                            material_quantities[material_id] = 0
                        material_quantities[material_id] += reward.quantity
                
                elif reward.item_type == "weapon" and reward.item_id:
                    # 武器の場合
                    player_weapon = PlayerWeapon(
                        player_id=current_user.id,
                        weapon_master_id=reward.item_id,
                        base_attack=20,  # デフォルト攻撃力
                        acquisition_method="buyback"
                    )
                    db.add(player_weapon)
                
                elif reward.item_type == "gold":
                    # ゴールドの場合、報酬分を追加（net_costで差額は計算済み）
                    total_gold_gained += reward.quantity
                
                # 購入アイテムの詳細情報を取得
                item_name = "不明なアイテム"
                if reward.item_type == "material" and reward.item_id:
                    # 素材名を取得
                    mat_id = reward.item_id
                    if mat_id == "1":
                        mat_id = "iron_ore"
                    mat_master = db.query(MaterialMaster).filter(
                        MaterialMaster.id == mat_id
                    ).first()
                    if mat_master:
                        item_name = mat_master.name
                elif reward.item_type == "gold":
                    item_name = f"{reward.quantity}ゴールド"
                elif reward.item_type == "weapon":
                    # 武器マスター情報を取得（必要に応じて）
                    item_name = "武器"
                
                # クエスト情報を取得
                quest_info = db.query(AdventurerQuest).options(
                    joinedload(AdventurerQuest.quest_area),
                    joinedload(AdventurerQuest.adventurer)  # 正しいリレーション名
                ).filter(
                    AdventurerQuest.id == reward.adventurer_quest_id
                ).first()
                
                quest_area_name = "不明なエリア"
                adventurer_name = "不明な冒険者"
                
                if quest_info:
                    # エリア名と冒険者名を取得
                    if quest_info.quest_area:
                        quest_area_name = quest_info.quest_area.name
                    if quest_info.adventurer:  # 正しいリレーション名
                        adventurer_name = quest_info.adventurer.name
                
                purchased_items.append({
                    "item_type": reward.item_type,
                    "item_name": item_name,
                    "quantity": reward.quantity,
                    "price": reward.buyback_price,  # Flutterはpriceを期待
                    "quest_area_name": quest_area_name,
                    "adventurer_name": adventurer_name
                })
            else:
                # 予算超過で買取不可
                break
        
        # 素材をまとめてプレイヤーインベントリに追加
        for material_id, total_quantity in material_quantities.items():
            player_material = db.query(PlayerMaterial).filter(
                and_(
                    PlayerMaterial.player_id == current_user.id,
                    PlayerMaterial.material_master_id == material_id
                )
            ).first()
            
            if player_material:
                player_material.quantity += total_quantity
            else:
                player_material = PlayerMaterial(
                    player_id=current_user.id,
                    material_master_id=material_id,
                    quantity=total_quantity
                )
                db.add(player_material)
        
        # プレイヤーのゴールドを調整（コスト支払い + ゴールド報酬追加）
        current_user.gold = current_user.gold - total_cost + total_gold_gained
        
        # ショップ経験値を追加
        from app.core.shop_progression import ShopProgressionService
        exp_result = ShopProgressionService.add_experience(
            current_user, 
            "bulk_buyback",
            db,
            multiplier=len(purchased_items)  # アイテム数に応じて経験値倍率
        )
        
        db.commit()
        
        return {
            "success": True,
            "message": f"{len(purchased_items)}個のアイテムを{total_cost}ゴールドで買取しました",
            "items_purchased": purchased_items,  # Flutter側が期待するフィールド名
            "total_cost": total_cost,
            "total_items": len(purchased_items),
            "gold_remaining": current_user.gold,  # Flutter側が期待するフィールド名
            "exp_gained": exp_result.get("exp_gained", 0),  # Flutter側が期待するフィールド名
            "shop_level": current_user.shop_level,  # 現在のショップレベルを追加
            "shop_level_up": exp_result if exp_result.get("leveled_up") else None  # Flutter側が期待するフィールド名
        }
        
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"一括買取でエラーが発生しました: {str(e)}")


def _calculate_weapon_requirements_for_tier(player_shop_level: int, tier: str) -> tuple:
    """プレイヤーレベルとティアに基づいて武器要求を計算"""
    # プレイヤーレベルに基づく基本攻撃力範囲
    # レベル1: 6-15攻撃力, レベル5: 20-30攻撃力, レベル10: 40-48攻撃力
    base_min = max(1, 5 + (player_shop_level - 1) * 4)
    base_max = base_min + 10 + player_shop_level
    
    if tier == "normal":
        # 通常ティア: プレイヤーレベルに見合った要求（80%）
        # 現在のショップレベルで購入できる武器で満たせる範囲
        min_attack = max(1, base_min + random.randint(-2, 2))
        return min_attack, min_attack + random.randint(3, 8)
    
    elif tier == "challenge":
        # チャレンジティア: 1-2レベル高い要求（20%）
        # クラフトや強化が必要な範囲
        challenge_bonus = random.randint(8, 15)
        min_attack = base_min + challenge_bonus
        return min_attack, min_attack + random.randint(5, 12)
    
    elif tier == "elite":
        # エリートティア: 高難易度（特別なイベント用）
        elite_bonus = random.randint(20, 35)
        min_attack = base_min + elite_bonus
        return min_attack, min_attack + random.randint(10, 20)
    
    return base_min, base_max


def _get_tier_appropriate_masters(db: Session, player_shop_level: int, tier: str) -> List[AdventurerMaster]:
    """指定されたティアに適したアドベンチャーマスターを取得"""
    # プレイヤーレベルに適した冒険者を取得
    base_query = db.query(AdventurerMaster).filter(
        AdventurerMaster.is_active == True,
        AdventurerMaster.min_player_level <= player_shop_level
    )
    
    # max_player_levelが設定されている場合はそれも考慮
    base_query = base_query.filter(
        or_(
            AdventurerMaster.max_player_level.is_(None),
            AdventurerMaster.max_player_level >= player_shop_level
        )
    )
    
    masters = base_query.all()
    
    if not masters:
        # フォールバック: 最も低いレベル要求の冒険者を返す
        return db.query(AdventurerMaster).filter(
            AdventurerMaster.is_active == True
        ).order_by(AdventurerMaster.min_player_level).limit(3).all()
    
    return masters


@router.post("/spawn-visitors")
def spawn_visiting_adventurers(
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """プログレッシブ訪問者生成システム - 25%固有キャラ/80%通常/20%チャレンジ"""
    player_shop_level = current_user.shop_level
    
    # 冒険者数を決定（1-3人）
    num_visitors = random.randint(1, 3)
    created_adventurers = []
    now = datetime.utcnow()
    
    for _ in range(num_visitors):
        # 25%の確率で固有キャラクターをチェック（解放済みの場合）
        if random.random() < 0.25:
            unlocked_character = _try_spawn_named_character(db, current_user.id, now)
            if unlocked_character:
                created_adventurers.append(unlocked_character)
                continue
        
        # 80%の確率で通常ティア、20%の確率でチャレンジティア
        if random.random() < 0.8:
            tier = "normal"
        else:
            tier = "challenge"
        
        # ティアに適した冒険者マスターを取得
        available_masters = _get_tier_appropriate_masters(db, player_shop_level, tier)
        
        if not available_masters:
            continue
        
        # 重みを考慮して冒険者マスターを選択
        total_weight = sum(m.spawn_weight for m in available_masters)
        if total_weight == 0:
            master = random.choice(available_masters)
        else:
            weight_threshold = random.randint(1, total_weight)
            current_weight = 0
            master = available_masters[0]  # フォールバック
            
            for m in available_masters:
                current_weight += m.spawn_weight
                if current_weight >= weight_threshold:
                    master = m
                    break
        
        # 冒険者インスタンスを作成
        # レベルはマスターのレベル±2の範囲で決定
        adventurer_level = max(1, master.level + random.randint(-2, 2))
        
        adventurer = AdventurerInstance(
            adventurer_master_id=int(master.id),
            name=f"{master.name}_{random.randint(1, 999)}",
            level=adventurer_level,
            trust_level=random.randint(0, 50),
            status="visiting",
            visit_start_time=now,
            visit_end_time=now + timedelta(minutes=random.randint(45, 180))
        )
        db.add(adventurer)
        db.flush()
        
        # ティアに基づいて武器要求を計算
        min_attack, max_attack = _calculate_weapon_requirements_for_tier(player_shop_level, tier)
        
        # 予算を攻撃力と難易度に応じて調整
        base_budget_ratio = min_attack / 30.0  # 攻撃力30で1倍
        tier_multiplier = 1.0 if tier == "normal" else 1.5  # チャレンジは予算1.5倍
        personality_multiplier = {
            "generous": 1.3,
            "wealthy": 1.4,
            "normal": 1.0,
            "friendly": 1.1,
            "stingy": 0.7,
            "poor": 0.6
        }.get(master.personality, 1.0)
        
        adjusted_budget = int(
            master.budget_max * 
            max(0.3, base_budget_ratio) * 
            tier_multiplier * 
            personality_multiplier
        )
        
        # 武器タイプの選択（職業に基づく）
        profession_weapon_types = {
            "warrior": ["sword", "hammer"],
            "archer": ["bow", "dagger"],
            "mage": ["staff"],
            "rogue": ["dagger", "bow"],
            "paladin": ["sword", "hammer"]
        }
        
        preferred_types = profession_weapon_types.get(master.profession, ["sword", "bow", "staff", "dagger", "hammer"])
        weapon_type = random.choice(preferred_types)
        
        # レアリティの傾向（チャレンジティアはより高いレアリティを要求）
        if tier == "normal":
            rarity_choices = ["common", "common", "common", "rare"]
        elif tier == "challenge":
            rarity_choices = ["common", "rare", "rare", "epic"]
        else:  # elite
            rarity_choices = ["rare", "epic", "epic", "legendary"]
        
        # 武器リクエストを作成
        request = AdventurerRequest(
            adventurer_instance_id=adventurer.id,
            weapon_type=weapon_type,
            min_attack=min_attack,
            max_budget=adjusted_budget,
            preferred_rarity=random.choice(rarity_choices),
            urgency=random.randint(1, 5),
            description=f"【{tier.upper()}】{master.personality}な{master.profession}からのリクエスト",
            deadline=now + timedelta(hours=random.randint(3, 24))
        )
        db.add(request)
        
        created_adventurers.append({
            "adventurer": adventurer,
            "tier": tier,
            "min_attack": min_attack,
            "budget": adjusted_budget
        })
    
    db.commit()
    
    # 結果の詳細を返す
    normal_count = len([a for a in created_adventurers if a["tier"] == "normal"])
    challenge_count = len([a for a in created_adventurers if a["tier"] == "challenge"])
    named_character_count = len([a for a in created_adventurers if a["tier"] == "named_character"])
    
    return {
        "message": f"{len(created_adventurers)}人の冒険者が訪問しました",
        "breakdown": {
            "normal_adventurers": normal_count,
            "challenge_adventurers": challenge_count,
            "named_characters": named_character_count,
            "player_shop_level": player_shop_level
        },
        "adventurers": [
            {
                "id": str(a["adventurer"].id),
                "name": a["adventurer"].name,
                "tier": a["tier"],
                "min_attack_required": a["min_attack"],
                "max_budget": a["budget"]
            } for a in created_adventurers
        ]
    }


def _try_spawn_named_character(db: Session, player_id: UUID, now: datetime) -> Optional[dict]:
    """
    解放済み固有キャラクターをスポーンする
    
    Returns:
        dict or None: スポーンしたキャラクター情報、またはNone
    """
    # 解放済みキャラクターを取得
    unlocked_bonds = db.query(PlayerCharacterBond).filter(
        and_(
            PlayerCharacterBond.player_id == player_id,
            PlayerCharacterBond.is_unlocked == True
        )
    ).join(AdventurerCharacter).all()
    
    if not unlocked_bonds:
        return None
    
    # 現在訪問中でない固有キャラクターを選択
    for bond in unlocked_bonds:
        # 既に訪問中かチェック
        existing_visit = db.query(AdventurerInstance).filter(
            and_(
                AdventurerInstance.character_id == bond.character_id,
                AdventurerInstance.status.in_(['visiting', 'on_quest'])
            )
        ).first()
        
        if existing_visit:
            continue  # 既に活動中なのでスキップ
        
        # 固有キャラクターとしてスポーン
        character = bond.character
        adventurer = AdventurerInstance(
            character_id=character.id,
            is_named_character=True,
            name=character.display_name,
            level=max(bond.current_level, character.base_level),
            trust_level=bond.trust_level,
            status="visiting",
            visit_start_time=now,
            visit_end_time=now + timedelta(minutes=random.randint(60, 240))  # 1-4時間訪問
        )
        db.add(adventurer)
        db.flush()
        
        # 固有キャラクター用のリクエストを作成
        # 信頼度に基づいて予算を調整
        base_budget = 1000 + (bond.trust_level * 50)  # 信頼度が高いほど予算も高い
        min_attack = 50 + (bond.current_level * 10)
        
        request = AdventurerRequest(
            adventurer_instance_id=adventurer.id,
            weapon_type=character.preferred_weapon_types[0] if character.preferred_weapon_types else "sword",
            min_attack=min_attack,
            max_budget=base_budget,
            preferred_rarity="rare" if bond.trust_level > 50 else "common",
            urgency=3,  # 固有キャラクターは中程度の緊急度
            description=f"【固有】{character.display_name}からの特別なリクエスト",
            deadline=now + timedelta(hours=random.randint(6, 48))
        )
        db.add(request)
        
        return {
            "adventurer": adventurer,
            "tier": "named_character",
            "min_attack": min_attack,
            "budget": base_budget
        }
    
    return None


@router.post("/test-spawn/{player_shop_level}")
def test_spawn_for_level(
    player_shop_level: int,
    db: Session = Depends(get_db)
):
    """テスト用: 指定されたプレイヤーレベルでの冒険者生成をシミュレート"""
    
    # 模擬プレイヤーオブジェクト
    class MockPlayer:
        def __init__(self, shop_level):
            self.shop_level = shop_level
    
    mock_player = MockPlayer(player_shop_level)
    
    # 冒険者数を決定（1-3人）
    num_visitors = random.randint(1, 3)
    created_adventurers = []
    now = datetime.utcnow()
    
    for _ in range(num_visitors):
        # 80%の確率で通常ティア、20%の確率でチャレンジティア
        if random.random() < 0.8:
            tier = "normal"
        else:
            tier = "challenge"
        
        # ティアに適した冒険者マスターを取得
        available_masters = _get_tier_appropriate_masters(db, player_shop_level, tier)
        
        if not available_masters:
            continue
        
        # 重みを考慮して冒険者マスターを選択
        total_weight = sum(m.spawn_weight for m in available_masters)
        if total_weight == 0:
            master = random.choice(available_masters)
        else:
            weight_threshold = random.randint(1, total_weight)
            current_weight = 0
            master = available_masters[0]  # フォールバック
            
            for m in available_masters:
                current_weight += m.spawn_weight
                if current_weight >= weight_threshold:
                    master = m
                    break
        
        # ティアに基づいて武器要求を計算
        min_attack, max_attack = _calculate_weapon_requirements_for_tier(player_shop_level, tier)
        
        # 予算を攻撃力と難易度に応じて調整
        base_budget_ratio = min_attack / 30.0  # 攻撃力30で1倍
        tier_multiplier = 1.0 if tier == "normal" else 1.5  # チャレンジは予算1.5倍
        personality_multiplier = {
            "generous": 1.3,
            "wealthy": 1.4,
            "normal": 1.0,
            "friendly": 1.1,
            "stingy": 0.7,
            "poor": 0.6
        }.get(master.personality, 1.0)
        
        adjusted_budget = int(
            master.budget_max * 
            max(0.3, base_budget_ratio) * 
            tier_multiplier * 
            personality_multiplier
        )
        
        created_adventurers.append({
            "master_name": master.name,
            "master_profession": master.profession,
            "master_personality": master.personality,
            "tier": tier,
            "min_attack": min_attack,
            "budget": adjusted_budget,
            "progression_multiplier": master.progression_multiplier
        })
    
    # 結果の詳細を返す
    normal_count = len([a for a in created_adventurers if a["tier"] == "normal"])
    challenge_count = len([a for a in created_adventurers if a["tier"] == "challenge"])
    
    return {
        "message": f"プレイヤーレベル{player_shop_level}で{len(created_adventurers)}人の冒険者を生成",
        "breakdown": {
            "normal_adventurers": normal_count,
            "challenge_adventurers": challenge_count,
            "player_shop_level": player_shop_level,
            "normal_percentage": round(normal_count / len(created_adventurers) * 100, 1) if created_adventurers else 0,
            "challenge_percentage": round(challenge_count / len(created_adventurers) * 100, 1) if created_adventurers else 0
        },
        "adventurers": created_adventurers
    }