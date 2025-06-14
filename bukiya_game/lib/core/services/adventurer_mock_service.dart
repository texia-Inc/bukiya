import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/adventurer_new.dart';

// 一時的なAdventurerMasterクラス（モック用）
class MockAdventurerMaster {
  final String id;
  final String name;
  final String profession;
  final String professionIcon;
  final int baseLevel;
  final int baseTrustLevel;
  final int baseBudget;
  final String preferredWeaponType;
  final String description;

  const MockAdventurerMaster({
    required this.id,
    required this.name,
    required this.profession,
    required this.professionIcon,
    required this.baseLevel,
    required this.baseTrustLevel,
    required this.baseBudget,
    required this.preferredWeaponType,
    required this.description,
  });
}

/// 冒険者システムのモックデータサービス
/// 実際のAPIが実装されるまでの一時的な実装
class AdventurerMockService {
  static final Random _random = Random();
  
  // 冒険者マスターデータ
  static final List<MockAdventurerMaster> _adventurerMasters = [
    MockAdventurerMaster(
      id: 'master_warrior_1',
      name: '戦士エリオット',
      profession: 'warrior',
      professionIcon: '⚔️',
      baseLevel: 5,
      baseTrustLevel: 60,
      baseBudget: 800,
      preferredWeaponType: 'sword',
      description: '経験豊富な戦士。剣を好む。',
    ),
    MockAdventurerMaster(
      id: 'master_archer_1',
      name: 'アーチャーアリス',
      profession: 'archer',
      professionIcon: '🏹',
      baseLevel: 4,
      baseTrustLevel: 50,
      baseBudget: 600,
      preferredWeaponType: 'bow',
      description: '正確な射撃が得意な弓使い。',
    ),
    MockAdventurerMaster(
      id: 'master_mage_1',
      name: '魔法使いマリン',
      profession: 'mage',
      professionIcon: '🔮',
      baseLevel: 6,
      baseTrustLevel: 70,
      baseBudget: 1000,
      preferredWeaponType: 'staff',
      description: '強力な魔法を操る魔法使い。',
    ),
    MockAdventurerMaster(
      id: 'master_rogue_1',
      name: '盗賊レイド',
      profession: 'rogue',
      professionIcon: '🗡️',
      baseLevel: 3,
      baseTrustLevel: 40,
      baseBudget: 400,
      preferredWeaponType: 'dagger',
      description: '素早い動きが得意な盗賊。',
    ),
  ];

