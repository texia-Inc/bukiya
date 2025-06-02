from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
import redis
from typing import Generator

from app.core.config import settings

# SQLAlchemy設定
engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    echo=True if settings.ENVIRONMENT == "development" else False,
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

# Redis接続
redis_client = redis.from_url(
    settings.REDIS_URL,
    encoding="utf-8",
    decode_responses=True
)

# データベースセッション依存性
def get_db() -> Generator:
    """
    データベースセッションを取得する依存性関数
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Redis接続依存性
def get_redis():
    """
    Redis接続を取得する依存性関数
    """
    return redis_client

# データベース接続テスト
def test_db_connection():
    """
    データベース接続をテストする
    """
    try:
        db = SessionLocal()
        db.execute("SELECT 1")
        db.close()
        return True
    except Exception as e:
        print(f"Database connection failed: {e}")
        return False

# Redis接続テスト
def test_redis_connection():
    """
    Redis接続をテストする
    """
    try:
        redis_client.ping()
        return True
    except Exception as e:
        print(f"Redis connection failed: {e}")
        return False
