import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/core/models/enchantment.dart';
import 'package:bukiya_game/features/enchantment/providers/enchantment_provider.dart';

class EnchantmentTypeSelectionCard extends StatelessWidget {
  const EnchantmentTypeSelectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_fix_high,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'エンチャントタイプ選択',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<EnchantmentProvider>(
              builder: (context, provider, child) {
                final enchantmentTypes = provider.enchantmentTypes;
                
                if (enchantmentTypes.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('エンチャントタイプが見つかりません'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (provider.selectedEnchantmentType != null)
                      _buildSelectedEnchantmentType(context, provider.selectedEnchantmentType!),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: enchantmentTypes.length,
                      itemBuilder: (context, index) {
                        final enchantmentType = enchantmentTypes[index];
                        final isSelected = provider.selectedEnchantmentType?.id == enchantmentType.id;
                        final currentLevel = provider.getCurrentEnchantmentLevel(enchantmentType.id);
                        final canEnchant = currentLevel < enchantmentType.maxLevel;
                        
                        return _buildEnchantmentTypeCard(
                          context,
                          enchantmentType,
                          currentLevel,
                          isSelected,
                          canEnchant,
                          () => canEnchant ? provider.selectEnchantmentType(enchantmentType) : null,
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedEnchantmentType(BuildContext context, EnchantmentType enchantmentType) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getEnchantmentTypeColor(enchantmentType.effectType),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getEnchantmentTypeIcon(enchantmentType.effectType),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enchantmentType.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  enchantmentType.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEnchantmentTypeCard(
    BuildContext context,
    EnchantmentType enchantmentType,
    int currentLevel,
    bool isSelected,
    bool canEnchant,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : canEnchant
                  ? Colors.grey.withValues(alpha: 0.1)
                  : Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : canEnchant
                    ? Colors.transparent
                    : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: canEnchant 
                        ? _getEnchantmentTypeColor(enchantmentType.effectType)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getEnchantmentTypeIcon(enchantmentType.effectType),
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    enchantmentType.effectTypeDisplayName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: canEnchant ? null : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lv.$currentLevel/${enchantmentType.maxLevel}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: canEnchant ? Colors.blue : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!canEnchant)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'MAX',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  Color _getEnchantmentTypeColor(String effectType) {
    switch (effectType) {
      case 'attack':
        return Colors.red;
      case 'defense':
        return Colors.blue;
      case 'speed':
        return Colors.green;
      case 'critical':
        return Colors.orange;
      case 'accuracy':
        return Colors.purple;
      case 'durability':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _getEnchantmentTypeIcon(String effectType) {
    switch (effectType) {
      case 'attack':
        return Icons.flash_on;
      case 'defense':
        return Icons.shield;
      case 'speed':
        return Icons.speed;
      case 'critical':
        return Icons.star;
      case 'accuracy':
        return Icons.my_location;
      case 'durability':
        return Icons.build;
      default:
        return Icons.auto_fix_high;
    }
  }
}
