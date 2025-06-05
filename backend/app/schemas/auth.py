from pydantic import BaseModel, Field, EmailStr, validator
from typing import Optional

from .common import BaseSchema

class UserCreate(BaseModel):
    """
    ユーザー登録リクエスト
    """
    username: str = Field(..., min_length=3, max_length=50, description="ユーザー名")
    email: EmailStr = Field(..., description="メールアドレス")
    password: str = Field(..., min_length=6, max_length=100, description="パスワード")
    
    @validator('username')
    def validate_username(cls, v):
        if not v.replace('_', '').replace('-', '').isalnum():
            raise ValueError('ユーザー名は英数字、アンダースコア、ハイフンのみ使用可能です')
        return v
    
    @validator('password')
    def validate_password(cls, v):
        if len(v) < 6:
            raise ValueError('パスワードは6文字以上である必要があります')
        return v

class UserLogin(BaseModel):
    """
    ユーザーログインリクエスト
    """
    email: EmailStr = Field(..., description="メールアドレス")
    password: str = Field(..., description="パスワード")

class Token(BaseModel):
    """
    トークンレスポンス
    """
    access_token: str = Field(..., description="アクセストークン")
    refresh_token: Optional[str] = Field(None, description="リフレッシュトークン")
    token_type: str = Field(default="bearer", description="トークンタイプ")
    expires_in: int = Field(..., description="有効期限（秒）")

class UserResponse(BaseSchema):
    """
    ユーザー情報レスポンス
    """
    player_id: str = Field(..., description="プレイヤーID")
    username: str = Field(..., description="ユーザー名")
    access_token: str = Field(..., description="アクセストークン")
    refresh_token: Optional[str] = Field(None, description="リフレッシュトークン")
    token_type: str = Field(default="bearer", description="トークンタイプ")
    expires_in: int = Field(..., description="有効期限（秒）")

class TokenData(BaseModel):
    """
    トークンデータ
    """
    user_id: Optional[str] = None

class RefreshTokenRequest(BaseModel):
    """
    リフレッシュトークンリクエスト
    """
    refresh_token: str = Field(..., description="リフレッシュトークン")

class DeviceLoginRequest(BaseModel):
    """
    デバイス認証ログインリクエスト
    """
    device_id: str = Field(..., description="デバイス固有ID")
    device_info: Optional[dict] = Field(None, description="デバイス情報")

class GuestLoginRequest(BaseModel):
    """
    ゲストログインリクエスト
    """
    device_id: str = Field(..., description="デバイス固有ID")
    device_info: Optional[dict] = Field(None, description="デバイス情報")

class AccountLinkRequest(BaseModel):
    """
    アカウント連携リクエスト（ゲスト→正規アカウント）
    """
    username: str = Field(..., min_length=3, max_length=50, description="ユーザー名")
    email: EmailStr = Field(..., description="メールアドレス")
    password: str = Field(..., min_length=6, max_length=100, description="パスワード")
