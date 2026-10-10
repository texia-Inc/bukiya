/// ランに持ち出す武器の定義（プロトタイプでは店の在庫をモックで持つ）
enum CarriedWeaponType { sword, bow, spear, staff }

extension CarriedWeaponTypeLabel on CarriedWeaponType {
  /// 武器の攻撃方法の短い説明
  String get attackStyle => switch (this) {
        CarriedWeaponType.sword => '周囲を回転斬り',
        CarriedWeaponType.bow => '近くの敵を自動で射る',
        CarriedWeaponType.spear => '近くの敵へ鋭く突く（貫通）',
        CarriedWeaponType.staff => '火の玉を放って爆発させる',
      };
}

/// 一度に持ち出せる武器の数
const int maxCarriedWeapons = 2;

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
  CarriedWeapon(
    id: 'iron_spear',
    name: '鉄の槍',
    type: CarriedWeaponType.spear,
    enchantLevel: 1,
    basePrice: 700,
  ),
  CarriedWeapon(
    id: 'apprentice_staff',
    name: '見習いの杖',
    type: CarriedWeaponType.staff,
    enchantLevel: 0,
    basePrice: 650,
  ),
];
