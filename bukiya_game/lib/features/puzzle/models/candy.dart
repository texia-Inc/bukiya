import 'dart:math';

/// キャンディの種類
enum CandyType {
  red,
  blue,
  green,
  yellow,
  purple,
  empty,
}

/// キャンディクラス
class Candy {
  CandyType type;
  bool isMatched;
  bool isFalling;
  bool isSwapping;
  
  Candy({
    required this.type,
    this.isMatched = false,
    this.isFalling = false,
    this.isSwapping = false,
  });
  
  /// ランダムなキャンディを生成（emptyは除く）
  static Candy random() {
    final types = CandyType.values.where((type) => type != CandyType.empty).toList();
    return Candy(type: types[Random().nextInt(types.length)]);
  }
  
  /// 空のキャンディ
  static Candy empty() {
    return Candy(type: CandyType.empty);
  }
  
  /// キャンディが空かどうか
  bool get isEmpty => type == CandyType.empty;
  
  /// キャンディの色を取得
  String get emoji {
    switch (type) {
      case CandyType.red:
        return '🍎';
      case CandyType.blue:
        return '🫐';
      case CandyType.green:
        return '🍏';
      case CandyType.yellow:
        return '🍌';
      case CandyType.purple:
        return '🍇';
      case CandyType.empty:
        return '';
    }
  }
  
  @override
  String toString() => 'Candy($type, matched: $isMatched, falling: $isFalling, swapping: $isSwapping)';
}