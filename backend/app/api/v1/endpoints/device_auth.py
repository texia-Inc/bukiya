from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import uuid

from app.core.database import get_db
from app.core.config import settings
from app.core.security import get_password_hash, create_access_token, create_refresh_token
from app.schemas.auth import UserResponse, DeviceLoginRequest, GuestLoginRequest, AccountLinkRequest
from app.schemas.common import APIResponse
from app.models.player import Player
from app.models.player_statistics import PlayerStatistics
from app.models.device_session import DeviceSession

router = APIRouter()

@router.post("/guest-login", response_model=APIResponse[UserResponse])
async def guest_login(
    request: GuestLoginRequest,
    db: Session = Depends(get_db)
):
    """
    ゲストログイン（デバイス認証ベース）
    ゲーム系アプリの標準的な実装
    """
    # 既存のデバイスセッションを確認
    device_session = db.query(DeviceSession).filter(
        DeviceSession.device_id == request.device_id,
        DeviceSession.is_active == True
    ).first()
    
    if device_session and device_session.player_id:
        # 既存のプレイヤーアカウントが関連付けられている場合
        player = device_session.player
        if not player or not player.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="関連付けられたアカウントが無効です"
            )
        
        # デバイスセッションを更新
        device_session.update_last_used()
        player.last_login = datetime.utcnow()
        db.commit()
        
    else:
        # 新しいゲストプレイヤーを作成
        guest_username = f"Guest_{request.device_id[-8:]}"
        guest_email = f"guest_{request.device_id}@bukiya.local"
        
        # 重複チェック
        existing_player = db.query(Player).filter(
            Player.email == guest_email
        ).first()
        
        if existing_player:
            # 既存のゲストアカウントが見つかった場合
            player = existing_player
        else:
            # 新しいゲストプレイヤー作成
            player = Player(
                username=guest_username,
                email=guest_email,
                password_hash=get_password_hash(request.device_id),
                gold=settings.DEFAULT_PLAYER_GOLD,
                gems=settings.DEFAULT_PLAYER_GEMS,
                shop_level=settings.DEFAULT_SHOP_LEVEL,
                reputation=1
            )
            
            db.add(player)
            db.flush()
            
            # プレイヤー統計初期化
            player_stats = PlayerStatistics(player_id=player.id)
            db.add(player_stats)
        
        # デバイスセッション作成または更新
        if not device_session:
            device_info = request.device_info or {}
            device_session = DeviceSession(
                device_id=request.device_id,
                player_id=player.id,
                device_name=device_info.get('name'),
                device_model=device_info.get('model'),
                platform=device_info.get('platform'),
                platform_version=device_info.get('version'),
                is_trusted=True  # ゲストログインはデバイスを信頼済みとして扱う
            )
            db.add(device_session)
        else:
            device_session.player_id = player.id
            device_session.is_active = True
            device_session.update_last_used()
        
        player.last_login = datetime.utcnow()
        db.commit()
    
    # トークン生成
    access_token = create_access_token(
        data={"sub": str(player.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    refresh_token = create_refresh_token(
        data={"sub": str(player.id)}
    )
    
    return APIResponse(
        success=True,
        data=UserResponse(
            player_id=str(player.id),
            username=player.username,
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        ),
        message="ゲストログインしました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/device-login", response_model=APIResponse[UserResponse])
async def device_login(
    request: DeviceLoginRequest,
    db: Session = Depends(get_db)
):
    """
    デバイス認証ログイン（既存アカウント用）
    信頼済みデバイスでの永続ログイン
    """
    # デバイスセッションを確認
    device_session = db.query(DeviceSession).filter(
        DeviceSession.device_id == request.device_id,
        DeviceSession.is_active == True,
        DeviceSession.is_trusted == True
    ).first()
    
    if not device_session or not device_session.player_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="認証済みデバイスが見つかりません"
        )
    
    player = device_session.player
    if not player or not player.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="関連付けられたアカウントが無効です"
        )
    
    # デバイスセッション更新
    device_session.update_last_used()
    player.last_login = datetime.utcnow()
    db.commit()
    
    # トークン生成
    access_token = create_access_token(
        data={"sub": str(player.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    refresh_token = create_refresh_token(
        data={"sub": str(player.id)}
    )
    
    return APIResponse(
        success=True,
        data=UserResponse(
            player_id=str(player.id),
            username=player.username,
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        ),
        message="デバイス認証でログインしました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/link-account", response_model=APIResponse[UserResponse])
async def link_guest_account(
    request: AccountLinkRequest,
    device_id: str,
    db: Session = Depends(get_db)
):
    """
    ゲストアカウントを正規アカウントに連携
    ゲーム系アプリの標準機能
    """
    # デバイスセッションを確認
    device_session = db.query(DeviceSession).filter(
        DeviceSession.device_id == device_id,
        DeviceSession.is_active == True
    ).first()
    
    if not device_session or not device_session.player_id:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="ゲストアカウントが見つかりません"
        )
    
    guest_player = device_session.player
    if not guest_player:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="ゲストプレイヤーが見つかりません"
        )
    
    # メールアドレス・ユーザー名の重複チェック
    existing_email = db.query(Player).filter(
        Player.email == request.email,
        Player.id != guest_player.id
    ).first()
    if existing_email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="このメールアドレスは既に使用されています"
        )
    
    existing_username = db.query(Player).filter(
        Player.username == request.username,
        Player.id != guest_player.id
    ).first()
    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="このユーザー名は既に使用されています"
        )
    
    # ゲストアカウントを正規アカウントに変換
    guest_player.username = request.username
    guest_player.email = request.email
    guest_player.password_hash = get_password_hash(request.password)
    
    db.commit()
    
    # 新しいトークンを生成
    access_token = create_access_token(
        data={"sub": str(guest_player.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    refresh_token = create_refresh_token(
        data={"sub": str(guest_player.id)}
    )
    
    return APIResponse(
        success=True,
        data=UserResponse(
            player_id=str(guest_player.id),
            username=guest_player.username,
            access_token=access_token,
            refresh_token=refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        ),
        message="アカウント連携が完了しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )