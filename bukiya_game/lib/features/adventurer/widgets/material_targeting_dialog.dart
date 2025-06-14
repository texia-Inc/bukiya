import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/material_targeting.dart';
import '../../../core/models/adventurer_new.dart';
import '../../../shared/themes/app_theme.dart';
import '../../auth/providers/auth_provider.dart';

/// 素材ターゲティング設定ダイアログ
class MaterialTargetingDialog extends StatefulWidget {
  final Adventurer adventurer;
  final List<QuestArea> questAreas;
  final List<QuestAreaDropInfo> dropInfo;
  final Function(int questAreaId, MaterialTargetRequest? targetRequest) onDispatch;

  const MaterialTargetingDialog({
    Key? key,
    required this.adventurer,
    required this.questAreas,
    required this.dropInfo,
    required this.onDispatch,
  }) : super(key: key);

  @override
  State<MaterialTargetingDialog> createState() => _MaterialTargetingDialogState();
}

class _MaterialTargetingDialogState extends State<MaterialTargetingDialog> {
  QuestArea? selectedQuestArea;
  MaterialTargetInfo? selectedMaterial;
  int selectedBoostLevel = 1;
  bool enableTargeting = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuestAreaSelection(),
                    const SizedBox(height: 16),
                    _buildTargetingToggle(),
                    if (enableTargeting) ...[
                      const SizedBox(height: 16),
                      _buildMaterialSelection(),
                      const SizedBox(height: 16),
                      _buildBoostLevelSelection(),
                      const SizedBox(height: 16),
                      _buildCostSummary(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: widget.adventurer.adventurerMaster?.avatarUrl != null
              ? NetworkImage(widget.adventurer.adventurerMaster!.avatarUrl!)
              : null,
          child: widget.adventurer.adventurerMaster?.avatarUrl == null
              ? const Icon(Icons.person)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.adventurer.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Lv.${widget.adventurer.level} ${widget.adventurer.adventurerMaster?.profession ?? "冒険者"}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildQuestAreaSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'クエストエリア選択',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.questAreas.length,
            itemBuilder: (context, index) {
              final area = widget.questAreas[index];
              final isSelected = selectedQuestArea?.id == area.id;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedQuestArea = area;
                    selectedMaterial = null; // エリア変更時に素材選択をリセット
                  });
                },
                child: Container(
                  width: 140,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.2) : AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lv.${area.requiredLevel}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${area.durationMinutes}分',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
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
      ],
    );
  }

  Widget _buildTargetingToggle() {
    return Row(
      children: [
        Switch(
          value: enableTargeting,
          onChanged: (value) {
            setState(() {
              enableTargeting = value;
              if (!value) {
                selectedMaterial = null;
                selectedBoostLevel = 1;
              }
            });
          },
        ),
        const SizedBox(width: 8),
        const Text(
          '素材ターゲティングを使用',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        if (enableTargeting)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'コストが発生します',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMaterialSelection() {
    if (selectedQuestArea == null) return Container();

    final areaDropInfo = widget.dropInfo.firstWhere(
      (info) => info.questAreaId == selectedQuestArea!.id,
      orElse: () => QuestAreaDropInfo(
        questAreaId: selectedQuestArea!.id,
        questAreaName: selectedQuestArea!.name,
        primaryMaterials: [],
        secondaryMaterials: [],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ターゲット素材選択',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (areaDropInfo.primaryMaterials.isNotEmpty) ...[
          const Text(
            '主要ドロップ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: areaDropInfo.primaryMaterials.map((material) {
              return _buildMaterialChip(material, isPrimary: true);
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        if (areaDropInfo.secondaryMaterials.isNotEmpty) ...[
          const Text(
            '副次ドロップ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: areaDropInfo.secondaryMaterials.map((material) {
              return _buildMaterialChip(material, isPrimary: false);
            }).toList(),
          ),
        ],
        if (areaDropInfo.allMaterials.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'このエリアのドロップ情報はまだ利用できません',
              style: TextStyle(color: Colors.grey),
            ),
          ),
      ],
    );
  }

  Widget _buildMaterialChip(MaterialTargetInfo material, {required bool isPrimary}) {
    final isSelected = selectedMaterial?.materialId == material.materialId;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMaterial = isSelected ? null : material;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.surfaceColor,
          border: Border.all(
            color: isPrimary ? Colors.green : Colors.blue,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isPrimary ? Icons.star : Icons.star_border,
              size: 16,
              color: isSelected ? AppTheme.backgroundColor : (isPrimary ? Colors.green : Colors.blue),
            ),
            const SizedBox(width: 4),
            Text(
              material.materialName,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? AppTheme.backgroundColor : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoostLevelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ブーストレベル選択',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...MaterialTargetingLevel.levels.map((level) {
          final isSelected = selectedBoostLevel == level.level;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedBoostLevel = level.level;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : AppTheme.surfaceColor,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.primaryColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: level.level,
                      groupValue: selectedBoostLevel,
                      onChanged: (value) {
                        setState(() {
                          selectedBoostLevel = value!;
                        });
                      },
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            level.description,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(int.parse('0xFF${level.colorHex.substring(1)}')).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${level.cost}G',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(int.parse('0xFF${level.colorHex.substring(1)}')),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCostSummary() {
    if (selectedMaterial == null) return Container();

    final level = MaterialTargetingLevel.getByLevel(selectedBoostLevel);
    final playerGold = context.watch<AuthProvider>().currentPlayer?.gold ?? 0;
    final canAfford = playerGold >= level.cost;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: canAfford 
            ? AppTheme.successColor.withValues(alpha: 0.1) 
            : AppTheme.errorColor.withValues(alpha: 0.1),
        border: Border.all(
          color: canAfford ? AppTheme.successColor : AppTheme.errorColor,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                canAfford ? Icons.check_circle : Icons.warning,
                color: canAfford ? AppTheme.successColor : AppTheme.errorColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'コスト概要',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: canAfford ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ターゲット素材:'),
              Text(
                selectedMaterial!.materialName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ドロップ率倍率:'),
              Text(
                '${level.multiplier}x',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('コスト:'),
              Text(
                '${level.cost}G',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: canAfford ? AppTheme.successColor : AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('所持ゴールド:'),
              Text(
                '${playerGold}G',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (!canAfford) ...[
            const SizedBox(height: 8),
            Text(
              'ゴールドが不足しています',
              style: TextStyle(
                color: AppTheme.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final canDispatch = selectedQuestArea != null && 
        (!enableTargeting || (selectedMaterial != null && 
         (context.watch<AuthProvider>().currentPlayer?.gold ?? 0) >= 
         MaterialTargetingLevel.getByLevel(selectedBoostLevel).cost));

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
              backgroundColor: Colors.grey[100],
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'キャンセル',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: canDispatch ? _handleDispatch : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canDispatch 
                  ? Colors.blue[600]
                  : Colors.grey[400],
              foregroundColor: Colors.white,
              elevation: canDispatch ? 2 : 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              enableTargeting ? 'ターゲティング派遣' : '通常派遣',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleDispatch() {
    if (selectedQuestArea == null) return;

    MaterialTargetRequest? targetRequest;
    
    if (enableTargeting && selectedMaterial != null) {
      targetRequest = MaterialTargetRequest(
        targetMaterialId: selectedMaterial!.materialId,
        boostLevel: selectedBoostLevel,
      );
    }

    widget.onDispatch(selectedQuestArea!.id, targetRequest);
    Navigator.of(context).pop();
  }
}