from fastapi import APIRouter

from app.api.v1.endpoints import auth, players, weapons, materials, crafting, adventurers, missions, idle, enchantments

api_router = APIRouter()

# 各エンドポイントを登録
api_router.include_router(auth.router, prefix="/auth", tags=["認証"])
api_router.include_router(players.router, prefix="/players", tags=["プレイヤー"])
api_router.include_router(weapons.router, prefix="/weapons", tags=["武器"])
api_router.include_router(materials.router, prefix="/materials", tags=["素材"])
api_router.include_router(crafting.router, prefix="/crafting", tags=["合成"])
api_router.include_router(adventurers.router, prefix="/admin", tags=["管理画面"])
api_router.include_router(missions.router, prefix="/missions", tags=["ミッション"])
api_router.include_router(idle.router, prefix="/idle", tags=["放置システム"])
api_router.include_router(enchantments.router, prefix="/enchantments", tags=["エンチャント"])
