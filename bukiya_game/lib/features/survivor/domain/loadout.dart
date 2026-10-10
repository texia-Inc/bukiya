/// ランに持ち出す武器の定義（プロトタイプでは店の在庫をモックで持つ）
enum CarriedWeaponType { sword, bow }

class CarriedWeapon {
  final String id;
  final String name;
  final CarriedWeaponType type;

  /// 店で鍛えたエンチャントレベル。ラン中の攻撃力に効く
  final int enchantLevel;

  /// 店での基本売値
  final int basePrice;
  final int durability;

  const CarriedWeapon({
    required this.id,
    required this.name,
    required this.type,
    required this.enchantLevel,
    required this.basePrice,
    this.durability = 100,
  });

  /// エンチャント1段階ごとに攻撃力 +10%
  double get damageMultiplier => 1 + enchantLevel * 0.1;

  String get displayName => enchantLevel > 0 ? '$name +$enchantLevel' : name;
}

/// バックエンドにつなぐまでの仮の在庫
const List<CarriedWeapon> mockShopStock = [
  CarriedWeapon(
    id: 'iron_sword',
    name: '鉄の剣',
    type: CarriedWeaponType.sword,
    enchantLevel: 2,
    basePrice: 800,
  ),
  CarriedWeapon(
    id: 'hunter_bow',
    name: '狩人の弓',
    type: CarriedWeaponType.bow,
    enchantLevel: 0,
    basePrice: 600,
  ),
];
