from pydantic_settings import BaseSettings
from typing import List, Optional
import os

class Settings(BaseSettings):
    # アプリケーション設定
    PROJECT_NAME: str = "武器屋放置ゲーム"
    VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"
    
    # セキュリティ設定
    SECRET_KEY: str = "bukiya_secret_key_change_in_production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # データベース設定
    DATABASE_URL: str = "postgresql://bukiya_user:bukiya_password@postgres:5432/bukiya_game"
    
    # Redis設定
    REDIS_URL: str = "redis://redis:6379/0"
    
    # CORS設定
    ALLOWED_HOSTS: List[str] = ["localhost", "127.0.0.1"]
    
    # ページネーション設定
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100
    
    # ゲーム設定
    DEFAULT_PLAYER_GOLD: int = 1000
    DEFAULT_PLAYER_GEMS: int = 50
    DEFAULT_SHOP_LEVEL: int = 1
    
    # ログ設定
    LOG_LEVEL: str = "INFO"
    
    class Config:
        env_file = ".env"
        case_sensitive = True

# グローバル設定インスタンス
settings = Settings()
