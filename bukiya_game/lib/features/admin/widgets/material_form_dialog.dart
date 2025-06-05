import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/crafting.dart' as crafting;

/// 素材作成・編集フォームダイアログ
class MaterialFormDialog extends StatefulWidget {
  final crafting.Material? material; // 編集時はnull以外
  final Function(Map<String, dynamic>) onSubmit;

  const MaterialFormDialog({
    Key? key,
    this.material,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<MaterialFormDialog> createState() => _MaterialFormDialogState();
}

class _MaterialFormDialogState extends State<MaterialFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _sellPriceController;
  
  String _selectedMaterialType = 'ore';
  String _selectedRarity = 'common';
  bool _isActive = true;
  
  final List<MapEntry<String, String>> _materialTypes = [
    const MapEntry('ore', '鉱石'),
    const MapEntry('wood', '木材'),
    const MapEntry('leather', '革'),
    const MapEntry('cloth', '布'),
    const MapEntry('crystal', '水晶'),
    const MapEntry('scale', '鱗'),
    const MapEntry('feather', '羽'),
    const MapEntry('liquid', '液体'),
    const MapEntry('powder', '粉末'),
    const MapEntry('fragment', '欠片'),
    const MapEntry('organ', '器官'),
    const MapEntry('stone', '石'),
    const MapEntry('flame', '炎'),
    const MapEntry('light', '光'),
    const MapEntry('other', 'その他'),
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
    final material = widget.material;
    _nameController = TextEditingController(text: material?.name ?? '');
    _descriptionController = TextEditingController(text: material?.description ?? '');
    _sellPriceController = TextEditingController(
      text: material?.sellPrice.toString() ?? ''
    );
    
    if (material != null) {
      _selectedRarity = material.rarity;
      _isActive = material.isActive;
      // material_typeは実際のモデルに存在しないため、説明から推測
      _selectedMaterialType = _guessMaterialType(material.description);
    }
  }

  String _guessMaterialType(String description) {
    for (final type in _materialTypes) {
      if (description.contains(type.value)) {
        return type.key;
      }
    }
    return 'other';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _sellPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.material != null;
    
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
                    Icons.category,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? '素材編集' : '素材作成',
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
                      // 素材名
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '素材名 *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '素材名を入力してください';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // 素材種別とレアリティ
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedMaterialType,
                              decoration: const InputDecoration(
                                labelText: '素材種別 *',
                                border: OutlineInputBorder(),
                              ),
                              items: _materialTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type.key,
                                  child: Text(type.value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedMaterialType = value!;
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
                      
                      // 売却価格
                      TextFormField(
                        controller: _sellPriceController,
                        decoration: const InputDecoration(
                          labelText: '売却価格 *',
                          border: OutlineInputBorder(),
                          suffixText: 'G',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '売却価格を入力してください';
                          }
                          final price = int.tryParse(value);
                          if (price == null || price < 0) {
                            return '0以上の数値を入力してください';
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
                      const SizedBox(height: 16),
                      
                      // アクティブ状態
                      SwitchListTile(
                        title: const Text('アクティブ状態'),
                        subtitle: const Text('無効にすると素材がゲーム内で使用できなくなります'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
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

    final materialData = {
      'name': _nameController.text.trim(),
      'material_type': _selectedMaterialType,
      'rarity': _selectedRarity,
      'sell_price': int.parse(_sellPriceController.text),
      'description': _descriptionController.text.trim(),
      'is_active': _isActive,
    };

    widget.onSubmit(materialData);
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