import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/candy.dart';

class PuzzleProvider extends ChangeNotifier {
  static const int boardSize = 8;
  
  List<List<Candy>> _board = [];
  int _score = 0;
  int _moves = 30;
  bool _gameOver = false;
  bool _isProcessing = false;
  
  // Getters
  List<List<Candy>> get board => _board;
  int get score => _score;
  int get moves => _moves;
  bool get gameOver => _gameOver;
  bool get isProcessing => _isProcessing;
  
  /// ゲームを初期化
  void initializeGame() {
    _board = List.generate(
      boardSize,
      (row) => List.generate(
        boardSize,
        (col) => Candy.random(),
      ),
    );
    
    // 初期状態でマッチがないことを確認
    while (_hasMatches()) {
      _regenerateBoard();
    }
    
    _score = 0;
    _moves = 30;
    _gameOver = false;
    _isProcessing = false;
    notifyListeners();
  }
  
  /// ボードを再生成
  void _regenerateBoard() {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        _board[row][col] = Candy.random();
      }
    }
  }
  
  /// キャンディをスワップ
  Future<bool> swapCandies(int fromRow, int fromCol, int toRow, int toCol) async {
    if (_isProcessing || _gameOver) return false;
    
    // 隣接チェック
    if (!_isAdjacent(fromRow, fromCol, toRow, toCol)) return false;
    
    _isProcessing = true;
    notifyListeners();
    
    // スワップアニメーションの開始
    await _playSwapAnimation(fromRow, fromCol, toRow, toCol);
    
    // 仮スワップ
    _swapCandies(fromRow, fromCol, toRow, toCol);
    
    // マッチチェック
    if (_hasMatches()) {
      _moves--;
      await _processMatches();
      
      if (_moves <= 0) {
        _gameOver = true;
      }
      
      _isProcessing = false;
      notifyListeners();
      return true;
    } else {
      // マッチしない場合は元に戻すアニメーション
      await _playSwapAnimation(toRow, toCol, fromRow, fromCol);
      _swapCandies(fromRow, fromCol, toRow, toCol);
      _isProcessing = false;
      notifyListeners();
      return false;
    }
  }
  
  /// 隣接チェック
  bool _isAdjacent(int fromRow, int fromCol, int toRow, int toCol) {
    int rowDiff = (fromRow - toRow).abs();
    int colDiff = (fromCol - toCol).abs();
    return (rowDiff == 1 && colDiff == 0) || (rowDiff == 0 && colDiff == 1);
  }
  
  /// キャンディを実際にスワップ
  void _swapCandies(int row1, int col1, int row2, int col2) {
    Candy temp = _board[row1][col1];
    _board[row1][col1] = _board[row2][col2];
    _board[row2][col2] = temp;
  }
  
  /// マッチがあるかチェック
  bool _hasMatches() {
    // 横方向のチェック
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize - 2; col++) {
        if (_board[row][col].type != CandyType.empty &&
            _board[row][col].type == _board[row][col + 1].type &&
            _board[row][col].type == _board[row][col + 2].type) {
          return true;
        }
      }
    }
    
    // 縦方向のチェック
    for (int row = 0; row < boardSize - 2; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col].type != CandyType.empty &&
            _board[row][col].type == _board[row + 1][col].type &&
            _board[row][col].type == _board[row + 2][col].type) {
          return true;
        }
      }
    }
    
    return false;
  }
  
  /// マッチを処理
  Future<void> _processMatches() async {
    while (_hasMatches()) {
      _markMatches();
      await _removeMatches();
      await _dropCandies();
      await _fillEmptySpaces();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }
  
  /// マッチをマーク
  void _markMatches() {
    // 横方向のマッチ
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize - 2; col++) {
        if (_board[row][col].type != CandyType.empty &&
            _board[row][col].type == _board[row][col + 1].type &&
            _board[row][col].type == _board[row][col + 2].type) {
          _board[row][col].isMatched = true;
          _board[row][col + 1].isMatched = true;
          _board[row][col + 2].isMatched = true;
          
          // 4つ以上の連続もチェック
          for (int i = col + 3; i < boardSize; i++) {
            if (_board[row][i].type == _board[row][col].type) {
              _board[row][i].isMatched = true;
            } else {
              break;
            }
          }
        }
      }
    }
    
    // 縦方向のマッチ
    for (int row = 0; row < boardSize - 2; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col].type != CandyType.empty &&
            _board[row][col].type == _board[row + 1][col].type &&
            _board[row][col].type == _board[row + 2][col].type) {
          _board[row][col].isMatched = true;
          _board[row + 1][col].isMatched = true;
          _board[row + 2][col].isMatched = true;
          
          // 4つ以上の連続もチェック
          for (int i = row + 3; i < boardSize; i++) {
            if (_board[i][col].type == _board[row][col].type) {
              _board[i][col].isMatched = true;
            } else {
              break;
            }
          }
        }
      }
    }
  }
  
  /// マッチしたキャンディを削除
  Future<void> _removeMatches() async {
    int matchedCount = 0;
    
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col].isMatched) {
          _board[row][col] = Candy.empty();
          matchedCount++;
        }
      }
    }
    
    _score += matchedCount * 10;
    notifyListeners();
  }
  
  /// キャンディを落下
  Future<void> _dropCandies() async {
    bool hasDropped = false;
    
    for (int col = 0; col < boardSize; col++) {
      List<Candy> column = [];
      
      // 空でないキャンディを集める
      for (int row = boardSize - 1; row >= 0; row--) {
        if (!_board[row][col].isEmpty) {
          column.add(_board[row][col]);
        }
      }
      
      // 落下が発生するかチェック
      for (int row = boardSize - 1; row >= 0; row--) {
        if (column.length > boardSize - 1 - row) {
          if (_board[row][col].isEmpty || _board[row][col].type != column[boardSize - 1 - row].type) {
            hasDropped = true;
            break;
          }
        } else if (!_board[row][col].isEmpty) {
          hasDropped = true;
          break;
        }
      }
      
      // 列を再構築
      for (int row = boardSize - 1; row >= 0; row--) {
        if (column.isNotEmpty) {
          _board[row][col] = column.removeAt(0);
        } else {
          _board[row][col] = Candy.empty();
        }
      }
    }
    
    // 落下アニメーションを再生
    if (hasDropped) {
      await _playFallAnimation();
    }
    
    notifyListeners();
  }
  
  /// 空のスペースを埋める
  Future<void> _fillEmptySpaces() async {
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (_board[row][col].isEmpty) {
          _board[row][col] = Candy.random();
        }
      }
    }
    
    notifyListeners();
  }
  
  /// スワップアニメーションを再生
  Future<void> _playSwapAnimation(int fromRow, int fromCol, int toRow, int toCol) async {
    // スワップフラグを設定
    _board[fromRow][fromCol].isSwapping = true;
    _board[toRow][toCol].isSwapping = true;
    notifyListeners();
    
    // アニメーション待機
    await Future.delayed(const Duration(milliseconds: 250));
    
    // スワップフラグをリセット
    _board[fromRow][fromCol].isSwapping = false;
    _board[toRow][toCol].isSwapping = false;
    notifyListeners();
  }
  
  /// 落下アニメーションを再生
  Future<void> _playFallAnimation() async {
    // 落下フラグを設定
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (!_board[row][col].isEmpty) {
          _board[row][col].isFalling = true;
        }
      }
    }
    notifyListeners();
    
    // アニメーション待機
    await Future.delayed(const Duration(milliseconds: 400));
    
    // 落下フラグをリセット
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        _board[row][col].isFalling = false;
      }
    }
    notifyListeners();
  }
  
  /// ゲームリセット
  void resetGame() {
    initializeGame();
  }
}