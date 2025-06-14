import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../core/models/adventurer_new.dart';
import '../../../core/models/material_targeting.dart';
import 'material_targeting_dialog.dart';

class QuestDispatchDialog extends StatelessWidget {
  final Adventurer adventurer;
  final List<QuestArea> questAreas;
  final List<QuestAreaDropInfo> questAreaDropInfo;
  final Function(String questAreaId) onDispatch;
  final Function(int questAreaId, MaterialTargetRequest? targetRequest) onDispatchWithTargeting;

  const QuestDispatchDialog({
    super.key,
    required this.adventurer,
    required this.questAreas,
    required this.questAreaDropInfo,
    required this.onDispatch,
    required this.onDispatchWithTargeting,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.primaryColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '冒険派遣',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${adventurer.name}を冒険に派遣します',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                // 素材ターゲティング派遣ボタン
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showMaterialTargetingDialog(context);
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('素材ターゲティング派遣'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 通常派遣ボタン
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // 最初のクエストエリアのIDを使用
                      if (questAreas.isNotEmpty) {
                        Navigator.of(context).pop();
                        onDispatch(questAreas.first.id.toString());
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('利用可能なクエストエリアがありません'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: Text(
                      '通常派遣',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green[700],
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.green[700]!, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // キャンセルボタン
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'キャンセル',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                      backgroundColor: Colors.grey[100],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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

  void _showMaterialTargetingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MaterialTargetingDialog(
        adventurer: adventurer,
        questAreas: questAreas,
        dropInfo: questAreaDropInfo,
        onDispatch: (questAreaId, targetRequest) {
          onDispatchWithTargeting(questAreaId, targetRequest);
        },
      ),
    );
  }
}