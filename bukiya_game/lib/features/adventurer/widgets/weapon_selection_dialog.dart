import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer_new.dart';
import '../../../core/models/inventory.dart';
import '../../inventory/providers/inventory_provider.dart';

class WeaponSelectionDialog extends StatefulWidget {
  final Adventurer adventurer;
  final Function(String weaponId, int price) onSale;

  const WeaponSelectionDialog({
    super.key,
    required this.adventurer,
    required this.onSale,
  });

  @override
  State<WeaponSelectionDialog> createState() => _WeaponSelectionDialogState();
}

class _WeaponSelectionDialogState extends State<WeaponSelectionDialog> {
  PlayerWeapon? _selectedWeapon;
  bool _isLoading = true;
  List<PlayerWeapon> _compatibleWeapons = [];

  @override
  void initState() {
    super.initState();
    _loadCompatibleWeapons();
  }

  Future<void> _loadCompatibleWeapons() async {
    final inventoryProvider = context.read<InventoryProvider>();
    
    // 武器インベントリを読み込み
    await inventoryProvider.loadPlayerWeapons();
    
    // 冒険者のリクエストに合う武器をフィルター
    final request = widget.adventurer.currentRequest;
    if (request != null) {
      debugPrint('冒険者のリクエスト: 武器タイプ=${request.weaponType}, 攻撃力=${request.minAttack}+, 予算=${request.maxBudget}G');
      debugPrint('プレイヤーの武器数: ${inventoryProvider.playerWeapons.length}');
      
      _compatibleWeapons = inventoryProvider.playerWeapons.where((weapon) {
        // 武器タイプをチェック（複数の可能性を考慮）
        final weaponType = weapon.weaponMaster.weaponType.toLowerCase();
        final requestedType = request.weaponType.toLowerCase();
        final weaponTypeMatch = _isWeaponTypeMatch(weaponType, requestedType);
        
        // 攻撃力をチェック
        final attackMatch = weapon.totalAttack >= request.minAttack;
        
        // 予算内かチェック（武器の売却価格が予算以下）
        final priceMatch = weapon.sellPrice <= request.maxBudget;
        
        debugPrint('武器チェック: ${weapon.weaponMaster.name} (${weaponType}) - タイプマッチ:$weaponTypeMatch, 攻撃力マッチ:$attackMatch (${ weapon.totalAttack}>=${request.minAttack}), 価格マッチ:$priceMatch (${weapon.sellPrice}<=${request.maxBudget})');
        
        return weaponTypeMatch && attackMatch && priceMatch;
      }).toList();
      
      debugPrint('条件に合う武器数: ${_compatibleWeapons.length}');
    }
    
    setState(() {
      _isLoading = false;
    });
  }

  bool _isWeaponTypeMatch(String weaponType, String requestedType) {
    // 武器タイプのマッピング
    final typeMapping = {
      'sword': ['sword', '剣', 'blade'],
      'bow': ['bow', '弓', 'archer'],
      'staff': ['staff', '杖', 'rod', 'wand'],
      'dagger': ['dagger', '短剣', 'knife'],
      'axe': ['axe', '斧', 'hatchet'],
      'hammer': ['hammer', 'ハンマー', 'mace'],
    };
    
    // 直接マッチ
    if (weaponType == requestedType) return true;
    
    // マッピングを使ったマッチ
    for (final entry in typeMapping.entries) {
      if (entry.value.contains(weaponType) && entry.value.contains(requestedType)) {
        return true;
      }
    }
    
    return false;
  }

  String _getWeaponTypeName(String weaponType) {
    switch (weaponType.toLowerCase()) {
      case 'sword':
        return '剣';
      case 'bow':
        return '弓';
      case 'staff':
        return '杖';
      case 'dagger':
        return '短剣';
      case 'axe':
        return '斧';
      case 'hammer':
        return 'ハンマー';
      default:
        return weaponType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.adventurer.currentRequest;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Text(
              '武器選択',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // 冒険者のリクエスト情報
            if (request != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.adventurer.name}のリクエスト',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '希望: ${_getWeaponTypeName(request.weaponType)} | 攻撃力${request.minAttack}+ | 予算${request.maxBudget}G',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // 武器リスト
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_compatibleWeapons.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '条件に合う武器がありません',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '冒険者の要求に応えられる武器を作成してください',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _compatibleWeapons.length,
                  itemBuilder: (context, index) {
                    final weapon = _compatibleWeapons[index];
                    final isSelected = _selectedWeapon?.id == weapon.id;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedWeapon = weapon;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: AppTheme.successColor, width: 2)
                                : null,
                            color: isSelected
                                ? AppTheme.successColor.withValues(alpha: 0.1)
                                : null,
                          ),
                          child: Row(
                            children: [
                              // 選択インジケーター
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppTheme.successColor 
                                        : AppTheme.textSecondary,
                                    width: 2,
                                  ),
                                  color: isSelected 
                                      ? AppTheme.successColor 
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              
                              // 武器情報
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      weapon.displayName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: weapon.rarityColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '攻撃力: ${weapon.totalAttack} | 売却価格: ${weapon.sellPrice}G',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                    if (weapon.enchantLevel > 0)
                                      Text(
                                        'エンチャント: +${weapon.enchantLevel}',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.successColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              
                              // レアリティバッジ
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: weapon.rarityColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  weapon.weaponMaster.rarity,
                                  style: TextStyle(
                                    color: weapon.rarityColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 16),
            
            // ボタン
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.primaryColor, width: 1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'キャンセル',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectedWeapon != null
                        ? () {
                            Navigator.of(context).pop();
                            widget.onSale(_selectedWeapon!.id, _selectedWeapon!.sellPrice);
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedWeapon != null 
                              ? AppTheme.successColor 
                              : AppTheme.textSecondary,
                          width: 1,
                        ),
                        color: _selectedWeapon != null 
                            ? AppTheme.successColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _selectedWeapon != null 
                            ? '販売 (${_selectedWeapon!.sellPrice}G)'
                            : '武器を選択してください',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _selectedWeapon != null 
                              ? AppTheme.successColor 
                              : AppTheme.textSecondary,
                          fontWeight: _selectedWeapon != null 
                              ? FontWeight.bold 
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}