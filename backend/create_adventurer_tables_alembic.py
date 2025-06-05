"""
冒険者システムのテーブル作成スクリプト（Alembic使用）
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql
import uuid

def create_adventurer_tables():
    # 冒険者インスタンステーブル
    op.create_table('adventurer_instances',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('adventurer_master_id', sa.String(50), sa.ForeignKey('adventurer_masters.id'), nullable=False),
        sa.Column('player_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('players.id', ondelete='SET NULL')),
        sa.Column('name', sa.String(100), nullable=False),
        sa.Column('level', sa.Integer, nullable=False, default=1),
        sa.Column('trust_level', sa.Integer, nullable=False, default=0),
        sa.Column('status', sa.String(20), nullable=False, default='idle'),
        sa.Column('current_quest_id', postgresql.UUID(as_uuid=True)),
        sa.Column('visit_start_time', sa.DateTime(timezone=True)),
        sa.Column('visit_end_time', sa.DateTime(timezone=True)),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'))
    )
    
    # 冒険者の武器リクエストテーブル
    op.create_table('adventurer_requests',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('adventurer_instance_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('adventurer_instances.id', ondelete='CASCADE'), nullable=False),
        sa.Column('weapon_type', sa.String(50), nullable=False),
        sa.Column('min_attack', sa.Integer, nullable=False),
        sa.Column('max_budget', sa.Integer, nullable=False),
        sa.Column('preferred_rarity', sa.String(20)),
        sa.Column('urgency', sa.Integer, nullable=False, default=3),
        sa.Column('description', sa.Text),
        sa.Column('deadline', sa.DateTime(timezone=True), nullable=False),
        sa.Column('status', sa.String(20), nullable=False, default='pending'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'))
    )
    
    # 冒険者のクエスト履歴テーブル
    op.create_table('adventurer_quests',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('adventurer_instance_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('adventurer_instances.id', ondelete='CASCADE'), nullable=False),
        sa.Column('quest_area_id', sa.String(50), sa.ForeignKey('quest_area_masters.id'), nullable=False),
        sa.Column('player_weapon_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('player_weapons.id')),
        sa.Column('status', sa.String(20), nullable=False, default='in_progress'),
        sa.Column('start_time', sa.DateTime(timezone=True), nullable=False, server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('end_time', sa.DateTime(timezone=True)),
        sa.Column('success', sa.Boolean),
        sa.Column('gold_earned', sa.Integer, default=0),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP')),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'))
    )
    
    # クエスト報酬テーブル
    op.create_table('quest_rewards',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('adventurer_quest_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('adventurer_quests.id', ondelete='CASCADE'), nullable=False),
        sa.Column('item_type', sa.String(20), nullable=False),
        sa.Column('item_id', sa.String(50), nullable=False),
        sa.Column('quantity', sa.Integer, nullable=False, default=1),
        sa.Column('buyback_price', sa.Integer),
        sa.Column('buyback_deadline', sa.DateTime(timezone=True)),
        sa.Column('is_bought', sa.Boolean, default=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'))
    )
    
    # 冒険者と武器の購入履歴テーブル
    op.create_table('adventurer_purchases',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True, default=uuid.uuid4),
        sa.Column('adventurer_instance_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('adventurer_instances.id', ondelete='CASCADE'), nullable=False),
        sa.Column('player_weapon_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('player_weapons.id'), nullable=False),
        sa.Column('price', sa.Integer, nullable=False),
        sa.Column('purchased_at', sa.DateTime(timezone=True), server_default=sa.text('CURRENT_TIMESTAMP'))
    )
    
    # インデックスの作成
    op.create_index('idx_adventurer_instances_player_id', 'adventurer_instances', ['player_id'])
    op.create_index('idx_adventurer_instances_status', 'adventurer_instances', ['status'])
    op.create_index('idx_adventurer_requests_adventurer_id', 'adventurer_requests', ['adventurer_instance_id'])
    op.create_index('idx_adventurer_quests_adventurer_id', 'adventurer_quests', ['adventurer_instance_id'])
    op.create_index('idx_adventurer_quests_status', 'adventurer_quests', ['status'])
    op.create_index('idx_quest_rewards_quest_id', 'quest_rewards', ['adventurer_quest_id'])
    op.create_index('idx_quest_rewards_buyback', 'quest_rewards', ['is_bought', 'buyback_deadline'])

def drop_adventurer_tables():
    op.drop_index('idx_quest_rewards_buyback')
    op.drop_index('idx_quest_rewards_quest_id')
    op.drop_index('idx_adventurer_quests_status')
    op.drop_index('idx_adventurer_quests_adventurer_id')
    op.drop_index('idx_adventurer_requests_adventurer_id')
    op.drop_index('idx_adventurer_instances_status')
    op.drop_index('idx_adventurer_instances_player_id')
    
    op.drop_table('adventurer_purchases')
    op.drop_table('quest_rewards')
    op.drop_table('adventurer_quests')
    op.drop_table('adventurer_requests')
    op.drop_table('adventurer_instances')

if __name__ == "__main__":
    print("このスクリプトはAlembicマイグレーションファイルとして使用してください。")
    print("以下のコマンドでマイグレーションを作成してください：")
    print("alembic revision -m 'add adventurer system tables'")
    print("その後、生成されたファイルにcreate_adventurer_tables()関数の内容をコピーしてください。")