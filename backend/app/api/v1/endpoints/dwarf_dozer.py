"""
ドワーフドーザー（ブラウザ版の採掘ゲーム）用のオンライン機能

- ステージ別のクリアタイムランキング
- ワールドドラゴン（全プレイヤーで1週間かけて削る共有ボス）

データは Redis に置く:
    dd:board:{board}           ZSET  player_id -> クリア秒数（小さいほど上位）
    dd:names                   HASH  player_id -> 表示名
    dd:dragon:{season}:dealt   STR   その週の累計ダメージ
    dd:dragon:{season}:top     ZSET  player_id -> その週の貢献ダメージ
    dd:rl:{player_id}          STR   送信間隔の制限用（短い TTL）

プレイヤーはクライアントが生成したランダム ID で識別する（ログイン不要の簡易方式）。
"""
import re
from datetime import datetime, timedelta, timezone
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from pydantic import BaseModel, Field

from app.core.database import get_redis

router = APIRouter()

JST = timezone(timedelta(hours=9))
BOARDS = {f"m{i}" for i in range(10)} | {f"l{i}" for i in range(3)}
MIN_CLEAR_SECONDS = {"m": 60, "l": 30}     # これより速いクリアは不正とみなす
MAX_CLEAR_SECONDS = 7 * 24 * 3600
WORLD_MAX = 3_000_000                      # ワールドドラゴンの体力（全プレイヤー合計で削る）
MAX_HIT = 5000                             # 1回の送信で加算できる上限
HIT_INTERVAL_SECONDS = 4                   # 同じプレイヤーの送信間隔の下限
SEASON_TTL_SECONDS = 21 * 24 * 3600

PLAYER_ID = r"^[A-Za-z0-9]{8,40}$"
SEASON_ID = r"^\d{4}-W\d{2}$"


def clean_name(name: str) -> str:
    name = re.sub(r"[\x00-\x1f\x7f<>]", "", name).strip()[:16]
    return name or "ドワーフ"


def current_season(now: Optional[datetime] = None) -> tuple[str, datetime]:
    """日本時間の ISO 週（月曜0時に切り替わる）。(シーズンID, 終了時刻) を返す。"""
    now = (now or datetime.now(timezone.utc)).astimezone(JST)
    year, week, weekday = now.isocalendar()
    monday = (now - timedelta(days=weekday - 1)).replace(hour=0, minute=0, second=0, microsecond=0)
    return f"{year}-W{week:02d}", monday + timedelta(days=7)


class ScoreIn(BaseModel):
    player_id: str = Field(pattern=PLAYER_ID)
    name: str = Field(min_length=1, max_length=32)
    board: str
    time: int = Field(ge=1, le=MAX_CLEAR_SECONDS)


class HitIn(BaseModel):
    player_id: str = Field(pattern=PLAYER_ID)
    name: str = Field(min_length=1, max_length=32)
    season: str = Field(pattern=SEASON_ID)
    dmg: int = Field(ge=1, le=MAX_HIT)


def board_state(r, board: str, player_id: Optional[str], limit: int) -> dict:
    key = f"dd:board:{board}"
    entries = r.zrange(key, 0, limit - 1, withscores=True)
    names = r.hmget("dd:names", [pid for pid, _ in entries]) if entries else []
    rows = [
        {"rank": i + 1, "player_id": pid, "name": names[i] or "ドワーフ", "time": int(score)}
        for i, (pid, score) in enumerate(entries)
    ]
    you = None
    if player_id:
        rank = r.zrank(key, player_id)
        if rank is not None:
            you = {"rank": rank + 1, "time": int(r.zscore(key, player_id))}
    return {"board": board, "total": r.zcard(key), "rows": rows, "you": you}


def dragon_state(r, player_id: Optional[str]) -> dict:
    season, ends_at = current_season()
    top_key = f"dd:dragon:{season}:top"
    dealt = int(r.get(f"dd:dragon:{season}:dealt") or 0)
    entries = r.zrevrange(top_key, 0, 9, withscores=True)
    names = r.hmget("dd:names", [pid for pid, _ in entries]) if entries else []
    you = None
    if player_id:
        score = r.zscore(top_key, player_id)
        if score is not None:
            you = {"rank": r.zrevrank(top_key, player_id) + 1, "dmg": int(score)}
    return {
        "season": season,
        "ends_at": ends_at.isoformat(),
        "max": WORLD_MAX,
        "dealt": min(dealt, WORLD_MAX),
        "defeated": dealt >= WORLD_MAX,
        "players": r.zcard(top_key),
        "top": [{"player_id": pid, "name": names[i] or "ドワーフ", "dmg": int(s)} for i, (pid, s) in enumerate(entries)],
        "you": you,
    }


@router.post("/scores")
def submit_score(body: ScoreIn, r=Depends(get_redis)):
    """クリアタイムを登録する。自己ベストより遅い記録は無視される。"""
    if body.board not in BOARDS:
        raise HTTPException(status_code=400, detail="unknown board")
    if body.time < MIN_CLEAR_SECONDS[body.board[0]]:
        raise HTTPException(status_code=400, detail="time too short")
    r.hset("dd:names", body.player_id, clean_name(body.name))
    r.zadd(f"dd:board:{body.board}", {body.player_id: body.time}, lt=True)
    return board_state(r, body.board, body.player_id, 10)


@router.get("/scores/{board}")
def get_scores(board: str, player_id: Optional[str] = Query(None, pattern=PLAYER_ID),
               limit: int = Query(10, ge=1, le=100), r=Depends(get_redis)):
    """ステージのランキング（速い順）。player_id を渡すと自分の順位も返す。"""
    if board not in BOARDS:
        raise HTTPException(status_code=404, detail="unknown board")
    return board_state(r, board, player_id, limit)


@router.get("/dragon")
def get_dragon(player_id: Optional[str] = Query(None, pattern=PLAYER_ID), r=Depends(get_redis)):
    """今週のワールドドラゴンの状態。"""
    return dragon_state(r, player_id)


@router.post("/dragon/hit")
def hit_dragon(body: HitIn, r=Depends(get_redis)):
    """ワールドドラゴンにダメージを加算する。"""
    season, _ = current_season()
    if body.season != season:
        raise HTTPException(status_code=409, detail="season changed")
    if not r.set(f"dd:rl:{body.player_id}", 1, nx=True, ex=HIT_INTERVAL_SECONDS):
        raise HTTPException(status_code=429, detail="too many requests")
    r.hset("dd:names", body.player_id, clean_name(body.name))
    dealt_key, top_key = f"dd:dragon:{season}:dealt", f"dd:dragon:{season}:top"
    r.incrby(dealt_key, body.dmg)
    r.zincrby(top_key, body.dmg, body.player_id)
    r.expire(dealt_key, SEASON_TTL_SECONDS)
    r.expire(top_key, SEASON_TTL_SECONDS)
    return dragon_state(r, body.player_id)
