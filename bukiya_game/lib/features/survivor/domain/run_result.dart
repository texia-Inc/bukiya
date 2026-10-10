import 'loadout.dart';

enum MaterialKind { ironOre, fang, manaStone }

extension MaterialKindLabel on MaterialKind {
  String get label => switch (this) {
        MaterialKind.ironOre => '鉄鉱石',
        MaterialKind.fang => '魔物の牙',
        MaterialKind.manaStone => '魔石',
      };
}

/// 熟練度による売値倍率は、この撃破数で上限になる
const int proficiencyCapKills = 500;

/// 撃破数に応じた売値倍率（最大 +50%）
double proficiencyMultiplier(int kills) =>
    1 + 0.5 * (kills.clamp(0, proficiencyCapKills) / proficiencyCapKills);

class WeaponOutcome {
  final CarriedWeapon weapon;
  final int kills;
  final int durabilityAfter;

  const WeaponOutcome({
    required this.weapon,
    required this.kills,
    required this.durabilityAfter,
  });

  double get priceMultiplier => proficiencyMultiplier(kills);
  int get priceAfter => (weapon.basePrice * priceMultiplier).round();
}

class RunResult {
  /// 帰還ゲートから生きて帰ったか
  final bool returned;
  final double survivedSeconds;
  final int level;
  final Map<MaterialKind, int> materialsFound;
  final List<WeaponOutcome> weapons;

  const RunResult({
    required this.returned,
    required this.survivedSeconds,
    required this.level,
    required this.materialsFound,
    required this.weapons,
  });

  int get totalKills => weapons.fold(0, (sum, w) => sum + w.kills);

  /// 倒れると素材は半分（切り捨て）しか持ち帰れない
  Map<MaterialKind, int> get materialsKept => {
        for (final e in materialsFound.entries)
          e.key: returned ? e.value : e.value ~/ 2,
      };

  static RunResult build({
    required bool returned,
    required double survivedSeconds,
    required int level,
    required Map<MaterialKind, int> materialsFound,
    required List<CarriedWeapon> loadout,
    required Map<String, int> killsByWeapon,
  }) {
    final durabilityLoss = returned ? 10 : 40;
    return RunResult(
      returned: returned,
      survivedSeconds: survivedSeconds,
      level: level,
      materialsFound: Map.of(materialsFound),
      weapons: [
        for (final w in loadout)
          WeaponOutcome(
            weapon: w,
            kills: killsByWeapon[w.id] ?? 0,
            durabilityAfter: (w.durability - durabilityLoss).clamp(0, 100),
          ),
      ],
    );
  }
}
