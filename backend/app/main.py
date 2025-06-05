from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import structlog
from datetime import datetime
import uuid

from app.core.config import settings
from app.core.database import engine, Base
from app.api.v1.api import api_router

# ログ設定
logger = structlog.get_logger()

# FastAPIアプリケーション初期化
app = FastAPI(
    title="武器屋放置ゲーム API",
    description="武器屋経営放置ゲームのバックエンドAPI",
    version="1.0.0",
    docs_url="/docs" if settings.ENVIRONMENT == "development" else None,
    redoc_url="/redoc" if settings.ENVIRONMENT == "development" else None,
)

# CORS設定
if settings.ENVIRONMENT == "development":
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[
            "*",
            "http://localhost:3000",
            "http://127.0.0.1:3000",
            "http://localhost:8080",
            "http://127.0.0.1:8080"
        ],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
else:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[f"http://{host}" for host in settings.ALLOWED_HOSTS] + [f"https://{host}" for host in settings.ALLOWED_HOSTS],
        allow_credentials=True,
        allow_methods=["GET", "POST", "PUT", "DELETE"],
        allow_headers=["*"],
    )

# APIルーター登録
app.include_router(api_router, prefix="/api/v1")

# グローバル例外ハンドラー
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": {
                "code": f"HTTP_{exc.status_code}",
                "message": exc.detail,
                "details": {}
            },
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "request_id": str(uuid.uuid4())
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    logger.error("Unhandled exception", exc_info=exc)
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": {
                "code": "INTERNAL_SERVER_ERROR",
                "message": "内部サーバーエラーが発生しました",
                "details": {}
            },
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "request_id": str(uuid.uuid4())
        }
    )

# ヘルスチェックエンドポイント
@app.get("/health")
async def health_check():
    return {
        "success": True,
        "data": {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "version": "1.0.0",
            "environment": settings.ENVIRONMENT
        },
        "message": "API is running",
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "request_id": str(uuid.uuid4())
    }

# アプリケーション起動時の処理
@app.on_event("startup")
async def startup_event():
    logger.info("Starting 武器屋放置ゲーム API", environment=settings.ENVIRONMENT)
    
    # データベーステーブル作成（開発環境のみ）
    if settings.ENVIRONMENT == "development":
        Base.metadata.create_all(bind=engine)
        logger.info("Database tables created")

# アプリケーション終了時の処理
@app.on_event("shutdown")
async def shutdown_event():
    logger.info("Shutting down 武器屋放置ゲーム API")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "app.main:app",
        host="0.0.0.0",
        port=8000,
        reload=True if settings.ENVIRONMENT == "development" else False
    )
