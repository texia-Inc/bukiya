from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from typing import Optional
import uuid

from app.core.database import get_db
from app.core.config import settings
from app.core.security import verify_password, get_password_hash, create_access_token, create_refresh_token, verify_refresh_token
from app.core.dependencies import get_current_user
from app.schemas.auth import Token, UserCreate, UserResponse, UserLogin, RefreshTokenRequest, DeviceLoginRequest, GuestLoginRequest, AccountLinkRequest
from app.schemas.common import APIResponse
from app.models.player import Player
from app.models.player_statistics import PlayerStatistics
from app.models.device_session import DeviceSession

router = APIRouter()

@router.post("/register", response_model=APIResponse[UserResponse])
async def register(
    user_data: UserCreate,
    db: Session = Depends(get_db)
):
    """
    新規プレイヤー登録
    """
    # メールアドレスの重複チェック
    existing_user = db.query(Player).filter(Player.email == user_data.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="このメールアドレスは既に登録されています"
        )
    
    # ユーザー名の重複チェック
    existing_username = db.query(Player).filter(Player.username == user_data.username).first()
    if existing_username:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="このユーザー名は既に使用されています"
        )
    
    # パスワードハッシュ化
    hashed_password = get_password_hash(user_data.password)
    
    # プレイヤー作成
    player = Player(
        username=user_data.username,
        email=user_data.email,
        password_hash=hashed_password,
        gold=settings.DEFAULT_PLAYER_GOLD,
        gems=settings.DEFAULT_PLAYER_GEMS,
        shop_level=settings.DEFAULT_SHOP_LEVEL,
        reputation=1
    )
    
    db.add(player)
    db.commit()
    db.refresh(player)
    
    # プレイヤー統計初期化
    player_stats = PlayerStatistics(player_id=player.id)
    db.add(player_stats)
    db.commit()
    
    # アクセストークンとリフレッシュトークン生成
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
        message="プレイヤー登録が完了しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/login", response_model=APIResponse[UserResponse])
async def login(
    user_data: UserLogin,
    db: Session = Depends(get_db)
):
    """
    プレイヤーログイン
    """
    # プレイヤー認証
    player = db.query(Player).filter(Player.email == user_data.email).first()
    if not player or not verify_password(user_data.password, player.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="メールアドレスまたはパスワードが正しくありません",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # アカウント状態チェック
    if not player.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="アカウントが無効化されています"
        )
    
    if player.is_banned:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"アカウントが停止されています。理由: {player.ban_reason or '不明'}"
        )
    
    # 最終ログイン時刻更新
    player.last_login = datetime.utcnow()
    db.commit()
    
    # アクセストークンとリフレッシュトークン生成
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
        message="ログインしました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/refresh", response_model=APIResponse[Token])
async def refresh_token(
    current_user: Player = Depends(get_current_user)
):
    """
    アクセストークン更新（既存のアクセストークンを使用）
    """
    access_token = create_access_token(
        data={"sub": str(current_user.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    return APIResponse(
        success=True,
        data=Token(
            access_token=access_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        ),
        message="トークンを更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )

@router.post("/refresh-with-token", response_model=APIResponse[Token])
async def refresh_with_refresh_token(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    リフレッシュトークンを使用したアクセストークン更新
    """
    # リフレッシュトークンを検証
    user_id = verify_refresh_token(request.refresh_token)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="無効なリフレッシュトークンです"
        )
    
    # ユーザーを取得
    player = db.query(Player).filter(Player.id == user_id).first()
    if not player or not player.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="ユーザーが見つからないか無効化されています"
        )
    
    # 新しいアクセストークンとリフレッシュトークンを生成
    new_access_token = create_access_token(
        data={"sub": str(player.id)},
        expires_delta=timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    )
    
    new_refresh_token = create_refresh_token(
        data={"sub": str(player.id)}
    )
    
    return APIResponse(
        success=True,
        data=Token(
            access_token=new_access_token,
            refresh_token=new_refresh_token,
            token_type="bearer",
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        ),
        message="トークンを更新しました",
        timestamp=datetime.utcnow(),
        request_id=str(uuid.uuid4())
    )
