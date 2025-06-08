"""
固有冒険者キャラクターAPIエンドポイント
名前ありキャラクター（育成対象）の管理API
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import and_, or_
from typing import List, Optional
from datetime import datetime
from uuid import UUID

from app.core.dependencies import get_db, get_current_player
from app.models import (
    Player, AdventurerCharacter, PlayerCharacterBond, 
    CharacterUnlockLog, CharacterConversation
)
from app.schemas.adventurer_character import (
    AdventurerCharacterResponse, PlayerCharacterBondResponse,
    CharacterUnlockRequest, CharacterInteractionRequest,
    CharacterListResponse, BondProgressResponse
)

router = APIRouter()


@router.get("/available", response_model=CharacterListResponse)
def get_available_characters(
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """プレイヤーが解放可能な固有キャラクター一覧を取得"""
    
    # プレイヤーレベルで解放可能なキャラクターを取得
    available_characters = db.query(AdventurerCharacter).filter(
        and_(
            AdventurerCharacter.is_active == True,
            AdventurerCharacter.unlock_player_level <= current_user.shop_level
        )
    ).order_by(AdventurerCharacter.unlock_order).all()
    
    # プレイヤーとの絆データを取得
    existing_bonds = {
        bond.character_id: bond for bond in 
        db.query(PlayerCharacterBond).filter(
            PlayerCharacterBond.player_id == current_user.id
        ).all()
    }
    
    # レスポンス用データを構築
    character_list = []
    for character in available_characters:
        bond = existing_bonds.get(character.id)
        
        # Pydanticで処理できる形に変換
        from app.schemas.adventurer_character import AdventurerCharacterResponse
        character_dict = AdventurerCharacterResponse.model_validate(character).model_dump()
        
        # BondもPydanticに変換
        bond_dict = None
        if bond:
            from app.schemas.adventurer_character import PlayerCharacterBondResponse
            bond_dict = PlayerCharacterBondResponse.model_validate(bond).model_dump()
        
        character_data = {
            "character": character_dict,
            "bond": bond_dict,
            "is_unlocked": bond.is_unlocked if bond else False,
            "can_unlock": not bond or not bond.is_unlocked,
            "unlock_requirement_met": current_user.shop_level >= character.unlock_player_level
        }
        character_list.append(character_data)
    
    return {
        "characters": character_list,
        "player_level": current_user.shop_level,
        "total_available": len(character_list),
        "total_unlocked": len([c for c in character_list if c["is_unlocked"]])
    }


@router.get("/unlocked", response_model=List[PlayerCharacterBondResponse])
def get_unlocked_characters(
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """プレイヤーが解放済みの固有キャラクター一覧を取得"""
    
    bonds = db.query(PlayerCharacterBond).filter(
        and_(
            PlayerCharacterBond.player_id == current_user.id,
            PlayerCharacterBond.is_unlocked == True
        )
    ).all()
    
    return bonds


@router.get("/{character_id}", response_model=AdventurerCharacterResponse)
def get_character_detail(
    character_id: int,
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """特定のキャラクターの詳細情報を取得"""
    
    character = db.query(AdventurerCharacter).filter(
        AdventurerCharacter.id == character_id
    ).first()
    
    if not character:
        raise HTTPException(status_code=404, detail="キャラクターが見つかりません")
    
    # プレイヤーとの絆データを取得
    bond = db.query(PlayerCharacterBond).filter(
        and_(
            PlayerCharacterBond.player_id == current_user.id,
            PlayerCharacterBond.character_id == character_id
        )
    ).first()
    
    return {
        "character": character,
        "bond": bond,
        "can_unlock": (
            not bond or not bond.is_unlocked
        ) and current_user.shop_level >= character.unlock_player_level
    }


@router.post("/{character_id}/unlock")
def unlock_character(
    character_id: int,
    request: CharacterUnlockRequest,
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """キャラクターを解放する"""
    
    character = db.query(AdventurerCharacter).filter(
        AdventurerCharacter.id == character_id
    ).first()
    
    if not character:
        raise HTTPException(status_code=404, detail="キャラクターが見つかりません")
    
    # 解放条件チェック
    if current_user.shop_level < character.unlock_player_level:
        raise HTTPException(
            status_code=400, 
            detail=f"プレイヤーレベル{character.unlock_player_level}が必要です"
        )
    
    # 既存の絆データをチェック
    existing_bond = db.query(PlayerCharacterBond).filter(
        and_(
            PlayerCharacterBond.player_id == current_user.id,
            PlayerCharacterBond.character_id == character_id
        )
    ).first()
    
    if existing_bond and existing_bond.is_unlocked:
        raise HTTPException(status_code=400, detail="既に解放済みのキャラクターです")
    
    # 絆データを作成または更新
    if existing_bond:
        existing_bond.is_unlocked = True
        existing_bond.unlock_date = datetime.utcnow()
        bond = existing_bond
    else:
        bond = PlayerCharacterBond(
            player_id=current_user.id,
            character_id=character_id,
            trust_level=0,
            friendship_level=1,
            is_unlocked=True,
            unlock_date=datetime.utcnow()
        )
        db.add(bond)
    
    # 解放ログを記録
    unlock_log = CharacterUnlockLog(
        player_id=current_user.id,
        character_id=character_id,
        unlock_method=request.unlock_method,
        unlock_condition_met=request.condition_description
    )
    db.add(unlock_log)
    
    db.commit()
    
    return {
        "message": f"{character.display_name}を解放しました！",
        "character": character,
        "bond": bond
    }


@router.post("/{character_id}/interact")
def interact_with_character(
    character_id: int,
    request: CharacterInteractionRequest,
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """キャラクターと交流する"""
    
    # 絆データを取得
    bond = db.query(PlayerCharacterBond).filter(
        and_(
            PlayerCharacterBond.player_id == current_user.id,
            PlayerCharacterBond.character_id == character_id,
            PlayerCharacterBond.is_unlocked == True
        )
    ).first()
    
    if not bond:
        raise HTTPException(status_code=404, detail="解放されていないキャラクターです")
    
    # 交流によって得られる信頼度を計算
    trust_gain = _calculate_trust_gain(request.interaction_type, bond.trust_level)
    
    # 絆データを更新
    level_up = bond.add_trust_points(trust_gain)
    bond.total_interactions += 1
    bond.last_interaction_at = datetime.utcnow()
    
    # 交流タイプ別の処理
    if request.interaction_type == "weapon_gift":
        bond.total_weapon_gifts += 1
    
    # 会話ログを記録
    conversation = CharacterConversation(
        player_id=current_user.id,
        character_id=character_id,
        conversation_type=request.interaction_type,
        conversation_text=request.message,
        trust_gained=trust_gain
    )
    db.add(conversation)
    
    db.commit()
    
    return {
        "message": "交流が完了しました",
        "trust_gained": trust_gain,
        "new_trust_level": bond.trust_level,
        "level_up": level_up,
        "friendship_level": bond.friendship_level,
        "response_message": _get_character_response(bond.character, request.interaction_type, bond.trust_level)
    }


@router.get("/{character_id}/bond", response_model=BondProgressResponse)
def get_bond_progress(
    character_id: int,
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """キャラクターとの絆進捗を取得"""
    
    bond = db.query(PlayerCharacterBond).filter(
        and_(
            PlayerCharacterBond.player_id == current_user.id,
            PlayerCharacterBond.character_id == character_id
        )
    ).first()
    
    if not bond:
        raise HTTPException(status_code=404, detail="絆データが見つかりません")
    
    # 会話履歴を取得
    recent_conversations = db.query(CharacterConversation).filter(
        and_(
            CharacterConversation.player_id == current_user.id,
            CharacterConversation.character_id == character_id
        )
    ).order_by(CharacterConversation.created_at.desc()).limit(10).all()
    
    return {
        "bond": bond,
        "recent_conversations": recent_conversations,
        "can_participate_dragon_battle": bond.can_participate_dragon_battle(),
        "next_level_progress": {
            "current_exp": bond.current_experience,
            "required_exp": bond.next_level_exp,
            "progress_percentage": min(100, (bond.current_experience / bond.next_level_exp) * 100)
        }
    }


@router.post("/{character_id}/nickname")
def set_character_nickname(
    character_id: int,
    nickname: str = Query(..., min_length=1, max_length=50),
    current_user: Player = Depends(get_current_player),
    db: Session = Depends(get_db)
):
    """キャラクターにあだ名を設定"""
    
    bond = db.query(PlayerCharacterBond).filter(
        and_(
            PlayerCharacterBond.player_id == current_user.id,
            PlayerCharacterBond.character_id == character_id,
            PlayerCharacterBond.is_unlocked == True
        )
    ).first()
    
    if not bond:
        raise HTTPException(status_code=404, detail="解放されていないキャラクターです")
    
    bond.custom_nickname = nickname
    db.commit()
    
    return {
        "message": f"あだ名を「{nickname}」に設定しました",
        "nickname": nickname
    }


def _calculate_trust_gain(interaction_type: str, current_trust: int) -> int:
    """交流タイプと現在の信頼度に基づいて信頼度上昇値を計算"""
    base_gain = {
        "greeting": 1,
        "weapon_gift": 5,
        "quest_together": 3,
        "conversation": 2,
        "dragon_battle": 10
    }.get(interaction_type, 1)
    
    # 信頼度が高いほど上昇しにくくなる
    if current_trust >= 80:
        multiplier = 0.5
    elif current_trust >= 60:
        multiplier = 0.7
    elif current_trust >= 40:
        multiplier = 0.8
    else:
        multiplier = 1.0
    
    return max(1, int(base_gain * multiplier))


def _get_character_response(character: AdventurerCharacter, interaction_type: str, trust_level: int) -> str:
    """キャラクターの応答メッセージを生成"""
    if interaction_type == "greeting":
        if trust_level >= 80:
            return f"{character.quote} 今日も一緒に頑張ろう！"
        elif trust_level >= 40:
            return f"こんにちは！{character.name}です。"
        else:
            return "はじめまして..."
    elif interaction_type == "weapon_gift":
        return f"素晴らしい武器をありがとう！{character.quote}"
    else:
        return character.quote or f"{character.name}より"