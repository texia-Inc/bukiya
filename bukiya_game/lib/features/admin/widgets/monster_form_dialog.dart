import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/monster.dart';

/// モンスター作成・編集フォームダイアログ
class MonsterFormDialog extends StatefulWidget {
  final Monster? monster; // 編集時はnull以外
  final Function(Map<String, dynamic>) onSubmit;

  const MonsterFormDialog({
    Key? key,
    this.monster,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<MonsterFormDialog> createState() => _MonsterFormDialogState();
}

class _MonsterFormDialogState extends State<MonsterFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // 基本情報
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageUrlController;
  
  String _selectedMonsterType = MonsterType.normal;
  String _selectedRarity = 'common';
  String _selectedHabitat = MonsterHabitat.forest;
  bool _isBoss = false;
  bool _isActive = true;
  
  // ステータス
  late final TextEditingController _levelController;
  late final TextEditingController _hpController;
  late final TextEditingController _attackController;
  late final TextEditingController _defenseController;
  late final TextEditingController _speedController;
  
  // 報酬
  late final TextEditingController _expRewardController;
  late final TextEditingController _goldRewardController;
  
  // スキル
  final List<String> _skills = [];
  final TextEditingController _skillController = TextEditingController();
  
  // ドロップアイテム
  final Map<String, int> _dropItems = {};
  final TextEditingController _dropItemController = TextEditingController();
  final TextEditingController _dropRateController = TextEditingController();

  final List<String> _rarities = [
    'common',
    'uncommon',
    'rare',
    'epic',
    'legendary',
    'mythic',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // 編集モードの場合は既存データで初期化
    final monster = widget.monster;
    _nameController = TextEditingController(text: monster?.name ?? '');
    _descriptionController = TextEditingController(text: monster?.description ?? '');
    _imageUrlController = TextEditingController(text: monster?.imageUrl ?? '');
    
    _levelController = TextEditingController(text: monster?.level.toString() ?? '1');
    _hpController = TextEditingController(text: monster?.hp.toString() ?? '');
    _attackController = TextEditingController(text: monster?.attack.toString() ?? '');
    _defenseController = TextEditingController(text: monster?.defense.toString() ?? '');
    _speedController = TextEditingController(text: monster?.speed.toString() ?? '');
    
    _expRewardController = TextEditingController(text: monster?.expReward.toString() ?? '');
    _goldRewardController = TextEditingController(text: monster?.goldReward.toString() ?? '');
    
    if (monster != null) {
      _selectedMonsterType = monster.monsterType;
      _selectedRarity = monster.rarity;
      _selectedHabitat = monster.habitat;
      _isBoss = monster.isBoss;
      _isActive = monster.isActive;
      _skills.addAll(monster.skills);
      if (monster.dropItems != null) {
        _dropItems.addAll(monster.dropItems!);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _levelController.dispose();
    _hpController.dispose();
    _attackController.dispose();
    _defenseController.dispose();
    _speedController.dispose();
    _expRewardController.dispose();
    _goldRewardController.dispose();
    _skillController.dispose();
    _dropItemController.dispose();
    _dropRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.monster != null;
    
    return Dialog(
      child: Container(
        width: 600,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'モンスター編集' : 'モンスター作成',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // タブバー
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(text: '基本情報'),
                  Tab(text: 'ステータス'),
                  Tab(text: 'スキル'),
                  Tab(text: 'ドロップ'),
                ],
              ),
              const SizedBox(height: 16),
              
              // タブビュー
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBasicInfoTab(),
                    _buildStatsTab(),
                    _buildSkillsTab(),
                    _buildDropItemsTab(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // ボタン
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('キャンセル'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEdit ? '更新' : '作成'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // モンスター名
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'モンスター名 *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'モンスター名を入力してください';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // 説明
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: '説明',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            maxLength: 300,
          ),
          const SizedBox(height: 16),
          
          // タイプとレアリティ
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedMonsterType,
                  decoration: const InputDecoration(
                    labelText: 'モンスタータイプ *',
                    border: OutlineInputBorder(),
                  ),
                  items: MonsterType.allTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(MonsterType.getDisplayName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMonsterType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRarity,
                  decoration: const InputDecoration(
                    labelText: 'レアリティ *',
                    border: OutlineInputBorder(),
                  ),
                  items: _rarities.map((rarity) {
                    return DropdownMenuItem(
                      value: rarity,
                      child: Text(_getRarityDisplayName(rarity)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRarity = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 生息地
          DropdownButtonFormField<String>(
            value: _selectedHabitat,
            decoration: const InputDecoration(
              labelText: '生息地 *',
              border: OutlineInputBorder(),
            ),
            items: MonsterHabitat.allHabitats.map((habitat) {
              return DropdownMenuItem(
                value: habitat,
                child: Text(MonsterHabitat.getDisplayName(habitat)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedHabitat = value!;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // 画像URL
          TextFormField(
            controller: _imageUrlController,
            decoration: const InputDecoration(
              labelText: '画像URL',
              border: OutlineInputBorder(),
              hintText: 'https://example.com/monster.png',
            ),
          ),
          const SizedBox(height: 16),
          
          // ボス・アクティブ状態
          SwitchListTile(
            title: const Text('ボスモンスター'),
            subtitle: const Text('ボスとして設定する'),
            value: _isBoss,
            onChanged: (value) {
              setState(() {
                _isBoss = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('アクティブ状態'),
            subtitle: const Text('無効にするとゲームに出現しなくなります'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // レベル
          TextFormField(
            controller: _levelController,
            decoration: const InputDecoration(
              labelText: 'レベル *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'レベルを入力してください';
              }
              final level = int.tryParse(value);
              if (level == null || level < 1) {
                return '1以上の数値を入力してください';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // HP
          TextFormField(
            controller: _hpController,
            decoration: const InputDecoration(
              labelText: 'HP *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'HPを入力してください';
              }
              final hp = int.tryParse(value);
              if (hp == null || hp < 1) {
                return '1以上の数値を入力してください';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // 攻撃力と防御力
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _attackController,
                  decoration: const InputDecoration(
                    labelText: '攻撃力 *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '攻撃力を入力してください';
                    }
                    final attack = int.tryParse(value);
                    if (attack == null || attack < 0) {
                      return '0以上の数値を入力してください';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _defenseController,
                  decoration: const InputDecoration(
                    labelText: '防御力 *',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '防御力を入力してください';
                    }
                    final defense = int.tryParse(value);
                    if (defense == null || defense < 0) {
                      return '0以上の数値を入力してください';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // 速度
          TextFormField(
            controller: _speedController,
            decoration: const InputDecoration(
              labelText: '速度 *',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '速度を入力してください';
              }
              final speed = int.tryParse(value);
              if (speed == null || speed < 0) {
                return '0以上の数値を入力してください';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // 経験値報酬とゴールド報酬
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expRewardController,
                  decoration: const InputDecoration(
                    labelText: '経験値報酬 *',
                    border: OutlineInputBorder(),
                    suffixText: 'EXP',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '経験値報酬を入力してください';
                    }
                    final exp = int.tryParse(value);
                    if (exp == null || exp < 0) {
                      return '0以上の数値を入力してください';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _goldRewardController,
                  decoration: const InputDecoration(
                    labelText: 'ゴールド報酬 *',
                    border: OutlineInputBorder(),
                    suffixText: 'G',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'ゴールド報酬を入力してください';
                    }
                    final gold = int.tryParse(value);
                    if (gold == null || gold < 0) {
                      return '0以上の数値を入力してください';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _skillController,
                decoration: const InputDecoration(
                  labelText: 'スキル名',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                if (_skillController.text.trim().isNotEmpty) {
                  setState(() {
                    _skills.add(_skillController.text.trim());
                    _skillController.clear();
                  });
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _skills.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(_skills[index]),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _skills.removeAt(index);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropItemsTab() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _dropItemController,
                decoration: const InputDecoration(
                  labelText: 'アイテムID',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _dropRateController,
                decoration: const InputDecoration(
                  labelText: 'ドロップ率(%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final itemId = _dropItemController.text.trim();
                final rateStr = _dropRateController.text.trim();
                if (itemId.isNotEmpty && rateStr.isNotEmpty) {
                  final rate = int.tryParse(rateStr);
                  if (rate != null && rate >= 0 && rate <= 100) {
                    setState(() {
                      _dropItems[itemId] = rate;
                      _dropItemController.clear();
                      _dropRateController.clear();
                    });
                  }
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _dropItems.length,
            itemBuilder: (context, index) {
              final entry = _dropItems.entries.toList()[index];
              return ListTile(
                title: Text('${entry.key} (${entry.value}%)'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _dropItems.remove(entry.key);
                    });
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final monsterData = {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'monster_type': _selectedMonsterType,
      'rarity': _selectedRarity,
      'habitat': _selectedHabitat,
      'level': int.parse(_levelController.text),
      'hp': int.parse(_hpController.text),
      'attack': int.parse(_attackController.text),
      'defense': int.parse(_defenseController.text),
      'speed': int.parse(_speedController.text),
      'exp_reward': int.parse(_expRewardController.text),
      'gold_reward': int.parse(_goldRewardController.text),
      'image_url': _imageUrlController.text.trim().isNotEmpty 
          ? _imageUrlController.text.trim() 
          : null,
      'skills': _skills,
      'drop_items': _dropItems.isNotEmpty ? _dropItems : null,
      'is_boss': _isBoss,
      'is_active': _isActive,
    };

    widget.onSubmit(monsterData);
  }

  String _getRarityDisplayName(String rarity) {
    switch (rarity) {
      case 'common':
        return 'コモン';
      case 'uncommon':
        return 'アンコモン';
      case 'rare':
        return 'レア';
      case 'epic':
        return 'エピック';
      case 'legendary':
        return 'レジェンダリー';
      case 'mythic':
        return 'ミシック';
      default:
        return rarity;
    }
  }
}