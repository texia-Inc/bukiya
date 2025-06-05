import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/weapon.dart';

/// 武器作成・編集フォームダイアログ
class WeaponFormDialog extends StatefulWidget {
  final Weapon? weapon; // 編集時はnull以外
  final Function(Map<String, dynamic>) onSubmit;

  const WeaponFormDialog({
    Key? key,
    this.weapon,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<WeaponFormDialog> createState() => _WeaponFormDialogState();
}

class _WeaponFormDialogState extends State<WeaponFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _attackController;
  late final TextEditingController _priceController;
  late final TextEditingController _requiredLevelController;
  late final TextEditingController _descriptionController;
  
  String _selectedWeaponType = 'sword';
  String _selectedRarity = 'common';
  
  final List<String> _weaponTypes = [
    'sword',
    'axe',
    'bow',
    'staff',
    'dagger',
    'hammer',
  ];
  
  final List<String> _rarities = [
    'common',
    'uncommon',
    'rare',
    'epic',
    'legendary',
  ];

  @override
  void initState() {
    super.initState();
    
    // 編集モードの場合は既存データで初期化
    final weapon = widget.weapon;
    _nameController = TextEditingController(text: weapon?.name ?? '');
    _attackController = TextEditingController(text: weapon?.attack.toString() ?? '');
    _priceController = TextEditingController(text: weapon?.price.toString() ?? '');
    _requiredLevelController = TextEditingController(text: weapon?.requiredLevel.toString() ?? '1');
    _descriptionController = TextEditingController(text: weapon?.description ?? '');
    
    if (weapon != null) {
      _selectedWeaponType = weapon.weaponType;
      _selectedRarity = weapon.rarity;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _attackController.dispose();
    _priceController.dispose();
    _requiredLevelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.weapon != null;
    
    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー
              Row(
                children: [
                  Icon(
                    Icons.sports_martial_arts,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? '武器編集' : '武器作成',
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
              const SizedBox(height: 24),
              
              // フォームフィールド
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 武器名
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '武器名 *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '武器名を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // 武器種別とレアリティ
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedWeaponType,
                              decoration: const InputDecoration(
                                labelText: '武器種別 *',
                                border: OutlineInputBorder(),
                              ),
                              items: _weaponTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(_getWeaponTypeDisplayName(type)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedWeaponType = value!;
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
                      
                      // 攻撃力と価格
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _attackController,
                              decoration: const InputDecoration(
                                labelText: '攻撃力 *',
                                border: OutlineInputBorder(),
                                suffixText: 'ATK',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '攻撃力を入力してください';
                                }
                                final attack = int.tryParse(value);
                                if (attack == null || attack <= 0) {
                                  return '1以上の数値を入力してください';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _priceController,
                              decoration: const InputDecoration(
                                labelText: '価格 *',
                                border: OutlineInputBorder(),
                                suffixText: 'G',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '価格を入力してください';
                                }
                                final price = int.tryParse(value);
                                if (price == null || price <= 0) {
                                  return '1以上の数値を入力してください';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // 必要レベル
                      TextFormField(
                        controller: _requiredLevelController,
                        decoration: const InputDecoration(
                          labelText: '必要レベル',
                          border: OutlineInputBorder(),
                          suffixText: 'Lv',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            final level = int.tryParse(value);
                            if (level == null || level < 1) {
                              return '1以上の数値を入力してください';
                            }
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
                        maxLength: 200,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
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

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final weaponData = {
      'name': _nameController.text.trim(),
      'weapon_type': _selectedWeaponType,
      'rarity': _selectedRarity,
      'attack': int.parse(_attackController.text),
      'price': int.parse(_priceController.text),
      'required_level': int.tryParse(_requiredLevelController.text) ?? 1,
      'description': _descriptionController.text.trim(),
    };

    widget.onSubmit(weaponData);
  }

  String _getWeaponTypeDisplayName(String type) {
    switch (type) {
      case 'sword':
        return '剣';
      case 'axe':
        return '斧';
      case 'bow':
        return '弓';
      case 'staff':
        return '杖';
      case 'dagger':
        return '短剣';
      case 'hammer':
        return 'ハンマー';
      default:
        return type;
    }
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
      default:
        return rarity;
    }
  }
}