  // クエストエリアマスターデータ
  static final List<QuestArea> _questAreas = [
    QuestArea(
      id: 1,
      name: '深緑の森',
      areaType: 'forest',
      difficulty: 1,
      requiredLevel: 1,
      durationMinutes: 30,
      backgroundColor: '#2d5a3d',
      description: '初心者向けの森林エリア',
      isActive: true,
      displayOrder: 1,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    QuestArea(
      id: 2,
      name: '険しい山岳',
      areaType: 'mountain',
      difficulty: 3,
      requiredLevel: 5,
      durationMinutes: 60,
      backgroundColor: '#5a4a3a',
      description: '中級者向けの山岳エリア',
      isActive: true,
      displayOrder: 2,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    QuestArea(
      id: 3,
      name: '古代遺跡',
      areaType: 'dungeon',
      difficulty: 5,
      requiredLevel: 10,
      durationMinutes: 90,
      backgroundColor: '#3a3a5a',
      description: '上級者向けの遺跡エリア',
      isActive: true,
      displayOrder: 3,
      createdAt: DateTime.now().subtract(Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
  ];

  /// 訪問中の冒険者一覧を生成
  static Future<List<Adventurer>> generateVisitingAdventurers() async {
    await Future.delayed(const Duration(milliseconds: 500)); // API遅延をシミュレート
    
    final adventurers = <Adventurer>[];
    final count = 0; // モックデータを無効化
    
    for (int i = 0; i < count; i++) {
      final master = _adventurerMasters[_random.nextInt(_adventurerMasters.length)];
      final instanceNumber = _random.nextInt(999) + 1;
      final adventurerId = '${master.id}_$instanceNumber';
      final now = DateTime.now();
      
      final adventurer = Adventurer(
        id: adventurerId,
        adventurerMasterId: (i + 1).toString(),
        name: '${master.name}_$instanceNumber',
        level: master.baseLevel + _random.nextInt(5),
        trustLevel: (master.baseTrustLevel + _random.nextInt(20) - 10).clamp(0, 100),
        status: 'visiting',
        visitStartTime: now.subtract(Duration(minutes: _random.nextInt(30))),
        visitEndTime: now.add(Duration(minutes: 30 + _random.nextInt(60))),
        createdAt: now.subtract(Duration(days: _random.nextInt(30))),
        updatedAt: now,
        adventurerMaster: AdventurerMaster(
          id: (i + 1).toString(),
          name: master.name,
          profession: master.profession,
          level: master.baseLevel,
          personality: 'determined',
          trustLevel: master.baseTrustLevel,
          budgetMin: master.baseBudget - 200,
          budgetMax: master.baseBudget + 200,
          preferredWeaponType: master.preferredWeaponType,
          minAttackRequirement: 10,
          maxBudgetMultiplier: 1.5,
          urgencyTendency: 3,
          spawnWeight: 100,
          minPlayerLevel: 1,
          isActive: true,
          createdAt: now.subtract(Duration(days: 60)),
          updatedAt: now,
        ),
        requests: _generateRequests(adventurerId, master),
        isNamedCharacter: false,
        characterId: null,
        genericName: null,
      );
      
      adventurers.add(adventurer);
    }
    
    return adventurers;
  }

  /// 冒険中の冒険者一覧を生成
  static Future<List<Adventurer>> generateOnQuestAdventurers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final adventurers = <Adventurer>[];
    final count = 0; // モックデータを無効化
    
    for (int i = 0; i < count; i++) {
      final master = _adventurerMasters[_random.nextInt(_adventurerMasters.length)];
      final instanceNumber = _random.nextInt(999) + 1;
      final adventurerId = '${master.id}_quest_$instanceNumber';
      final now = DateTime.now();
      
      final adventurer = Adventurer(
        id: adventurerId,
        adventurerMasterId: (i + 1).toString(),
        name: '${master.name}_$instanceNumber',
        level: master.baseLevel + _random.nextInt(5),
        trustLevel: (master.baseTrustLevel + _random.nextInt(20) - 10).clamp(0, 100),
        status: 'on_quest',
        currentQuestId: 'quest_${_random.nextInt(1000)}',
        createdAt: now.subtract(Duration(days: _random.nextInt(30))),
        updatedAt: now,
        adventurerMaster: AdventurerMaster(
          id: (i + 1).toString(),
          name: master.name,
          profession: master.profession,
          level: master.baseLevel,
          personality: 'determined',
          trustLevel: master.baseTrustLevel,
          budgetMin: master.baseBudget - 200,
          budgetMax: master.baseBudget + 200,
          preferredWeaponType: master.preferredWeaponType,
          minAttackRequirement: 10,
          maxBudgetMultiplier: 1.5,
          urgencyTendency: 3,
          spawnWeight: 100,
          minPlayerLevel: 1,
          isActive: true,
          createdAt: now.subtract(Duration(days: 60)),
          updatedAt: now,
        ),
        isNamedCharacter: false,
        characterId: null,
        genericName: null,
      );
      
      adventurers.add(adventurer);
    }
    
    return adventurers;
  }

  /// 買取案件を生成
  static Future<List<QuestResult>> generatePendingBuybacks() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final buybacks = <QuestResult>[];
    final count = _random.nextInt(3); // 0-2件の買取案件
    final now = DateTime.now();
    
    for (int i = 0; i < count; i++) {
      final questArea = _questAreas[_random.nextInt(_questAreas.length)];
      final master = _adventurerMasters[_random.nextInt(_adventurerMasters.length)];
      final instanceNumber = _random.nextInt(999) + 1;
      
      final drops = <QuestDrop>[];
      final dropCount = 1 + _random.nextInt(3); // 1-3個のアイテム
      
      final possibleDrops = ['herb', 'wood', 'stone', 'ore', 'crystal', 'gem', 'artifact', 'scroll', 'rare_gem'];
      for (int j = 0; j < dropCount; j++) {
        final itemType = possibleDrops[_random.nextInt(possibleDrops.length)];
        drops.add(QuestDrop(
          id: 'drop_${i}_$j',
          itemType: itemType,
          itemId: 'item_${itemType}_${_random.nextInt(1000)}',
          name: itemType,
          rarity: 'common',
          quantity: 1 + _random.nextInt(3),
          buybackPrice: 50 + _random.nextInt(200),
          description: 'A ${itemType} found during the quest',
        ));
      }
      
      final totalValue = drops.fold(0, (sum, drop) => sum + drop.buybackPrice * drop.quantity);
      
      final questResult = QuestResult(
        id: 'result_$i',
        adventurerInstanceId: '${master.id}_$instanceNumber',
        questAreaId: questArea.id,
        status: 'completed',
        startTime: now.subtract(Duration(minutes: questArea.durationMinutes + _random.nextInt(30))),
        endTime: now.subtract(Duration(minutes: _random.nextInt(10))),
        success: true,
        goldEarned: totalValue,
        createdAt: now.subtract(Duration(hours: 1)),
        updatedAt: now,
        questArea: questArea,
        rewards: drops.map((drop) => QuestReward(
          id: 'reward_${drop.id}',
          adventurerQuestId: 'result_$i',
          itemType: drop.itemType,
          itemId: drop.itemId,
          itemName: _getMaterialName(drop.itemId), // 素材名を追加
          quantity: drop.quantity,
          buybackPrice: drop.buybackPrice,
          buybackDeadline: now.add(Duration(hours: 24)),
          isBought: false,
          createdAt: now,
        )).toList(),
      );
      
      buybacks.add(questResult);
    }
    
    return buybacks;
  }

  /// 利用可能なクエストエリア一覧を取得
  static Future<List<QuestArea>> getQuestAreas() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_questAreas);
  }

