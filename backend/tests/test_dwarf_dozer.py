"""ドワーフドーザーのオンライン API のテスト（Redis は fakeredis で代用）"""
from datetime import datetime, timezone

import fakeredis
import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from app.api.v1.endpoints import dwarf_dozer
from app.core.database import get_redis

P1, P2 = "player0000000001", "player0000000002"


@pytest.fixture
def client():
    fake = fakeredis.FakeRedis(decode_responses=True)
    app = FastAPI()
    app.include_router(dwarf_dozer.router, prefix="/dwarf-dozer")
    app.dependency_overrides[get_redis] = lambda: fake
    return TestClient(app)


def test_scores_keep_personal_best_and_rank(client):
    client.post("/dwarf-dozer/scores", json={"player_id": P1, "name": "ギムリ", "board": "m0", "time": 700})
    client.post("/dwarf-dozer/scores", json={"player_id": P2, "name": "トーリン", "board": "m0", "time": 650})
    # 遅い記録では自己ベストは変わらない
    res = client.post("/dwarf-dozer/scores", json={"player_id": P1, "name": "ギムリ", "board": "m0", "time": 900}).json()
    assert res["you"] == {"rank": 2, "time": 700}
    # 速い記録で更新される
    res = client.post("/dwarf-dozer/scores", json={"player_id": P1, "name": "ギムリ", "board": "m0", "time": 600}).json()
    assert [r["name"] for r in res["rows"]] == ["ギムリ", "トーリン"]
    assert res["total"] == 2

    res = client.get(f"/dwarf-dozer/scores/m0?player_id={P2}").json()
    assert res["you"] == {"rank": 2, "time": 650}


def test_scores_reject_bad_input(client):
    base = {"player_id": P1, "name": "x", "time": 700}
    assert client.post("/dwarf-dozer/scores", json={**base, "board": "m99"}).status_code == 400
    assert client.post("/dwarf-dozer/scores", json={**base, "board": "m0", "time": 10}).status_code == 400
    assert client.post("/dwarf-dozer/scores", json={**base, "board": "m0", "player_id": "bad id!"}).status_code == 422
    assert client.get("/dwarf-dozer/scores/zzz").status_code == 404


def test_names_are_sanitized(client):
    res = client.post("/dwarf-dozer/scores", json={"player_id": P1, "name": "<b>ドワ\x00ーフ</b>王" * 2, "board": "l0", "time": 120}).json()
    name = res["rows"][0]["name"]
    assert "<" not in name and "\x00" not in name and len(name) <= 16


def test_world_dragon_accumulates_and_ranks(client):
    season = client.get("/dwarf-dozer/dragon").json()["season"]
    client.post("/dwarf-dozer/dragon/hit", json={"player_id": P1, "name": "ギムリ", "season": season, "dmg": 300})
    res = client.post("/dwarf-dozer/dragon/hit", json={"player_id": P2, "name": "トーリン", "season": season, "dmg": 500}).json()
    assert res["dealt"] == 800 and res["players"] == 2
    assert [t["name"] for t in res["top"]] == ["トーリン", "ギムリ"]
    assert res["you"] == {"rank": 1, "dmg": 500}
    assert res["max"] == dwarf_dozer.WORLD_MAX and res["defeated"] is False


def test_world_dragon_limits(client):
    season = client.get("/dwarf-dozer/dragon").json()["season"]
    hit = {"player_id": P1, "name": "ギムリ", "season": season, "dmg": 100}
    assert client.post("/dwarf-dozer/dragon/hit", json=hit).status_code == 200
    assert client.post("/dwarf-dozer/dragon/hit", json=hit).status_code == 429          # 連打
    assert client.post("/dwarf-dozer/dragon/hit", json={**hit, "player_id": P2, "dmg": 999999}).status_code == 422
    assert client.post("/dwarf-dozer/dragon/hit", json={**hit, "player_id": P2, "season": "2000-W01"}).status_code == 409


def test_season_switches_on_monday_jst():
    # 2026-10-04 23:59 JST は日曜 → W40、10-05 00:00 JST から W41
    sunday = datetime(2026, 10, 4, 14, 59, tzinfo=timezone.utc)
    monday = datetime(2026, 10, 4, 15, 0, tzinfo=timezone.utc)
    assert dwarf_dozer.current_season(sunday)[0] == "2026-W40"
    assert dwarf_dozer.current_season(monday)[0] == "2026-W41"
    assert dwarf_dozer.current_season(sunday)[1].isoformat() == "2026-10-05T00:00:00+09:00"
