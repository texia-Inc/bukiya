import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/core/models/enchantment.dart';
import 'package:bukiya_game/features/enchantment/providers/enchantment_provider.dart';

class MaterialSelectionCard extends StatelessWidget {
  const MaterialSelectionCard({super.key});

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
                  Icons.inventory,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '素材選択',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer<EnchantmentProvider>(
              builder: (context, provider, child) {
                final enchantmentMaterials = provider.enchantmentMaterials;
                final playerMaterials = provider.playerEnchantmentMaterials;
                
                if (enchantmentMaterials.isEmpty) {
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
                        Text('エンチャント素材が見つかりません'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (provider.selectedMaterials.isNotEmpty)
                      _buildSelectedMaterials(context, provider),
                    const SizedBox(height: 12),
                    _buildMaterialGrid(context, enchantmentMaterials, playerMaterials, provider),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedMaterials(BuildContext context, EnchantmentProvider provider) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '選択中の素材',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: provider.clearSelectedMaterials,
                child: const Text('クリア'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: provider.selectedMaterials.entries.map((entry) {
              final materialId = entry.key;
              final quantity = entry.value;
              final material = provider.enchantmentMaterials
                  .firstWhere((m) => m.id == materialId);
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getMaterialRarityColor(material.rarity).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getMaterialRarityColor(material.rarity),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getMaterialIcon(material.materialType),
                      size: 16,
                      color: _getMaterialRarityColor(material.rarity),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${material.name} x$quantity',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => provider.removeMaterial(materialId),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialGrid(
    BuildContext context,
    List<EnchantmentMaterial> enchantmentMaterials,
    List<PlayerEnchantmentMaterial> playerMaterials,
    EnchantmentProvider provider,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: enchantmentMaterials.length,
      itemBuilder: (context, index) {
        final material = enchantmentMaterials[index];
        final playerMaterial = playerMaterials
            .where((pm) => pm.materialId == material.id)
            .firstOrNull;
        final availableQuantity = playerMaterial?.quantity ?? 0;
        final selectedQuantity = provider.selectedMaterials[material.id] ?? 0;
        
        return _buildMaterialCard(
          context,
          material,
          availableQuantity,
          selectedQuantity,
          provider,
        );
      },
    );
  }

  Widget _buildMaterialCard(
    BuildContext context,
    EnchantmentMaterial material,
    int availableQuantity,
    int selectedQuantity,
    EnchantmentProvider provider,
  ) {
    final canSelect = availableQuantity > selectedQuantity;
    final canRemove = selectedQuantity > 0;
    
    return Container(
      decoration: BoxDecoration(
        color: selectedQuantity > 0
            ? _getMaterialRarityColor(material.rarity).withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selectedQuantity > 0
              ? _getMaterialRarityColor(material.rarity)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getMaterialRarityColor(material.rarity),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getMaterialIcon(material.materialType),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    material.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '所持: $availableQuantity',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: availableQuantity > 0 ? Colors.green : Colors.grey,
                    ),
                  ),
                  if (selectedQuantity > 0)
                    Text(
                      '選択: $selectedQuantity',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getMaterialRarityColor(material.rarity),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: canRemove ? () => provider.removeMaterial(material.id) : null,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: canRemove ? Colors.red.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Icon(
                        Icons.remove,
                        color: canRemove ? Colors.red : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: canSelect ? () => provider.addMaterial(material.id) : null,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: canSelect ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        color: canSelect ? Colors.green : Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getMaterialRarityColor(String rarity) {
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

  IconData _getMaterialIcon(String materialType) {
    switch (materialType) {
      case 'crystal':
        return Icons.diamond;
      case 'essence':
        return Icons.water_drop;
      case 'powder':
        return Icons.grain;
      case 'stone':
        return Icons.circle;
      case 'scroll':
        return Icons.description;
      case 'catalyst':
        return Icons.science;
      default:
        return Icons.inventory;
    }
  }
}
