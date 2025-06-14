import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/crafting.dart';
import 'package:bukiya_game/core/models/inventory.dart';
import 'package:bukiya_game/shared/themes/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final CraftingRecipe recipe;
  final List<InventoryPlayerMaterial> playerMaterials;
  final VoidCallback onCraft;
  final bool isCrafting;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.playerMaterials,
    required this.onCraft,
    required this.isCrafting,
  });

  @override
  Widget build(BuildContext context) {
    final canCraft = _canCraft();
    final missingMaterials = _getMissingMaterials();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: canCraft 
                ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                : [const Color(0xFF757575), const Color(0xFF424242)],
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
                      color: _getRarityColor(recipe.weapon.rarity).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRarityColor(recipe.weapon.rarity),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      _getWeaponIcon(),
                      color: _getRarityColor(recipe.weapon.rarity),
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
                          recipe.weapon.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          recipe.name,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
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
                              '攻撃力: ${recipe.weapon.attack}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // 状態チップ
                  _buildStatusChip(canCraft),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // レシピ情報
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.monetization_on,
                      '${recipe.goldCostFormatted}G',
                      Colors.amber,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.trending_up,
                      '${recipe.successRatePercentage}%',
                      Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.star,
                      'Lv.${recipe.requiredLevel}',
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 必要素材
              const Text(
                '必要素材',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              ...recipe.materials.map((material) => _buildMaterialRow(material)),
              
              if (missingMaterials.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '不足素材',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      ...missingMaterials.map((material) => Text(
                        '• ${material.material.name} (${_getPlayerMaterialQuantity(material.materialId.toString())}/${material.quantity})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                        ),
                      )),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // 合成ボタン
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canCraft && !isCrafting ? onCraft : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canCraft ? Colors.white : Colors.grey[600],
                    foregroundColor: canCraft ? AppTheme.primaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: isCrafting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          canCraft ? '合成する' : '合成不可',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool canCraft) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: canCraft ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        canCraft ? '合成可能' : '合成不可',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMaterialRow(RecipeMaterial material) {
    final playerQuantity = _getPlayerMaterialQuantity(material.materialId.toString());
    final hasEnough = playerQuantity >= material.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: material.material.rarityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: material.material.rarityColor,
                width: 1,
              ),
            ),
            child: Icon(
              Icons.category,
              size: 12,
              color: material.material.rarityColor,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              material.material.name,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            '$playerQuantity/${material.quantity}',
            style: TextStyle(
              fontSize: 12,
              color: hasEnough ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWeaponIcon() {
    switch (recipe.weapon.weaponType) {
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

  bool _canCraft() {
    // レシピの合成可能フラグをチェック
    if (recipe.canCraft != null) {
      return recipe.canCraft!;
    }

    // 手動で素材チェック
    for (final material in recipe.materials) {
      final playerQuantity = _getPlayerMaterialQuantity(material.materialId.toString());
      if (playerQuantity < material.quantity) {
        return false;
      }
    }
    return true;
  }

  List<RecipeMaterial> _getMissingMaterials() {
    final missing = <RecipeMaterial>[];
    
    for (final material in recipe.materials) {
      final playerQuantity = _getPlayerMaterialQuantity(material.materialId.toString());
      if (playerQuantity < material.quantity) {
        missing.add(material);
      }
    }
    
    return missing;
  }

  int _getPlayerMaterialQuantity(String materialId) {
    final playerMaterial = playerMaterials
        .where((pm) => pm.materialId == materialId)
        .isNotEmpty 
        ? playerMaterials.where((pm) => pm.materialId == materialId).first 
        : null;
    return playerMaterial?.quantity ?? 0;
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
}

// 拡張メソッド
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
