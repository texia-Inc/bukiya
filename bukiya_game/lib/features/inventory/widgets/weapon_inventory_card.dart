import 'package:flutter/material.dart';
import '../../../core/models/inventory.dart';
import '../../../shared/themes/app_theme.dart';

class WeaponInventoryCard extends StatelessWidget {
  final PlayerWeapon weapon;
  final VoidCallback onSell;
  final VoidCallback onEnchant;

  const WeaponInventoryCard({
    super.key,
    required this.weapon,
    required this.onSell,
    required this.onEnchant,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: weapon.rarityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              weapon.rarityColor.withOpacity(0.05),
              weapon.rarityColor.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ヘッダー部分
              Row(
                children: [
                  // 武器アイコン
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: weapon.rarityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: weapon.rarityColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getWeaponIcon(),
                      color: weapon.rarityColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 武器情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          weapon.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          weapon.weaponMaster.weaponType,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.flash_on,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '攻撃力: ${weapon.totalAttack}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // レアリティチップ
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: weapon.rarityColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRarityDisplayName(weapon.weaponMaster.rarity),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 詳細情報
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.monetization_on,
                      '売却価格',
                      '${_formatNumber(weapon.sellPrice)}G',
                      Colors.green,
                    ),
                  ),
                  if (weapon.enchantLevel > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoItem(
                        Icons.auto_awesome,
                        'エンチャント',
                        '+${weapon.enchantLevel}',
                        Colors.purple,
                      ),
                    ),
                  ],
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_today,
                      '作成日',
                      _formatDate(weapon.createdAt),
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // アクションボタン
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSell,
                      icon: const Icon(Icons.sell, size: 18),
                      label: const Text('売却'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: weapon.canEnchant ? onEnchant : null,
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: Text(weapon.canEnchant ? 'エンチャント' : '最大レベル'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: weapon.canEnchant ? AppTheme.primaryColor : Colors.grey,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              
              // エンチャント情報
              if (weapon.canEnchant) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'コスト: ${_formatNumber(weapon.enchantCost)}G | 成功率: ${(weapon.enchantSuccessRate * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: color,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  IconData _getWeaponIcon() {
    switch (weapon.weaponMaster.weaponType.toLowerCase()) {
      case 'sword':
        return Icons.sports_martial_arts;
      case 'bow':
        return Icons.sports_golf;
      case 'staff':
        return Icons.sports_hockey;
      case 'dagger':
        return Icons.sports_kabaddi;
      default:
        return Icons.sports_martial_arts;
    }
  }

  String _getRarityDisplayName(String rarity) {
    switch (rarity.toLowerCase()) {
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

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
