from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime

from .common import BaseSchema

class PlayerResponse(BaseSchema):
    """
    プレイヤー情報レスポンス
    """
    id: str = Field(..., description="プレイヤーID")
    username: str = Field(..., description="ユーザー名")
    email: str = Field(..., description="メールアドレス")
    gold: int = Field(..., description="所持ゴールド")
    gems: int = Field(..., description="所持ジェム")
    shop_level: int = Field(..., description="ショップレベル")
    shop_exp: int = Field(..., description="ショップ経験値")
    reputation: int = Field(..., description="評判")
    created_at: datetime = Field(..., description="作成日時")
    last_login: datetime = Field(..., description="最終ログイン日時")
    is_active: bool = Field(..., description="アクティブフラグ")

class PlayerStatisticsResponse(BaseSchema):
    """
    プレイヤー統計レスポンス
    """
    player_id: str = Field(..., description="プレイヤーID")
    total_play_time_seconds: int = Field(..., description="総プレイ時間（秒）")
    session_count: int = Field(..., description="セッション数")
    last_session_duration: int = Field(..., description="最終セッション時間")
    total_gold_earned: int = Field(..., description="総獲得ゴールド")
    total_gold_spent: int = Field(..., description="総消費ゴールド")
    total_gems_purchased: int = Field(..., description="総購入ジェム")
    total_gems_spent: int = Field(..., description="総消費ジェム")
    weapons_crafted: int = Field(..., description="作成武器数")
    enchants_attempted: int = Field(..., description="エンチャント試行回数")
    enchants_succeeded: int = Field(..., description="エンチャント成功回数")
    trades_completed: int = Field(..., description="完了取引数")
    expeditions_sent: int = Field(..., description="派遣回数")
    highest_weapon_attack: int = Field(..., description="最高武器攻撃力")
    highest_enchant_level: int = Field(..., description="最高エンチャントレベル")
    max_daily_gold: int = Field(..., description="最高日次ゴールド")
    enchant_success_rate: float = Field(..., description="エンチャント成功率")
    average_session_duration: float = Field(..., description="平均セッション時間")
    updated_at: datetime = Field(..., description="更新日時")

class PlayerDetailResponse(BaseSchema):
    """
    プレイヤー詳細情報レスポンス
    """
    player: PlayerResponse = Field(..., description="プレイヤー基本情報")
    statistics: Optional[PlayerStatisticsResponse] = Field(None, description="プレイヤー統計")
    total_weapons: int = Field(..., description="所持武器数")
    total_materials: int = Field(..., description="所持素材種類数")

class PlayerUpdateRequest(BaseModel):
    """
    プレイヤー情報更新リクエスト
    """
    username: Optional[str] = Field(None, min_length=3, max_length=50, description="ユーザー名")
    email: Optional[str] = Field(None, description="メールアドレス")

class PlayerGoldRequest(BaseModel):
    """
    ゴールド操作リクエスト
    """
    amount: int = Field(..., gt=0, description="金額")
    reason: Optional[str] = Field(None, description="理由")

class PlayerGemsRequest(BaseModel):
    """
    ジェム操作リクエスト
    """
    amount: int = Field(..., gt=0, description="金額")
    reason: Optional[str] = Field(None, description="理由")

class PlayerAdminUpdateRequest(BaseModel):
    """
    管理者用プレイヤー情報更新リクエスト
    """
    username: Optional[str] = Field(None, min_length=3, max_length=50, description="ユーザー名")
    email: Optional[str] = Field(None, description="メールアドレス")
    gold: Optional[int] = Field(None, ge=0, description="所持ゴールド")
    gems: Optional[int] = Field(None, ge=0, description="所持ジェム")
    shop_level: Optional[int] = Field(None, ge=1, description="ショップレベル")
    reputation: Optional[int] = Field(None, description="評判")
    is_active: Optional[bool] = Field(None, description="アクティブフラグ")

class PlayerBanRequest(BaseModel):
    """
    プレイヤーBANリクエスト
    """
    reason: str = Field(..., min_length=1, max_length=500, description="BAN理由")
    expires_at: Optional[datetime] = Field(None, description="BAN解除日時（永久BANの場合はNone）")
