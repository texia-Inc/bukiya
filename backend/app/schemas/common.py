from pydantic import BaseModel, Field
from typing import TypeVar, Generic, Optional, Any, List
from datetime import datetime
import uuid

T = TypeVar('T')

class APIResponse(BaseModel, Generic[T]):
    """
    統一APIレスポンス形式
    """
    success: bool = Field(..., description="処理成功フラグ")
    data: Optional[T] = Field(None, description="レスポンスデータ")
    message: str = Field(..., description="メッセージ")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="タイムスタンプ")
    request_id: str = Field(default_factory=lambda: str(uuid.uuid4()), description="リクエストID")

class ErrorResponse(BaseModel):
    """
    エラーレスポンス形式
    """
    success: bool = Field(False, description="処理成功フラグ")
    error: "ErrorDetail" = Field(..., description="エラー詳細")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="タイムスタンプ")
    request_id: str = Field(default_factory=lambda: str(uuid.uuid4()), description="リクエストID")

class ErrorDetail(BaseModel):
    """
    エラー詳細
    """
    code: str = Field(..., description="エラーコード")
    message: str = Field(..., description="エラーメッセージ")
    details: Optional[dict] = Field(None, description="エラー詳細情報")

class PaginationInfo(BaseModel):
    """
    ページネーション情報
    """
    current_page: int = Field(..., description="現在のページ番号")
    total_pages: int = Field(..., description="総ページ数")
    total_items: int = Field(..., description="総アイテム数")
    items_per_page: int = Field(..., description="1ページあたりのアイテム数")
    has_next: bool = Field(..., description="次のページが存在するか")
    has_prev: bool = Field(..., description="前のページが存在するか")

class PaginationResponse(BaseModel, Generic[T]):
    """
    ページネーション付きレスポンス
    """
    items: List[T] = Field(..., description="アイテムリスト")
    pagination: PaginationInfo = Field(..., description="ページネーション情報")

class BaseSchema(BaseModel):
    """
    基本スキーマクラス
    """
    class Config:
        from_attributes = True
        json_encoders = {
            datetime: lambda v: v.isoformat() + "Z" if v else None
        }

# 新しいレスポンス形式（BaseResponseとPaginatedResponse）
class BaseResponse(BaseModel, Generic[T]):
    """
    基本レスポンス形式
    """
    success: bool = Field(..., description="処理成功フラグ")
    data: Optional[T] = Field(None, description="レスポンスデータ")
    message: str = Field(..., description="メッセージ")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="タイムスタンプ")
    request_id: str = Field(default_factory=lambda: str(uuid.uuid4()), description="リクエストID")

class PaginatedResponse(BaseModel, Generic[T]):
    """
    ページネーション付きレスポンス
    """
    success: bool = Field(..., description="処理成功フラグ")
    data: List[T] = Field(..., description="データリスト")
    message: str = Field(..., description="メッセージ")
    timestamp: datetime = Field(default_factory=datetime.utcnow, description="タイムスタンプ")
    request_id: str = Field(default_factory=lambda: str(uuid.uuid4()), description="リクエストID")
    pagination: dict = Field(..., description="ページネーション情報")

# エラーレスポンスの更新
ErrorResponse.model_rebuild()
