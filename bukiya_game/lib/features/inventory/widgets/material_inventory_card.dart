import 'package:flutter/material.dart';
import '../../../core/models/inventory.dart';
import '../../../shared/themes/app_theme.dart';

class MaterialInventoryCard extends StatelessWidget {
  final InventoryPlayerMaterial material;
  final Function(int) onSell;

  const MaterialInventoryCard({
    super.key,
    required this.material,
    required this.onSell,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getRarityColor(material.material.rarity).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              _getRarityColor(material.material.rarity).withOpacity(0.05),
              _getRarityColor(material.material.rarity).withOpacity(0.02),
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
                  // 素材アイコン
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getRarityColor(material.material.rarity).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRarityColor(material.material.rarity),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getMaterialIcon(),
                      color: _getRarityColor(material.material.rarity),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 素材情報
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          material.material.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          material.material.description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.inventory,
                              size: 16,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '所持数: ${material.quantityDisplay}',
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
                      color: _getRarityColor(material.material.rarity),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRarityDisplayName(material.material.rarity),
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
                      '単価',
                      '${_formatNumber(material.sellPrice)}G',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.account_balance_wallet,
                      '総価値',
                      '${_formatNumber(material.totalSellPrice)}G',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.star,
                      'レアリティ',
                      _getRarityDisplayName(material.material.rarity),
                      _getRarityColor(material.material.rarity),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 売却セクション
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.sell,
                          size: 16,
                          color: Colors.green,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '売却',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // 売却ボタン行
                    Row(
                      children: [
                        Expanded(
                          child: _buildSellButton(
                            '1個',
                            1,
                            material.quantity >= 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSellButton(
                            '10個',
                            10,
                            material.quantity >= 10,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSellButton(
                            '100個',
                            100,
                            material.quantity >= 100,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSellButton(
                            'すべて',
                            material.quantity,
                            material.quantity > 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSellButton(String label, int quantity, bool enabled) {
    return ElevatedButton(
      onPressed: enabled ? () => onSell(quantity) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: enabled ? Colors.green : Colors.grey,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        minimumSize: const Size(0, 32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          if (quantity <= material.quantity)
            Text(
              '${_formatNumber(material.sellPrice * quantity)}G',
              style: const TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  IconData _getMaterialIcon() {
    // 素材の種類に応じてアイコンを変更
    final name = material.material.name.toLowerCase();
    if (name.contains('鉄') || name.contains('iron')) {
      return Icons.hardware;
    } else if (name.contains('木') || name.contains('wood')) {
      return Icons.park;
    } else if (name.contains('石') || name.contains('stone')) {
      return Icons.landscape;
    } else if (name.contains('宝石') || name.contains('gem')) {
      return Icons.diamond;
    } else if (name.contains('薬') || name.contains('potion')) {
      return Icons.local_pharmacy;
    } else {
      return Icons.category;
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'common':
        return const Color(0xFF9E9E9E);
      case 'uncommon':
        return const Color(0xFF4CAF50);
      case 'rare':
        return const Color(0xFF2196F3);
      case 'epic':
        return const Color(0xFF9C27B0);
      case 'legendary':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF9E9E9E);
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
}
