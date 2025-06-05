import 'package:flutter/material.dart';
import 'package:bukiya_game/core/models/crafting.dart';

class CraftingResultDialog extends StatelessWidget {
  final CraftingResult result;

  const CraftingResultDialog({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: result.success
                ? [const Color(0xFF4CAF50), const Color(0xFF2E7D32)]
                : [const Color(0xFFE53935), const Color(0xFFC62828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // アイコンとタイトル
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                result.success ? Icons.check_circle : Icons.cancel,
                size: 48,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              result.success ? '合成成功！' : '合成失敗...',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              result.message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // 結果詳細
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '合成結果',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 武器作成結果
                  if (result.weaponCreated) ...[
                    _buildResultRow(
                      Icons.build_circle,
                      '武器作成',
                      '成功',
                      Colors.green,
                    ),
                    if (result.weaponId != null)
                      _buildResultRow(
                        Icons.tag,
                        '武器ID',
                        result.weaponId!,
                        Colors.blue,
                      ),
                  ] else ...[
                    _buildResultRow(
                      Icons.build_circle,
                      '武器作成',
                      '失敗',
                      Colors.red,
                    ),
                  ],
                  
                  // ゴールド消費
                  _buildResultRow(
                    Icons.monetization_on,
                    'ゴールド消費',
                    '${_formatNumber(result.goldSpent)}G',
                    Colors.amber,
                  ),
                  
                  // 消費素材
                  if (result.materialsConsumed.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '消費素材',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...result.materialsConsumed.map((material) =>
                      _buildMaterialRow(material),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 閉じるボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: result.success ? Colors.green : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  '閉じる',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialRow(ConsumedMaterial material) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Icon(
              Icons.category,
              size: 10,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              material.materialName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
              ),
            ),
          ),
          Text(
            'x${material.quantity}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
