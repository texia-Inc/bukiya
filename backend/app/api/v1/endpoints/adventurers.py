from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from ....core.dependencies import get_db
from ....models.adventurer_master import AdventurerMaster, MonsterMaster, QuestAreaMaster, MonsterDropTable
from ....schemas.adventurer import (
    AdventurerMaster as AdventurerMasterSchema,
    AdventurerMasterCreate,
    AdventurerMasterUpdate,
    AdventurerMasterListResponse,
    MonsterMaster as MonsterMasterSchema,
    MonsterMasterCreate,
    MonsterMasterUpdate,
    MonsterMasterListResponse,
    QuestAreaMaster as QuestAreaMasterSchema,
    QuestAreaMasterCreate,
    QuestAreaMasterUpdate,
    QuestAreaMasterListResponse,
    MonsterDropTable as MonsterDropTableSchema,
    MonsterDropTableCreate,
    MonsterDropTableUpdate,
    MonsterDropTableListResponse,
)

router = APIRouter()

# 冒険者マスター管理エンドポイント
@router.get("/adventurers", response_model=AdventurerMasterListResponse)
def get_adventurers(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりの件数"),
    search: Optional[str] = Query(None, description="検索キーワード"),
    profession: Optional[str] = Query(None, description="職業フィルター"),
    is_active: Optional[bool] = Query(None, description="有効フラグフィルター"),
    db: Session = Depends(get_db)
):
    """冒険者マスター一覧取得"""
    query = db.query(AdventurerMaster)
    
    # フィルター適用
    if search:
        query = query.filter(AdventurerMaster.name.contains(search))
    if profession:
        query = query.filter(AdventurerMaster.profession == profession)
    if is_active is not None:
        query = query.filter(AdventurerMaster.is_active == is_active)
    
    # 総件数取得
    total = query.count()
    
    # ページネーション
    offset = (page - 1) * limit
    adventurers = query.offset(offset).limit(limit).all()
    
    return AdventurerMasterListResponse(
        adventurers=adventurers,
        total=total,
        page=page,
        limit=limit
    )

@router.get("/adventurers/{adventurer_id}", response_model=AdventurerMasterSchema)
def get_adventurer(adventurer_id: str, db: Session = Depends(get_db)):
    """冒険者マスター詳細取得"""
    adventurer = db.query(AdventurerMaster).filter(AdventurerMaster.id == adventurer_id).first()
    if not adventurer:
        raise HTTPException(status_code=404, detail="冒険者が見つかりません")
    return adventurer

@router.post("/adventurers", response_model=AdventurerMasterSchema)
def create_adventurer(adventurer: AdventurerMasterCreate, db: Session = Depends(get_db)):
    """冒険者マスター作成"""
    # 名前の重複チェック
    existing = db.query(AdventurerMaster).filter(AdventurerMaster.name == adventurer.name).first()
    if existing:
        raise HTTPException(status_code=400, detail="同じ名前の冒険者が既に存在します")
    
    # 予算の妥当性チェック
    if adventurer.budget_min > adventurer.budget_max:
        raise HTTPException(status_code=400, detail="最小予算は最大予算以下である必要があります")
    
    db_adventurer = AdventurerMaster(**adventurer.dict())
    db.add(db_adventurer)
    db.commit()
    db.refresh(db_adventurer)
    return db_adventurer

@router.put("/adventurers/{adventurer_id}", response_model=AdventurerMasterSchema)
def update_adventurer(
    adventurer_id: str,
    adventurer: AdventurerMasterUpdate,
    db: Session = Depends(get_db)
):
    """冒険者マスター更新"""
    db_adventurer = db.query(AdventurerMaster).filter(AdventurerMaster.id == adventurer_id).first()
    if not db_adventurer:
        raise HTTPException(status_code=404, detail="冒険者が見つかりません")
    
    # 更新データの適用
    update_data = adventurer.dict(exclude_unset=True)
    
    # 名前の重複チェック（自分以外）
    if "name" in update_data:
        existing = db.query(AdventurerMaster).filter(
            AdventurerMaster.name == update_data["name"],
            AdventurerMaster.id != adventurer_id
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="同じ名前の冒険者が既に存在します")
    
    # 予算の妥当性チェック
    budget_min = update_data.get("budget_min", db_adventurer.budget_min)
    budget_max = update_data.get("budget_max", db_adventurer.budget_max)
    if budget_min > budget_max:
        raise HTTPException(status_code=400, detail="最小予算は最大予算以下である必要があります")
    
    for field, value in update_data.items():
        setattr(db_adventurer, field, value)
    
    db.commit()
    db.refresh(db_adventurer)
    return db_adventurer

@router.delete("/adventurers/{adventurer_id}")
def delete_adventurer(adventurer_id: str, db: Session = Depends(get_db)):
    """冒険者マスター削除"""
    db_adventurer = db.query(AdventurerMaster).filter(AdventurerMaster.id == adventurer_id).first()
    if not db_adventurer:
        raise HTTPException(status_code=404, detail="冒険者が見つかりません")
    
    db.delete(db_adventurer)
    db.commit()
    return {"message": "冒険者を削除しました"}

