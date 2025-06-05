import 'dart:math';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/weapon.dart';
import '../models/mission.dart';
import '../constants/app_constants.dart';

/// シードデータサービス
class SeedDataService {
  static final SeedDataService _instance = SeedDataService._internal();
  factory SeedDataService() => _instance;
  SeedDataService._internal();

  final _random = Random();

  /// 初期データが存在するかチェック
  Future<bool> hasInitialData() async {
    final box = await Hive.openBox(AppConstants.gameDataKey);
    final weapons = box.get('weapons', defaultValue: <String, dynamic>{});
    return weapons.isNotEmpty;
  }

  /// 全ての初期データを作成
  Future<void> seedAllData() async {
    print('シードデータの作成を開始...');
    
    // 既にデータが存在する場合はスキップ
    if (await hasInitialData()) {
      print('初期データが既に存在します。スキップします。');
      return;
    }

    try {
      await seedWeapons();
      await seedMissions();
      
      print('シードデータの作成が完了しました');
    } catch (e) {
      print('シードデータの作成中にエラーが発生しました: $e');
      rethrow;
    }
  }

  /// 武器マスターデータを作成
  Future<void> seedWeapons() async {
    print('武器データを作成中...');
    
    final weaponData = [
      // コモン武器
      _createWeaponData('初心者の剣', 'sword', 'common', 10, 100, 1, '冒険者が最初に手にする基本的な剣'),
      _createWeaponData('木の杖', 'staff', 'common', 8, 80, 1, '木から作られた簡素な杖'),
      _createWeaponData('狩人の弓', 'bow', 'common', 12, 120, 1, '狩猟に使われる基本的な弓'),
      _createWeaponData('石の斧', 'axe', 'common', 15, 150, 2, '石の刃を持つ重い斧'),
      _createWeaponData('短剣', 'dagger', 'common', 7, 70, 1, '小さくて扱いやすい短剣'),
      _createWeaponData('石のハンマー', 'hammer', 'common', 18, 180, 2, '石でできた重いハンマー'),

      // アンコモン武器
      _createWeaponData('鉄の剣', 'sword', 'uncommon', 25, 300, 5, '鉄で鍛えられた丈夫な剣'),
      _createWeaponData('魔法の杖', 'staff', 'uncommon', 22, 280, 4, '魔法の力が込められた杖'),
      _createWeaponData('複合弓', 'bow', 'uncommon', 28, 320, 5, '複数の素材で作られた強力な弓'),
      _createWeaponData('戦斧', 'axe', 'uncommon', 35, 400, 6, '戦場で使われる大型の斧'),
      _createWeaponData('毒塗り短剣', 'dagger', 'uncommon', 20, 250, 4, '毒が塗られた危険な短剣'),
      _createWeaponData('戦鎚', 'hammer', 'uncommon', 40, 450, 7, '重厚な作りの戦闘用ハンマー'),

      // レア武器
      _createWeaponData('銀の剣', 'sword', 'rare', 50, 800, 10, '銀で作られた美しい剣'),
      _createWeaponData('賢者の杖', 'staff', 'rare', 45, 750, 9, '賢者が使っていた知恵の杖'),
      _createWeaponData('エルフの弓', 'bow', 'rare', 55, 850, 10, 'エルフの職人が作った精密な弓'),
      _createWeaponData('ドワーフの斧', 'axe', 'rare', 65, 1000, 12, 'ドワーフの鍛冶師が作った名斧'),
      _createWeaponData('影の短剣', 'dagger', 'rare', 40, 700, 8, '影に隠れる者が愛用する短剣'),
      _createWeaponData('雷鎚', 'hammer', 'rare', 70, 1100, 13, '雷の力が宿るハンマー'),

      // エピック武器
      _createWeaponData('聖剣エクスカリバー', 'sword', 'epic', 100, 2000, 20, '伝説の聖なる剣'),
      _createWeaponData('大魔導師の杖', 'staff', 'epic', 90, 1800, 18, '大魔導師が使った究極の杖'),
      _createWeaponData('神弓アルテミス', 'bow', 'epic', 110, 2200, 22, '女神の名を冠する神弓'),
      _createWeaponData('破壊の斧', 'axe', 'epic', 130, 2500, 25, '破壊神の力が込められた斧'),
      _createWeaponData('暗殺者の刃', 'dagger', 'epic', 80, 1600, 16, '完璧な暗殺を約束する刃'),
      _createWeaponData('神槌ミョルニル', 'hammer', 'epic', 140, 2800, 28, '雷神の槌'),

      // レジェンダリー武器
      _createWeaponData('創世の剣', 'sword', 'legendary', 200, 5000, 40, '世界を創造した神の剣'),
      _createWeaponData('時空の杖', 'staff', 'legendary', 180, 4500, 35, '時空を操る最強の杖'),
      _createWeaponData('滅世の弓', 'bow', 'legendary', 220, 5500, 45, '世界を滅ぼすと言われる弓'),
      _createWeaponData('終焉の斧', 'axe', 'legendary', 250, 6000, 50, '全てを終わらせる斧'),
      _createWeaponData('虚無の刃', 'dagger', 'legendary', 160, 4000, 30, '存在そのものを消し去る刃'),
      _createWeaponData('審判の槌', 'hammer', 'legendary', 280, 7000, 55, '神の審判を下すハンマー'),
    ];

    final box = await Hive.openBox(AppConstants.gameDataKey);
    final weaponsMap = <String, dynamic>{};
    
    for (final data in weaponData) {
      weaponsMap[data['id']] = data;
    }
    
    await box.put('weapons', weaponsMap);

    print('${weaponData.length}個の武器データを作成しました');
  }


