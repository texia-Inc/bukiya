from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import decode_access_token
from app.models.player import Player

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: Session = Depends(get_db)
) -> Player:
    """
    JWTトークンから現在のユーザーを取得
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="認証情報を確認できませんでした",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = decode_access_token(token)
        player_id: str = payload.get("sub")
        if player_id is None:
            raise credentials_exception
    except Exception:
        raise credentials_exception
    
    player = db.query(Player).filter(Player.id == player_id).first()
    if player is None:
        raise credentials_exception
    
    if not player.is_active or player.is_banned:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="アカウントが無効化または停止されています"
        )
    
    return player

# エイリアス（互換性のため）
get_current_player = get_current_user
