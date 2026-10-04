from fastapi import APIRouter

from app.api.v1.endpoints import auth, players, weapons, materials, crafting, adventurers, missions, idle, enchantments, adventurer_instances, shop, device_auth, recipes, monsters, dashboard, master_data, idle_income, adventurer_characters, seasons
from app.api.v1.endpoints import dwarf_dozer
# 一時的に無効化 (openaiモジュール未インストールのため)
# from app.api.v1.endpoints import image_generation
# 一時的に無効化 (依存関係の問題)
# from app.api.v1.endpoints import adventurer_relations, adventurer_migration, adventurer_progression
# from app.api.v1.endpoints import dragon_events

api_router = APIRouter()

# 各エンドポイントを登録
api_router.include_router(auth.router, prefix="/auth", tags=["認証"])
api_router.include_router(players.router, prefix="/players", tags=["プレイヤー"])
api_router.include_router(weapons.router, prefix="/weapons", tags=["武器"])
api_router.include_router(materials.router, prefix="/materials", tags=["素材"])
api_router.include_router(crafting.router, prefix="/crafting", tags=["合成"])
api_router.include_router(adventurers.router, prefix="/admin", tags=["管理画面"])
api_router.include_router(adventurer_instances.router, prefix="/adventurers", tags=["冒険者"])
api_router.include_router(missions.router, prefix="/missions", tags=["ミッション"])
api_router.include_router(idle.router, prefix="/idle", tags=["放置システム"])
api_router.include_router(idle_income.router, prefix="/idle-income", tags=["放置収入"])
api_router.include_router(enchantments.router, prefix="/enchantments", tags=["エンチャント"])
api_router.include_router(shop.router, prefix="/shop", tags=["ショップ"])
api_router.include_router(device_auth.router, prefix="/auth", tags=["デバイス認証"])
api_router.include_router(recipes.router, prefix="/recipes", tags=["レシピ"])
api_router.include_router(monsters.router, prefix="/monsters", tags=["モンスター"])
api_router.include_router(seasons.router, prefix="/seasons", tags=["シーズン"])
api_router.include_router(dashboard.router, prefix="/dashboard", tags=["ダッシュボード"])
api_router.include_router(master_data.router, prefix="", tags=["マスターデータ"])
# 一時的に無効化（依存関係の問題）
# api_router.include_router(adventurer_relations.router, prefix="/adventurer-relations", tags=["冒険者関係"])
# api_router.include_router(adventurer_migration.router, prefix="/adventurer-migration", tags=["冒険者移行"])
# api_router.include_router(adventurer_progression.router, prefix="/adventurer-progression", tags=["冒険者成長"])
api_router.include_router(adventurer_characters.router, prefix="/characters", tags=["固有キャラクター"])
api_router.include_router(dwarf_dozer.router, prefix="/dwarf-dozer", tags=["ドワーフドーザー"])
# 一時的に無効化 (openaiモジュール未インストールのため)
# api_router.include_router(image_generation.router, prefix="/image-generation", tags=["画像生成"])
# api_router.include_router(dragon_events.router, prefix="/dragon-events", tags=["ドラゴンイベント"])