  /// ミッションマスターデータを作成
  Future<void> seedMissions() async {
    print('ミッションデータを作成中...');
    
    // 注意: 新しいMissionモデルはAPI経由でのみ作成可能です
    // このメソッドはMissionTemplateの作成のみに使用されます
    
    final missionTemplates = [
      // デイリーミッション
      MissionTemplate(
        id: _generateIntId(),
        name: '武器を作成しよう',
        description: '武器を3個作成してください',
        missionType: MissionType.daily,
        targetType: 'craft_weapon',
        targetCount: 3,
        rewardGold: 100,
        rewardExp: 50,
        isActive: true,
        requiredLevel: 1,
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MissionTemplate(
        id: _generateIntId(),
        name: '武器を販売しよう',
        description: '武器を5個販売してください',
        missionType: MissionType.daily,
        targetType: 'sell_weapon',
        targetCount: 5,
        rewardGold: 200,
        rewardExp: 75,
        isActive: true,
        requiredLevel: 1,
        displayOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MissionTemplate(
        id: _generateIntId(),
        name: 'ゴールドを稼ごう',
        description: '1000ゴールドを稼いでください',
        missionType: MissionType.daily,
        targetType: 'earn_gold',
        targetCount: 1000,
        rewardGold: 300,
        rewardExp: 100,
        isActive: true,
        requiredLevel: 1,
        displayOrder: 3,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // ウィークリーミッション
      MissionTemplate(
        id: _generateIntId(),
        name: '冒険者を派遣しよう',
        description: '冒険者を10回派遣してください',
        missionType: MissionType.weekly,
        targetType: 'dispatch_adventurer',
        targetCount: 10,
        rewardGold: 1000,
        rewardExp: 500,
        isActive: true,
        requiredLevel: 1,
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MissionTemplate(
        id: _generateIntId(),
        name: 'ショップを成長させよう',
        description: 'ショップをアップグレードしてください',
        missionType: MissionType.weekly,
        targetType: 'upgrade_shop',
        targetCount: 1,
        rewardGold: 2000,
        rewardExp: 1000,
        isActive: true,
        requiredLevel: 1,
        displayOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      // アチーブメント
      MissionTemplate(
        id: _generateIntId(),
        name: '初心者脱却',
        description: '武器を累計100個作成してください',
        missionType: MissionType.achievement,
        targetType: 'craft_weapon',
        targetCount: 100,
        rewardGold: 5000,
        rewardExp: 2000,
        isActive: true,
        requiredLevel: 1,
        displayOrder: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      MissionTemplate(
        id: _generateIntId(),
        name: '商売繁盛',
        description: '武器を累計500個販売してください',
        missionType: MissionType.achievement,
        targetType: 'sell_weapon',
        targetCount: 500,
        rewardGold: 10000,
        rewardExp: 5000,
        isActive: true,
        requiredLevel: 5,
        displayOrder: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final box = await Hive.openBox(AppConstants.gameDataKey);
    final missionTemplatesMap = <String, dynamic>{};
    
    for (final missionTemplate in missionTemplates) {
      missionTemplatesMap[missionTemplate.id.toString()] = missionTemplate.toJson();
    }
    
    await box.put('mission_templates', missionTemplatesMap);

    print('${missionTemplates.length}個のミッションテンプレートを作成しました');
  }

  /// 武器データ作成ヘルパー
  Map<String, dynamic> _createWeaponData(
    String name,
    String weaponType,
    String rarity,
    int attack,
    int price,
    int requiredLevel,
    String description,
  ) {
    return {
      'id': _generateId(),
      'name': name,
      'weapon_type': weaponType,
      'rarity': rarity,
      'attack': attack,
      'price': price,
      'required_level': requiredLevel,
      'description': description,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// 整数ID生成
  int _generateIntId() {
    return DateTime.now().millisecondsSinceEpoch + _random.nextInt(1000);
  }

  /// ユニークID生成
  String _generateId() {
    final now = DateTime.now();
    final random = _random.nextInt(9999).toString().padLeft(4, '0');
    return '${now.millisecondsSinceEpoch}_$random';
  }
}