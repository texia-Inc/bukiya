import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bukiya_game/core/models/inventory.dart';
import 'package:bukiya_game/features/enchantment/providers/enchantment_provider.dart';
import 'package:bukiya_game/features/inventory/providers/inventory_provider.dart';

class WeaponSelectionCard extends StatelessWidget {
  const WeaponSelectionCard({super.key});

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
                  Icons.sports_martial_arts,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '武器選択',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Consumer2<EnchantmentProvider, InventoryProvider>(
              builder: (context, enchantmentProvider, inventoryProvider, child) {
                final weapons = inventoryProvider.playerWeapons;
                
                if (weapons.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('エンチャント可能な武器がありません'),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    if (enchantmentProvider.selectedWeapon != null)
                      _buildSelectedWeapon(context, enchantmentProvider.selectedWeapon!),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: weapons.length,
                        itemBuilder: (context, index) {
                          final weapon = weapons[index];
                          final isSelected = enchantmentProvider.selectedWeapon?.id == weapon.id;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _buildWeaponCard(
                              context,
                              weapon,
                              isSelected,
                              () => enchantmentProvider.selectWeapon(weapon),
                            ),
                          );
                        },
                      ),
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

  Widget _buildSelectedWeapon(BuildContext context, PlayerWeapon weapon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sports_martial_arts,
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
                  weapon.weaponMaster.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.flash_on,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '攻撃力: ${weapon.totalAttack}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.auto_fix_high,
                      size: 16,
                      color: Colors.purple,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'エンチャント: +${weapon.enchantLevel}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
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

  Widget _buildWeaponCard(
    BuildContext context,
    PlayerWeapon weapon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.sports_martial_arts,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              weapon.weaponMaster.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '攻撃力: ${weapon.totalAttack}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange,
                fontSize: 10,
              ),
            ),
            if (weapon.enchantLevel > 0)
              Text(
                '+${weapon.enchantLevel}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.purple,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
