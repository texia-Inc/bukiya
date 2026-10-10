import 'loadout.dart';
import 'run_result.dart';

/// 武器の種類ごとの名前と、+0・耐久満タンのときの基本の売値
const Map<CarriedWeaponType, String> weaponNames = {
  CarriedWeaponType.sword: '鉄の剣',
  CarriedWeaponType.bow: '狩人の弓',
  CarriedWeaponType.spear: '鉄の槍',
  CarriedWeaponType.staff: '見習いの杖',
};

const Map<CarriedWeaponType, int> weaponBasePrices = {
  CarriedWeaponType.sword: 120,
  CarriedWeaponType.bow: 100,
  CarriedWeaponType.spear: 110,
  CarriedWeaponType.staff: 110,
};

const int maxEnchantLevel = 5;

/// 倉庫に置ける武器の数
const int maxOwnedWeapons = 8;

/// 店にある1本1本の武器。熟練度・耐久・強化値を武器ごとに持つ
class OwnedWeapon {
  final String uid;
  final CarriedWeaponType type;
  int enchantLevel;
  int durability;

  /// この武器で倒した数（熟練度）
  int kills;

  OwnedWeapon({
    required this.uid,
    required this.type,
    this.enchantLevel = 0,
    this.durability = 100,
    this.kills = 0,
  });

  String get name => weaponNames[type]!;
  String get displayName => enchantLevel > 0 ? '$name +$enchantLevel' : name;
  bool get broken => durability <= 0;

  /// 強化値込みの基本の売値（熟練度と耐久を掛ける前）
  int get basePrice =>
      (weaponBasePrices[type]! * (1 + 0.4 * enchantLevel)).round();

  /// 今の売値：基本の売値 × 熟練度（最大 +50%）× 耐久（0 で半額）
  int get sellPrice => (basePrice *
          proficiencyMultiplier(kills) *
          (0.5 + 0.5 * durability.clamp(0, 100) / 100))
      .round();

  CarriedWeapon toCarried() => CarriedWeapon(
        id: uid,
        name: name,
        type: type,
        enchantLevel: enchantLevel,
        basePrice: basePrice,
        durability: durability,
      );

  Map<String, Object?> toJson() => {
        'uid': uid,
        'type': type.name,
        'enchant': enchantLevel,
        'durability': durability,
        'kills': kills,
      };

  static OwnedWeapon? fromJson(Object? j) {
    if (j is! Map) return null;
    final type =
        CarriedWeaponType.values.where((t) => t.name == j['type']).firstOrNull;
    final uid = j['uid'];
    if (type == null || uid is! String) return null;
    int toInt(Object? v, int fallback) => v is num ? v.toInt() : fallback;
    return OwnedWeapon(
      uid: uid,
      type: type,
      enchantLevel: toInt(j['enchant'], 0).clamp(0, maxEnchantLevel),
      durability: toInt(j['durability'], 100).clamp(0, 100),
      kills: toInt(j['kills'], 0).clamp(0, 1 << 30),
    );
  }
}

/// はじめから店にある武器。以前のプロトタイプと同じ uid にして、熟練度を引き継げるようにする
List<OwnedWeapon> starterWeapons() => [
      OwnedWeapon(
          uid: 'iron_sword', type: CarriedWeaponType.sword, enchantLevel: 2),
      OwnedWeapon(uid: 'hunter_bow', type: CarriedWeaponType.bow),
      OwnedWeapon(
          uid: 'iron_spear', type: CarriedWeaponType.spear, enchantLevel: 1),
      OwnedWeapon(uid: 'apprentice_staff', type: CarriedWeaponType.staff),
    ];

/// 鍛冶で武器を1本作るのに要るもの
class Recipe {
  final CarriedWeaponType type;
  final Map<MaterialKind, int> materials;
  final int gold;

  const Recipe(this.type, this.materials, this.gold);
}

const List<Recipe> recipes = [
  Recipe(CarriedWeaponType.sword, {MaterialKind.ironOre: 5}, 40),
  Recipe(CarriedWeaponType.bow, {MaterialKind.fang: 4, MaterialKind.ironOre: 1},
      40),
  Recipe(CarriedWeaponType.spear,
      {MaterialKind.ironOre: 3, MaterialKind.bone: 2}, 40),
  Recipe(CarriedWeaponType.staff,
      {MaterialKind.manaStone: 2, MaterialKind.bone: 2}, 40),
];

/// 強化に要るもの
class Cost {
  final int gold;
  final Map<MaterialKind, int> materials;

  const Cost(this.gold, [this.materials = const {}]);
}

/// 今の強化値から +1 するのに要るもの。+3 以上は魔核も要る
Cost enchantCost(OwnedWeapon w) {
  final next = w.enchantLevel + 1;
  return Cost(60 * next, {
    MaterialKind.manaStone: next,
    if (next >= 3) MaterialKind.bossCore: 1,
  });
}

/// 耐久を満タンに戻すのに要るお金（減った耐久1につき1G）
int repairCost(OwnedWeapon w) => 100 - w.durability.clamp(0, 100);