# モンスターマスター管理エンドポイント
@router.get("/monsters", response_model=MonsterMasterListResponse)
def get_monsters(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりの件数"),
    search: Optional[str] = Query(None, description="検索キーワード"),
    monster_type: Optional[str] = Query(None, description="モンスタータイプフィルター"),
    is_active: Optional[bool] = Query(None, description="有効フラグフィルター"),
    db: Session = Depends(get_db)
):
    """モンスターマスター一覧取得"""
    query = db.query(MonsterMaster)
    
    # フィルター適用
    if search:
        query = query.filter(MonsterMaster.name.contains(search))
    if monster_type:
        query = query.filter(MonsterMaster.monster_type == monster_type)
    if is_active is not None:
        query = query.filter(MonsterMaster.is_active == is_active)
    
    # 総件数取得
    from sqlalchemy import func
    total = db.query(func.count(MonsterMaster.id)).filter(MonsterMaster.is_active == True).scalar()
    
    # ページネーション
    offset = (page - 1) * limit
    monsters = query.offset(offset).limit(limit).all()
    
    return MonsterMasterListResponse(
        monsters=monsters,
        total=total,
        page=page,
        limit=limit
    )

@router.get("/monsters/{monster_id}", response_model=MonsterMasterSchema)
def get_monster(monster_id: str, db: Session = Depends(get_db)):
    """モンスターマスター詳細取得"""
    monster = db.query(MonsterMaster).filter(MonsterMaster.id == monster_id).first()
    if not monster:
        raise HTTPException(status_code=404, detail="モンスターが見つかりません")
    return monster

@router.post("/monsters", response_model=MonsterMasterSchema)
def create_monster(monster: MonsterMasterCreate, db: Session = Depends(get_db)):
    """モンスターマスター作成"""
    # 名前の重複チェック
    existing = db.query(MonsterMaster).filter(MonsterMaster.name == monster.name).first()
    if existing:
        raise HTTPException(status_code=400, detail="同じ名前のモンスターが既に存在します")
    
    db_monster = MonsterMaster(**monster.dict())
    db.add(db_monster)
    db.commit()
    db.refresh(db_monster)
    return db_monster

@router.put("/monsters/{monster_id}", response_model=MonsterMasterSchema)
def update_monster(
    monster_id: str,
    monster: MonsterMasterUpdate,
    db: Session = Depends(get_db)
):
    """モンスターマスター更新"""
    db_monster = db.query(MonsterMaster).filter(MonsterMaster.id == monster_id).first()
    if not db_monster:
        raise HTTPException(status_code=404, detail="モンスターが見つかりません")
    
    # 更新データの適用
    update_data = monster.dict(exclude_unset=True)
    
    # 名前の重複チェック（自分以外）
    if "name" in update_data:
        existing = db.query(MonsterMaster).filter(
            MonsterMaster.name == update_data["name"],
            MonsterMaster.id != monster_id
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="同じ名前のモンスターが既に存在します")
    
    for field, value in update_data.items():
        setattr(db_monster, field, value)
    
    db.commit()
    db.refresh(db_monster)
    return db_monster

@router.delete("/monsters/{monster_id}")
def delete_monster(monster_id: str, db: Session = Depends(get_db)):
    """モンスターマスター削除"""
    db_monster = db.query(MonsterMaster).filter(MonsterMaster.id == monster_id).first()
    if not db_monster:
        raise HTTPException(status_code=404, detail="モンスターが見つかりません")
    
    # 関連するドロップテーブルも削除
    db.query(MonsterDropTable).filter(MonsterDropTable.monster_id == monster_id).delete()
    
    db.delete(db_monster)
    db.commit()
    return {"message": "モンスターを削除しました"}

# クエストエリアマスター管理エンドポイント
@router.get("/quest-areas", response_model=QuestAreaMasterListResponse)
def get_quest_areas(
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりの件数"),
    search: Optional[str] = Query(None, description="検索キーワード"),
    is_active: Optional[bool] = Query(None, description="有効フラグフィルター"),
    db: Session = Depends(get_db)
):
    """クエストエリアマスター一覧取得"""
    query = db.query(QuestAreaMaster)
    
    # フィルター適用
    if search:
        query = query.filter(QuestAreaMaster.name.contains(search))
    if is_active is not None:
        query = query.filter(QuestAreaMaster.is_active == is_active)
    
    # 表示順序でソート
    query = query.order_by(QuestAreaMaster.display_order, QuestAreaMaster.id)
    
    # 総件数取得
    total = query.count()
    
    # ページネーション
    offset = (page - 1) * limit
    areas = query.offset(offset).limit(limit).all()
    
    return QuestAreaMasterListResponse(
        areas=areas,
        total=total,
        page=page,
        limit=limit
    )

@router.get("/quest-areas/{area_id}", response_model=QuestAreaMasterSchema)
def get_quest_area(area_id: int, db: Session = Depends(get_db)):
    """クエストエリアマスター詳細取得"""
    area = db.query(QuestAreaMaster).filter(QuestAreaMaster.id == area_id).first()
    if not area:
        raise HTTPException(status_code=404, detail="クエストエリアが見つかりません")
    return area

