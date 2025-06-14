from pydantic import BaseModel, Field, validator
from datetime import date, datetime
from typing import Optional


class SeasonBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, description="シーズン名")
    description: Optional[str] = Field(None, description="シーズンの説明")
    start_date: date = Field(..., description="開始日")
    end_date: Optional[date] = Field(None, description="終了日")
    display_order: int = Field(default=1, ge=1, description="表示順序")

    @validator('end_date')
    def validate_end_date(cls, v, values):
        if v and 'start_date' in values and v <= values['start_date']:
            raise ValueError('終了日は開始日より後の日付を指定してください')
        return v


class SeasonCreate(SeasonBase):
    pass


class SeasonUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=100, description="シーズン名")
    description: Optional[str] = Field(None, description="シーズンの説明")
    start_date: Optional[date] = Field(None, description="開始日")
    end_date: Optional[date] = Field(None, description="終了日")
    display_order: Optional[int] = Field(None, ge=1, description="表示順序")
    is_active: Optional[bool] = Field(None, description="有効フラグ")

    @validator('end_date')
    def validate_end_date(cls, v, values):
        if v and 'start_date' in values and values['start_date'] and v <= values['start_date']:
            raise ValueError('終了日は開始日より後の日付を指定してください')
        return v


class Season(SeasonBase):
    id: int
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True