import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/character.dart';

class CharacterCard extends StatelessWidget {
  final CharacterData characterData;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.characterData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final character = characterData.character;
    final bond = characterData.bond;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(character.rarity),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _getRarityColor(character.rarity).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー部分
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getRarityColor(character.rarity).withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名前とタイトル
                  Text(
                    character.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (character.title != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      character.title!,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            
            // キャラクター画像エリア
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor.withOpacity(0.5),
                ),
                child: character.avatarUrl != null
                    ? Image.network(
                        character.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(character),
                      )
                    : _buildDefaultAvatar(character),
              ),
            ),
            
            // 下部情報
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // レア度と職業
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getRarityColor(character.rarity),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          character.rarityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        character.professionName,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // ステータス表示
                  if (characterData.isUnlocked && bond != null) ...[
                    // 解放済み - 信頼度表示
                    Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '信頼度 ${bond.trustLevel}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: bond.trustLevel / 100,
                      backgroundColor: AppTheme.backgroundColor,
                      valueColor: AlwaysStoppedAnimation(AppTheme.successColor),
                      minHeight: 3,
                    ),
                  ] else if (characterData.canUnlock) ...[
                    // 解放可能
                    Row(
                      children: [
                        Icon(
                          Icons.lock_open,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '解放可能',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // 解放不可
                    Row(
                      children: [
                        const Icon(
                          Icons.lock,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Lv.${character.unlockPlayerLevel}で解放',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(Character character) {
    return Container(
      width: double.infinity,
      color: _getRarityColor(character.rarity).withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getProfessionIcon(character.profession),
            size: 48,
            color: _getRarityColor(character.rarity),
          ),
          const SizedBox(height: 8),
          Text(
            character.professionName,
            style: TextStyle(
              color: _getRarityColor(character.rarity),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(String rarity) {
    switch (rarity) {
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

  IconData _getProfessionIcon(String profession) {
    switch (profession) {
      case 'warrior':
        return Icons.sports_martial_arts;
      case 'archer':
        return Icons.sports_golf;
      case 'mage':
        return Icons.auto_fix_high;
      case 'rogue':
        return Icons.whatshot;
      case 'priest':
        return Icons.healing;
      default:
        return Icons.person;
    }
  }
}