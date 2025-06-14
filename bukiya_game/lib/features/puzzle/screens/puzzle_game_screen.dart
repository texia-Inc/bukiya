import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../providers/puzzle_provider.dart';
import '../widgets/candy_widget.dart';

class PuzzleGameScreen extends StatefulWidget {
  const PuzzleGameScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleGameScreen> createState() => _PuzzleGameScreenState();
}

class _PuzzleGameScreenState extends State<PuzzleGameScreen> {
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PuzzleProvider>().initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3マッチパズル'),
        backgroundColor: AppTheme.backgroundColor,
        foregroundColor: AppTheme.textPrimary,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Consumer<PuzzleProvider>(
        builder: (context, puzzleProvider, child) {
          return Column(
            children: [
              // スコアとムーブ表示
              _buildScoreBar(puzzleProvider),
              
              // ゲームボード
              Expanded(
                child: Center(
                  child: _buildGameBoard(puzzleProvider),
                ),
              ),
              
              // コントロールボタン
              _buildControlButtons(puzzleProvider),
              
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _buildScoreBar(PuzzleProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(color: AppTheme.primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                'スコア',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${provider.score}',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Text(
                '残り手数',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
              Text(
                '${provider.moves}',
                style: TextStyle(
                  color: provider.moves <= 5 ? AppTheme.errorColor : AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(PuzzleProvider provider) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border.all(color: AppTheme.primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: PuzzleProvider.boardSize,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
        ),
        itemCount: PuzzleProvider.boardSize * PuzzleProvider.boardSize,
        itemBuilder: (context, index) {
          int row = index ~/ PuzzleProvider.boardSize;
          int col = index % PuzzleProvider.boardSize;
          
          bool isSelected = selectedRow == row && selectedCol == col;
          
          // スワップ方向を計算
          Offset? swapDirection;
          if (provider.board[row][col].isSwapping && selectedRow != null && selectedCol != null) {
            if (selectedRow == row && selectedCol == col) {
              // 選択されたキャンディの移動先を計算
              // この実装では簡単のため、デフォルトの方向を使用
              swapDirection = const Offset(1, 0);
            }
          }
          
          return CandyWidget(
            candy: provider.board[row][col],
            isSelected: isSelected,
            size: 35,
            isSwapping: provider.board[row][col].isSwapping,
            swapDirection: swapDirection,
            onTap: provider.isProcessing ? null : () => _onCandyTapped(provider, row, col),
          );
        },
      ),
    );
  }

  Widget _buildControlButtons(PuzzleProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (provider.gameOver)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.errorColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ゲームオーバー！',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    provider.resetGame();
                    selectedRow = null;
                    selectedCol = null;
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('リスタート'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('戻る'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _onCandyTapped(PuzzleProvider provider, int row, int col) {
    debugPrint('キャンディタップ: row=$row, col=$col, isEmpty=${provider.board[row][col].isEmpty}');
    
    if (provider.board[row][col].isEmpty) return;
    
    if (selectedRow == null || selectedCol == null) {
      // 最初の選択
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });
    } else if (selectedRow == row && selectedCol == col) {
      // 同じキャンディをタップした場合は選択解除
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });
    } else {
      // 2つ目の選択 - スワップを試行
      provider.swapCandies(selectedRow!, selectedCol!, row, col).then((success) {
        setState(() {
          selectedRow = null;
          selectedCol = null;
        });
        
        if (!success) {
          // スワップ失敗時のフィードバック
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('そのスワップはできません'),
              duration: const Duration(seconds: 1),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      });
    }
  }
}