@router.post("/quest-areas", response_model=QuestAreaMasterSchema)
def create_quest_area(area: QuestAreaMasterCreate, db: Session = Depends(get_db)):
    """クエストエリアマスター作成"""
    # 名前の重複チェック
    existing = db.query(QuestAreaMaster).filter(QuestAreaMaster.name == area.name).first()
    if existing:
        raise HTTPException(status_code=400, detail="同じ名前のクエストエリアが既に存在します")
    
    db_area = QuestAreaMaster(**area.dict())
    db.add(db_area)
    db.commit()
    db.refresh(db_area)
    return db_area

@router.put("/quest-areas/{area_id}", response_model=QuestAreaMasterSchema)
def update_quest_area(
    area_id: int,
    area: QuestAreaMasterUpdate,
    db: Session = Depends(get_db)
):
    """クエストエリアマスター更新"""
    db_area = db.query(QuestAreaMaster).filter(QuestAreaMaster.id == area_id).first()
    if not db_area:
        raise HTTPException(status_code=404, detail="クエストエリアが見つかりません")
    
    # 更新データの適用
    update_data = area.dict(exclude_unset=True)
    
    # 名前の重複チェック（自分以外）
    if "name" in update_data:
        existing = db.query(QuestAreaMaster).filter(
            QuestAreaMaster.name == update_data["name"],
            QuestAreaMaster.id != area_id
        ).first()
        if existing:
            raise HTTPException(status_code=400, detail="同じ名前のクエストエリアが既に存在します")
    
    for field, value in update_data.items():
        setattr(db_area, field, value)
    
    db.commit()
    db.refresh(db_area)
    return db_area

@router.delete("/quest-areas/{area_id}")
def delete_quest_area(area_id: int, db: Session = Depends(get_db)):
    """クエストエリアマスター削除"""
    db_area = db.query(QuestAreaMaster).filter(QuestAreaMaster.id == area_id).first()
    if not db_area:
        raise HTTPException(status_code=404, detail="クエストエリアが見つかりません")
    
    db.delete(db_area)
    db.commit()
    return {"message": "クエストエリアを削除しました"}

# ドロップテーブル管理エンドポイント
@router.get("/monsters/{monster_id}/drops", response_model=MonsterDropTableListResponse)
def get_monster_drops(
    monster_id: int,
    page: int = Query(1, ge=1, description="ページ番号"),
    limit: int = Query(20, ge=1, le=100, description="1ページあたりの件数"),
    db: Session = Depends(get_db)
):
    """モンスターのドロップテーブル取得"""
    # モンスターの存在確認
    monster = db.query(MonsterMaster).filter(MonsterMaster.id == monster_id).first()
    if not monster:
        raise HTTPException(status_code=404, detail="モンスターが見つかりません")
    
    query = db.query(MonsterDropTable).filter(MonsterDropTable.monster_id == monster_id)
    
    # 総件数取得
    total = query.count()
    
    # ページネーション
    offset = (page - 1) * limit
    drops = query.offset(offset).limit(limit).all()
    
    return MonsterDropTableListResponse(
        drops=drops,
        total=total,
        page=page,
        limit=limit
    )

@router.post("/monsters/{monster_id}/drops", response_model=MonsterDropTableSchema)
def create_monster_drop(
    monster_id: int,
    drop: MonsterDropTableCreate,
    db: Session = Depends(get_db)
):
    """モンスターのドロップテーブル作成"""
    # モンスターの存在確認
    monster = db.query(MonsterMaster).filter(MonsterMaster.id == monster_id).first()
    if not monster:
        raise HTTPException(status_code=404, detail="モンスターが見つかりません")
    
    # monster_idを設定
    drop_data = drop.dict()
    drop_data["monster_id"] = monster_id
    
    db_drop = MonsterDropTable(**drop_data)
    db.add(db_drop)
    db.commit()
    db.refresh(db_drop)
    return db_drop

@router.put("/drops/{drop_id}", response_model=MonsterDropTableSchema)
def update_monster_drop(
    drop_id: int,
    drop: MonsterDropTableUpdate,
    db: Session = Depends(get_db)
):
    """ドロップテーブル更新"""
    db_drop = db.query(MonsterDropTable).filter(MonsterDropTable.id == drop_id).first()
    if not db_drop:
        raise HTTPException(status_code=404, detail="ドロップテーブルが見つかりません")
    
    # 更新データの適用
    update_data = drop.dict(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_drop, field, value)
    
    db.commit()
    db.refresh(db_drop)
    return db_drop

@router.delete("/drops/{drop_id}")
def delete_monster_drop(drop_id: int, db: Session = Depends(get_db)):
    """ドロップテーブル削除"""
    db_drop = db.query(MonsterDropTable).filter(MonsterDropTable.id == drop_id).first()
    if not db_drop:
        raise HTTPException(status_code=404, detail="ドロップテーブルが見つかりません")
    
    db.delete(db_drop)
    db.commit()
    return {"message": "ドロップテーブルを削除しました"}
