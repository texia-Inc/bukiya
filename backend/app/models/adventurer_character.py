"""
固有冒険者キャラクターシステムのSQLAlchemyモデル
名前ありキャラクター（育成対象）のデータモデル
"""
from sqlalchemy import Column, Integer, String, Float, DateTime, Text, Boolean, UUID, ARRAY, ForeignKey
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import relationship
from datetime import datetime
from uuid import uuid4

from ..core.database import Base


class AdventurerCharacter(Base):
    """固有冒険者キャラクターマスターデータ（名前あり・育成対象）"""
    __tablename__ = "adventurer_characters"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False, index=True)
    title = Column(String(100), nullable=True)
    profession = Column(String(20), nullable=False, index=True)  # warrior, archer, mage, rogue, paladin
    rarity = Column(String(20), nullable=False, default='common', index=True)  # common, rare, epic, legendary
    
    # レベル設定
    base_level = Column(Integer, nullable=False, default=1)
    max_level = Column(Integer, nullable=False, default=50)
    max_trust_level = Column(Integer, nullable=False, default=100)
    
    # 解放条件
    unlock_player_level = Column(Integer, nullable=False, default=1, index=True)
    unlock_condition = Column(Text, nullable=True)  # JSON形式の追加条件
    
    # 能力値設定（JSON形式で柔軟性を確保）
    base_stats = Column(JSONB, default={"attack": 10, "defense": 5, "speed": 8, "magic": 3})
    growth_rates = Column(JSONB, default={"attack": 1.2, "defense": 1.1, "speed": 1.0, "magic": 1.0})
    
    # 武器・戦闘設定
    preferred_weapon_types = Column(ARRAY(String), default=[])  # 得意武器タイプの配列
    elemental_affinity = Column(String(20), nullable=True)  # fire, ice, thunder, earth, wind, light, dark, arcane
    
    # 個性・ストーリー
    personality = Column(String(50), nullable=False, default='normal')
    backstory = Column(Text, nullable=True)
    quote = Column(Text, nullable=True)  # 決め台詞
    
    # 見た目・UI設定
    avatar_url = Column(String(255), nullable=True)
    color_theme = Column(String(7), default='#4CAF50')  # UIテーマカラー
    voice_type = Column(String(20), nullable=True)  # 音声タイプ
    
    # 特殊能力・スキル（JSON形式で柔軟に拡張）
    special_abilities = Column(JSONB, default=[])  # 特殊スキルリスト
    passive_skills = Column(JSONB, default=[])     # パッシブスキル
    
    # ドラゴン討伐関連
    dragon_battle_eligible = Column(Boolean, default=False)  # ドラゴン討伐参加可能
    leadership_bonus = Column(Integer, default=0)            # リーダーシップボーナス
    team_synergy = Column(JSONB, default={})                 # チーム相性設定
    
    # 出現・管理設定
    is_story_character = Column(Boolean, default=False)      # メインストーリーキャラ
    unlock_order = Column(Integer, default=0, index=True)    # 解放順序
    is_limited_time = Column(Boolean, default=False)         # 期間限定キャラ
    availability_start = Column(DateTime, nullable=True)     # 入手可能開始日
    availability_end = Column(DateTime, nullable=True)       # 入手可能終了日
    
    # システム情報
    is_active = Column(Boolean, nullable=False, default=True, index=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # リレーションシップ
    player_bonds = relationship("PlayerCharacterBond", back_populates="character")
    adventurer_instances = relationship("AdventurerInstance", back_populates="character")
    unlock_logs = relationship("CharacterUnlockLog", back_populates="character")
    conversations = relationship("CharacterConversation", back_populates="character")

    def __repr__(self):
        return f"<AdventurerCharacter(id={self.id}, name='{self.name}', profession='{self.profession}', rarity='{self.rarity}')>"

    @property
    def display_name(self):
        """表示用の名前を取得"""
        if self.title:
            return f"{self.title} {self.name}"
        return self.name

    @property
    def rarity_weight(self):
        """レアリティの重み値を取得"""
        weights = {
            'common': 1,
            'rare': 2,
            'epic': 3,
            'legendary': 5
        }
        return weights.get(self.rarity, 1)

    def get_synergy_bonus(self, other_character_names):
        """他のキャラクターとの相性ボーナスを計算"""
        if not self.team_synergy:
            return 1.0
        
        total_bonus = 1.0
        for char_name in other_character_names:
            if char_name in self.team_synergy:
                total_bonus *= self.team_synergy[char_name]
            elif "全員" in self.team_synergy:
                total_bonus *= self.team_synergy["全員"]
        
        return total_bonus


class PlayerCharacterBond(Base):
    """プレイヤーと固有キャラクターの絆・関係データ"""
    __tablename__ = "player_character_bonds"

    id = Column(UUID, primary_key=True, default=uuid4, index=True)
    player_id = Column(UUID, ForeignKey('players.id', ondelete='CASCADE'), nullable=False, index=True)
    character_id = Column(Integer, ForeignKey('adventurer_characters.id'), nullable=False, index=True)
    
    # 関係レベル
    trust_level = Column(Integer, nullable=False, default=0, index=True)  # 信頼度 0-100
    friendship_level = Column(Integer, nullable=False, default=1)         # 絆レベル 1-10
    total_trust_points = Column(Integer, default=0)                       # 累積信頼ポイント
    
    # 交流履歴
    total_interactions = Column(Integer, default=0)           # 総交流回数
    total_weapon_gifts = Column(Integer, default=0)          # 武器プレゼント回数
    total_quests_together = Column(Integer, default=0)       # 一緒にしたクエスト数
    total_dragon_battles = Column(Integer, default=0)        # ドラゴン討伐参加回数
    
    # ステータス・進捗
    current_level = Column(Integer, default=1)               # 現在レベル
    current_experience = Column(Integer, default=0)          # 現在経験値
    is_unlocked = Column(Boolean, default=False, index=True) # 解放済みフラグ
    is_favorited = Column(Boolean, default=False)           # お気に入り設定
    
    # 装備・カスタマイズ
    equipped_weapon_id = Column(UUID, ForeignKey('player_weapons.id'), nullable=True)
    custom_nickname = Column(String(50), nullable=True)      # プレイヤーが付けたあだ名
    
    # 会話・イベント進捗（JSON形式）
    conversation_flags = Column(JSONB, default={})           # 会話フラグ
    story_progress = Column(JSONB, default={})               # ストーリー進捗
    special_events = Column(JSONB, default=[])               # 特別イベント履歴
    
    # 時間情報
    unlock_date = Column(DateTime, nullable=True)            # 解放日時
    last_interaction_at = Column(DateTime, nullable=True)    # 最後の交流日時
    last_level_up_at = Column(DateTime, nullable=True)       # 最後のレベルアップ日時
    
    # システム情報
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    updated_at = Column(DateTime, nullable=False, default=datetime.utcnow, onupdate=datetime.utcnow)

    # リレーションシップ
    character = relationship("AdventurerCharacter", back_populates="player_bonds")
    equipped_weapon = relationship("PlayerWeapon")

    def __repr__(self):
        return f"<PlayerCharacterBond(player_id={self.player_id}, character_id={self.character_id}, trust_level={self.trust_level})>"

    @property
    def display_name(self):
        """表示用の名前（あだ名がある場合はそちらを優先）"""
        if self.custom_nickname:
            return self.custom_nickname
        return self.character.name if self.character else "Unknown"

    @property
    def next_level_exp(self):
        """次のレベルまでの必要経験値"""
        return self.current_level * 100  # 簡単な計算式

    @property
    def trust_percentage(self):
        """信頼度のパーセンテージ"""
        max_trust = self.character.max_trust_level if self.character else 100
        return min(100, (self.trust_level / max_trust) * 100)

    def can_participate_dragon_battle(self):
        """ドラゴン討伐に参加可能かチェック"""
        if not self.character or not self.character.dragon_battle_eligible:
            return False
        return self.trust_level >= 50 and self.current_level >= 10

    def add_trust_points(self, points):
        """信頼ポイントを追加し、レベルアップをチェック"""
        self.total_trust_points += points
        self.trust_level = min(self.character.max_trust_level, self.trust_level + points)
        
        # 絆レベルアップのチェック
        required_trust_for_next_level = self.friendship_level * 20
        if self.trust_level >= required_trust_for_next_level and self.friendship_level < 10:
            self.friendship_level += 1
            self.last_level_up_at = datetime.utcnow()
            return True  # レベルアップした
        return False


class CharacterUnlockLog(Base):
    """キャラクター解放履歴ログ"""
    __tablename__ = "character_unlock_logs"

    id = Column(UUID, primary_key=True, default=uuid4, index=True)
    player_id = Column(UUID, ForeignKey('players.id', ondelete='CASCADE'), nullable=False, index=True)
    character_id = Column(Integer, ForeignKey('adventurer_characters.id'), nullable=False)
    unlock_method = Column(String(50), nullable=False)  # level_up, quest_complete, event, purchase
    unlock_condition_met = Column(Text, nullable=True)  # 満たした解放条件の詳細
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    # リレーションシップ
    character = relationship("AdventurerCharacter", back_populates="unlock_logs")

    def __repr__(self):
        return f"<CharacterUnlockLog(player_id={self.player_id}, character_id={self.character_id}, method='{self.unlock_method}')>"


class CharacterConversation(Base):
    """キャラクターとの会話履歴ログ"""
    __tablename__ = "character_conversations"

    id = Column(UUID, primary_key=True, default=uuid4, index=True)
    player_id = Column(UUID, ForeignKey('players.id', ondelete='CASCADE'), nullable=False, index=True)
    character_id = Column(Integer, ForeignKey('adventurer_characters.id'), nullable=False, index=True)
    conversation_type = Column(String(50), nullable=False)  # greeting, gift, quest, story, random
    conversation_text = Column(Text, nullable=True)         # 会話内容
    trust_gained = Column(Integer, default=0)               # 獲得した信頼度
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)

    # リレーションシップ
    character = relationship("AdventurerCharacter", back_populates="conversations")

    def __repr__(self):
        return f"<CharacterConversation(player_id={self.player_id}, character_id={self.character_id}, type='{self.conversation_type}')>"