  /// 武器販売をシミュレート
  static Future<Map<String, dynamic>> sellWeapon({
    required String adventurerId,
    required String weaponId,
    required int price,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    debugPrint('モック武器販売: 冒険者=$adventurerId, 武器=$weaponId, 価格=$price');
    
    // 90%の確率で成功
    final success = _random.nextDouble() < 0.9;
    
    if (success) {
      return {
        'success': true,
        'message': '武器の販売が完了しました',
        'gold_earned': price,
        'adventurer_satisfaction': 80 + _random.nextInt(20),
      };
    } else {
      throw Exception('冒険者が武器を気に入りませんでした');
    }
  }

  /// クエスト派遣をシミュレート
  static Future<Map<String, dynamic>> sendOnQuest({
    required String adventurerId,
    required String questAreaId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    
    debugPrint('モッククエスト派遣: 冒険者=$adventurerId, エリア=$questAreaId');
    
    final questArea = _questAreas.firstWhere(
      (area) => area.id.toString() == questAreaId,
      orElse: () => _questAreas.first,
    );
    
    return {
      'success': true,
      'message': '冒険者を${questArea.name}に派遣しました',
      'estimated_return_time': DateTime.now().add(Duration(minutes: 30 + _random.nextInt(60))).toIso8601String(),
      'expected_rewards': questArea.difficulty * 50 + _random.nextInt(100),
    };
  }

  /// アイテム買取をシミュレート
  static Future<Map<String, dynamic>> buybackItems({
    required String questResultId,
    required List<String> itemIds,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    debugPrint('モックアイテム買取: 結果=$questResultId, アイテム数=${itemIds.length}');
    
    final totalValue = itemIds.length * (100 + _random.nextInt(200));
    
    return {
      'success': true,
      'message': 'アイテムの買取が完了しました',
      'total_value': totalValue,
      'items_purchased': itemIds.length,
    };
  }

  /// 新しい訪問者を生成（手動実行）
  static Future<List<Adventurer>> spawnVisitors() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    debugPrint('新しい訪問者を生成中...');
    return generateVisitingAdventurers();
  }

  // プライベートヘルパーメソッド
  static List<AdventurerRequest> _generateRequests(String adventurerId, MockAdventurerMaster master) {
    final requests = <AdventurerRequest>[];
    
    // 80%の確率でリクエストあり
    if (_random.nextDouble() < 0.8) {
      final now = DateTime.now();
      requests.add(AdventurerRequest(
        id: 'req_${adventurerId}_${_random.nextInt(1000)}',
        adventurerInstanceId: adventurerId,
        weaponType: master.preferredWeaponType,
        minAttack: 10 + _random.nextInt(50),
        maxBudget: master.baseBudget + _random.nextInt(200),
        urgency: 1 + _random.nextInt(5),
        deadline: now.add(Duration(hours: 2 + _random.nextInt(6))),
        status: 'pending',
        createdAt: now,
        updatedAt: now,
      ));
    }
    
    return requests;
  }

  /// 素材IDから素材名を取得
  static String _getMaterialName(String itemId) {
    switch (itemId) {
      case '1':
        return '鉄鉱石';
      case '2':
        return '魔法の水晶';
      case '3':
        return '古代の木材';
      case '4':
        return '希少な宝石';
      case '5':
        return 'ドラゴンの鱗';
      case '6':
        return 'ミスリル鉱石';
      case '7':
        return '毒草';
      case '8':
        return '聖なる水';
      case '9':
        return 'プラチナ鉱石';
      case '10':
        return '木の枝';
      case '11':
        return '動物の毛皮';
      case '12':
        return '粘土';
      case '13':
        return '砂';
      case '14':
        return '炭';
      case '15':
        return '羊毛';
      case '16':
        return '麻紐';
      case '17':
        return '骨';
      case '18':
        return '小石';
      case '19':
        return '樹液';
      case '20':
        return '蜘蛛の糸';
      case '21':
        return '硫黄';
      case '22':
        return '鋼鉄塊';
      case '23':
        return '魔法の水晶';
      default:
        return '素材 #$itemId';
    }
  }
}