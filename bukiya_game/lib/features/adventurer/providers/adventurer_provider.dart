import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../../core/models/adventurer_new.dart';
import '../../../core/models/material_targeting.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/adventurer_api_service.dart';
import '../../../core/services/adventurer_mock_service.dart';
import '../../../core/services/error_handler.dart';

// 武器販売結果を表すクラス
class WeaponSaleResult {
  final bool success;
  final String message;
  final int goldEarned;
  final String? weaponName;
  final String? adventurerName;
  final int? trustGained;
  final int? newTrustLevel;
  final String? saleReason;
  final bool questDispatched;
  final String? questAreaName;
  final int? questDurationMinutes;
  final String? questEndTime;

  WeaponSaleResult({
    required this.success,
    required this.message,
    required this.goldEarned,
    this.weaponName,
    this.adventurerName,
    this.trustGained,
    this.newTrustLevel,
    this.saleReason,
    this.questDispatched = false,
    this.questAreaName,
    this.questDurationMinutes,
    this.questEndTime,
  });

  factory WeaponSaleResult.fromJson(Map<String, dynamic> json) {
    return WeaponSaleResult(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      goldEarned: json['gold_earned'] ?? 0,
      weaponName: json['weapon_name'],
      adventurerName: json['adventurer_name'],
      trustGained: json['trust_gained'],
      newTrustLevel: json['new_trust_level'],
      saleReason: json['sale_reason'],
      questDispatched: json['quest_dispatched'] ?? false,
      questAreaName: json['quest_area_name'],
      questDurationMinutes: json['quest_duration_minutes'],
      questEndTime: json['quest_end_time'],
    );
  }
}

class AdventurerProvider extends ChangeNotifier {
  final ApiService _apiService;
  late final AdventurerApiService _adventurerApiService;
  
  // 開発中はモックAPIを使用、本番では実際のAPIを使用
  static const bool _useRealApi = true;

  AdventurerProvider(this._apiService) {
    _adventurerApiService = AdventurerApiService(_apiService);
  }

  // 状態管理
  bool _isLoading = false;
  String? _errorMessage;
  
  // 冒険者データ
  List<Adventurer> _visitingAdventurers = [];
  List<Adventurer> _onQuestAdventurers = [];
  List<QuestResult> _pendingBuybacks = [];
  List<QuestArea> _questAreas = [];
  List<QuestAreaDropInfo> _questAreaDropInfo = [];
  
  // 定期更新用タイマー
  Timer? _updateTimer;
  Timer? _visitorSpawnTimer;
  DateTime? _lastVisitorSpawn;

  // ゲッター
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Adventurer> get visitingAdventurers => _visitingAdventurers;
  List<Adventurer> get onQuestAdventurers => _onQuestAdventurers;
  List<QuestResult> get pendingBuybacks => _pendingBuybacks;
  List<QuestArea> get questAreas => _questAreas;
  List<QuestAreaDropInfo> get questAreaDropInfo => _questAreaDropInfo;
  
  // 自動更新の開始
  void startAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      loadAdventurerData();
    });
    
    // 訪問者の定期生成開始（5-15分間隔）
    _startVisitorSpawning();
  }
  
  // 自動更新の停止
  void stopAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = null;
    _visitorSpawnTimer?.cancel();
    _visitorSpawnTimer = null;
  }
  
  // 訪問者の定期生成開始
  void _startVisitorSpawning() {
    _visitorSpawnTimer?.cancel();
    _scheduleNextVisitorSpawn();
  }
  
  // 次の訪問者生成をスケジュール
  void _scheduleNextVisitorSpawn() {
    // テスト用：30秒-2分間隔でランダムに生成（デバッグ用）
    final nextSpawnSeconds = 30 + Random().nextInt(90); // 30秒-2分
    _visitorSpawnTimer = Timer(Duration(seconds: nextSpawnSeconds), () async {
      await _trySpawnVisitors();
      _scheduleNextVisitorSpawn(); // 次回もスケジュール
    });
  }
  
  // 条件に応じて訪問者を生成
  Future<void> _trySpawnVisitors() async {
    try {
      // 訪問中が10人未満の場合のみ生成（従来5人から増加）
      if (_visitingAdventurers.length < 10) {
        await _spawnVisitors();
        _lastVisitorSpawn = DateTime.now();
        debugPrint('新しい訪問者を生成しました (現在: ${_visitingAdventurers.length}人)');
      }
    } catch (e) {
      debugPrint('定期訪問者生成エラー: $e');
    }
  }
  
  @override
  void dispose() {
    stopAutoUpdate();
    super.dispose();
  }

  // メインデータ読み込み
  Future<void> loadAdventurerData() async {
    try {
      _setLoading(true);
      _clearError();
      
      // 現在のユーザー情報をログ出力
      try {
        final currentUserResponse = await _apiService.dio.get('/api/v1/players/me');
        debugPrint('=== 現在のユーザー情報 ===');
        debugPrint('レスポンス全体: ${currentUserResponse.data}');
        debugPrint('ユーザーID: ${currentUserResponse.data['data']['player']['id']}');
        debugPrint('ユーザー名: ${currentUserResponse.data['data']['player']['username']}');
        debugPrint('ステータスコード: ${currentUserResponse.statusCode}');
        debugPrint('=========================');
      } catch (e) {
        debugPrint('ユーザー情報取得エラー: $e');
        if (e.toString().contains('401') || e.toString().contains('403')) {
          _setError('認証エラー: 再ログインが必要です');
          return;
        }
      }

      // 並行して全データを読み込み
      final futures = [
        _loadVisitingAdventurers(),
        _loadOnQuestAdventurers(),
        _loadPendingBuybacks(),
        _loadQuestAreas(),
        _loadQuestAreaDropInfo(),
      ];

      await Future.wait(futures);

      // 訪問中の冒険者がいない場合、自動で生成を試行
      if (_visitingAdventurers.isEmpty) {
        await _spawnVisitors();
      }

      notifyListeners();
    } catch (e) {
      _setError('冒険者データの読み込みに失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // 訪問中の冒険者を取得
  Future<void> _loadVisitingAdventurers() async {
    try {
      if (_useRealApi) {
        _visitingAdventurers = await _adventurerApiService.getVisitingAdventurers();
        
        // デバッグ: 取得した冒険者のリクエスト情報をログ出力
        debugPrint('=== 訪問中冒険者データ ===');
        debugPrint('総数: ${_visitingAdventurers.length}');
        for (var adventurer in _visitingAdventurers) {
          debugPrint('冒険者: ${adventurer.name}');
          debugPrint('  ID: ${adventurer.id}');
          debugPrint('  プレイヤーID: ${adventurer.playerId}');
          debugPrint('  ステータス: ${adventurer.status}');
          debugPrint('  requests数: ${adventurer.requests.length}');
          for (var request in adventurer.requests) {
            debugPrint('    リクエスト: ${request.weaponType}, 攻撃力${request.minAttack}+, 予算${request.maxBudget}G, ステータス: ${request.status}');
          }
          debugPrint('  currentRequest: ${adventurer.currentRequest?.weaponType ?? "なし"}');
        }
        debugPrint('========================');
      } else {
        _visitingAdventurers = await AdventurerMockService.generateVisitingAdventurers();
      }
    } catch (e) {
      debugPrint('訪問中冒険者の読み込みエラー: $e');
      // エラー時は空リストにして、spawn-visitorsで冒険者を生成してもらう
      _visitingAdventurers = [];
    }
  }

  // 冒険中の冒険者を取得
  Future<void> _loadOnQuestAdventurers() async {
    try {
      debugPrint('=== 冒険中冒険者を読み込み中 ===');
      if (_useRealApi) {
        _onQuestAdventurers = await _adventurerApiService.getOnQuestAdventurers();
        debugPrint('読み込み完了: ${_onQuestAdventurers.length}人の冒険中冒険者');
      } else {
        _onQuestAdventurers = await AdventurerMockService.generateOnQuestAdventurers();
      }
    } catch (e) {
      debugPrint('冒険中冒険者の読み込みエラー: $e');
      // エラー時は空リスト
      _onQuestAdventurers = [];
    }
  }

  // 買取待ちの結果を取得
  Future<void> _loadPendingBuybacks() async {
    try {
      if (_useRealApi) {
        _pendingBuybacks = await _adventurerApiService.getPendingBuybacks();
      } else {
        _pendingBuybacks = await AdventurerMockService.generatePendingBuybacks();
      }
    } catch (e) {
      debugPrint('買取案件の読み込みエラー: $e');
      // エラー時は空リスト
      _pendingBuybacks = [];
    }
  }

  // クエストエリアを取得
  Future<void> _loadQuestAreas() async {
    try {
      if (_useRealApi) {
        _questAreas = await _adventurerApiService.getQuestAreas();
      } else {
        _questAreas = await AdventurerMockService.getQuestAreas();
      }
    } catch (e) {
      debugPrint('クエストエリアの読み込みエラー: $e');
      // エラー時は空リスト
      _questAreas = [];
    }
  }

  // クエストエリアのドロップ情報を取得
  Future<void> _loadQuestAreaDropInfo() async {
    try {
      if (_useRealApi) {
        _questAreaDropInfo = await _adventurerApiService.getQuestAreaDropInfo();
      } else {
        // モック用の空データ
        _questAreaDropInfo = [];
      }
    } catch (e) {
      debugPrint('クエストエリアドロップ情報の読み込みエラー: $e');
      // エラー時は空リスト
      _questAreaDropInfo = [];
    }
  }

  // 武器を冒険者に販売
  Future<WeaponSaleResult> sellWeaponToAdventurer(String adventurerId, String weaponId, int price) async {
    try {
      _clearError();
      
      debugPrint('=== 武器販売処理開始 ===');
      debugPrint('販売対象冒険者ID: $adventurerId');
      debugPrint('武器ID: $weaponId');
      debugPrint('価格: $price');
      
      // 販売前に冒険者データを更新して最新の状態を確認
      await loadAdventurerData();
      
      debugPrint('現在の訪問中冒険者一覧:');
      for (var adv in _visitingAdventurers) {
        debugPrint('  - ${adv.name} (ID: ${adv.id})');
      }
      
      // 冒険者がまだ訪問中かチェック
      final adventurer = _visitingAdventurers.firstWhere(
        (a) => a.id == adventurerId,
        orElse: () {
          debugPrint('エラー: 冒険者ID $adventurerId が訪問中リストに見つかりません');
          debugPrint('利用可能な冒険者ID:');
          for (var adv in _visitingAdventurers) {
            debugPrint('  - ${adv.id}');
          }
          throw Exception('指定された冒険者は現在訪問中ではありません。画面を再読み込みしてください。');
        },
      );
      
      debugPrint('販売対象冒険者が確認されました: ${adventurer.name}');

      if (_useRealApi) {
        final result = await _adventurerApiService.sellWeaponToAdventurer(
          adventurerId: adventurerId,
          weaponId: weaponId,
          price: price,
        );
        
        final saleResult = WeaponSaleResult.fromJson(result);
        
        if (saleResult.success) {
          // 販売情報をログ出力（デバッグ用）
          print('=== 武器販売成功 ===');
          print('販売理由: ${saleResult.saleReason}');
          print('獲得ゴールド: ${saleResult.goldEarned}');
          print('信頼度上昇: +${saleResult.trustGained} (新レベル: ${saleResult.newTrustLevel})');
          if (saleResult.questDispatched) {
            print('クエスト派遣: ${saleResult.questAreaName} (${saleResult.questDurationMinutes}分)');
          } else {
            print('クエスト派遣: なし');
          }
          print('==================');
          
          // 販売成功時、少し待ってから冒険者データを再読み込み
          print('冒険者データを再読み込みします...');
          await Future.delayed(const Duration(milliseconds: 500)); // DBコミットを待つ
          await loadAdventurerData();
          print('冒険者データの再読み込み完了');
        }
        
        return saleResult;
      } else {
        final result = await AdventurerMockService.sellWeapon(
          adventurerId: adventurerId,
          weaponId: weaponId,
          price: price,
        );
        
        final saleResult = WeaponSaleResult.fromJson(result);
        
        if (saleResult.success) {
          // 販売成功時、該当の冒険者を訪問者リストから冒険中リストに移動
          _moveAdventurerToQuest(adventurerId);
        }
        
        return saleResult;
      }
    } catch (e) {
      _setError('武器の販売に失敗しました: ${e.toString()}');
      return WeaponSaleResult(
        success: false,
        message: '武器の販売に失敗しました: ${e.toString()}',
        goldEarned: 0,
      );
    }
  }

  // 冒険者を訪問者リストから冒険中リストに移動
  void _moveAdventurerToQuest(String adventurerId) {
    final adventurerIndex = _visitingAdventurers.indexWhere((a) => a.id == adventurerId);
    if (adventurerIndex != -1) {
      final adventurer = _visitingAdventurers[adventurerIndex];
      
      // 新しい冒険者インスタンスを作成（ステータスを変更）
      final updatedAdventurer = Adventurer(
        id: adventurer.id,
        adventurerMasterId: adventurer.adventurerMasterId,
        playerId: adventurer.playerId,
        name: adventurer.name,
        level: adventurer.level,
        trustLevel: adventurer.trustLevel,
        status: 'on_quest', // ステータスを冒険中に変更
        currentQuestId: 'quest_${DateTime.now().millisecondsSinceEpoch}',
        visitStartTime: adventurer.visitStartTime,
        visitEndTime: adventurer.visitEndTime,
        createdAt: adventurer.createdAt,
        updatedAt: DateTime.now(),
        adventurerMaster: adventurer.adventurerMaster,
        requests: adventurer.requests,
        isNamedCharacter: adventurer.isNamedCharacter,
        characterId: adventurer.characterId,
        genericName: adventurer.genericName,
      );
      
      // リストから削除して冒険中リストに追加
      _visitingAdventurers.removeAt(adventurerIndex);
      _onQuestAdventurers.add(updatedAdventurer);
      
      notifyListeners();
    }
  }

  // 冒険者を派遣
  Future<bool> sendAdventurerOnQuest(String adventurerId, String questAreaId) async {
    try {
      _setLoading(true);
      _clearError();

      if (_useRealApi) {
        final result = await _adventurerApiService.sendAdventurerOnQuest(
          adventurerId: adventurerId,
          questAreaId: questAreaId,
        );
        
        if (result.containsKey('message') || result.containsKey('quest_id')) {
          print('=== 通常派遣成功 ===');
          print('APIレスポンス: $result');
          print('=================');
          
          // 少し待ってからデータをリロード（DBコミットの完了を待つ）
          await Future.delayed(const Duration(milliseconds: 500));
          await loadAdventurerData();
          return true;
        }
        return false;
      } else {
        final result = await AdventurerMockService.sendOnQuest(
          adventurerId: adventurerId,
          questAreaId: questAreaId,
        );
        
        if (result['success'] == true) {
          await loadAdventurerData();
          return true;
        }
        return false;
      }
    } catch (e) {
      _setError('冒険者の派遣に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 素材ターゲティング機能付きで冒険者をクエストに派遣
  Future<bool> dispatchAdventurerWithTargeting({
    required String adventurerId,
    required int questAreaId,
    MaterialTargetRequest? targetRequest,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      if (_useRealApi) {
        final result = await _adventurerApiService.dispatchAdventurerWithTargeting(
          adventurerId: adventurerId,
          questAreaId: questAreaId,
          targetMaterialId: targetRequest?.targetMaterialId,
          boostLevel: targetRequest?.boostLevel ?? 1,
        );
        
        if (result.containsKey('message') || result.containsKey('quest_id')) {
          print('=== 素材ターゲティング派遣成功 ===');
          print('APIレスポンス: $result');
          print('=================');
          
          // 少し待ってからデータをリロード（DBコミットの完了を待つ）
          await Future.delayed(const Duration(milliseconds: 500));
          await loadAdventurerData();
          return true;
        }
        return false;
      } else {
        // モック用の処理（通常派遣と同じ）
        final result = await AdventurerMockService.sendOnQuest(
          adventurerId: adventurerId,
          questAreaId: questAreaId.toString(),
        );
        
        if (result['success'] == true) {
          await loadAdventurerData();
          return true;
        }
        return false;
      }
    } catch (e) {
      _setError('素材ターゲティング派遣に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // アイテムを買取
  Future<bool> buybackItems(String questResultId, List<String> itemIds) async {
    try {
      _setLoading(true);
      _clearError();

      if (_useRealApi) {
        final result = await _adventurerApiService.buybackItems(
          questResultId: questResultId,
          itemIds: itemIds,
        );
        
        // APIレスポンスに'message'フィールドがあれば成功とみなす
        if (result.containsKey('message')) {
          await _loadPendingBuybacks();
          return true;
        }
        return false;
      } else {
        final result = await AdventurerMockService.buybackItems(
          questResultId: questResultId,
          itemIds: itemIds,
        );
        
        // モックAPIでも同様に'message'フィールドで成功判定
        if (result.containsKey('message') || result['success'] == true) {
          await _loadPendingBuybacks();
          return true;
        }
        return false;
      }
    } catch (e) {
      print('=== アイテム買取エラー (Provider) ===');
      print('エラータイプ: ${e.runtimeType}');
      print('エラー内容: $e');
      
      String errorMessage;
      
      // カスタム例外（BuybackException）の場合
      if (e.runtimeType.toString().contains('BuybackException')) {
        String originalMessage = e.toString();
        print('BuybackExceptionメッセージ: $originalMessage');
        
        // エラーメッセージに応じてより詳細なガイドを追加
        if (originalMessage.contains('ゴールドが不足')) {
          errorMessage = 'ゴールドが不足しています。\n\n武器を売却するか、冒険者からの武器購入でゴールドを稼いでから再度お試しください。';
        } else if (originalMessage.contains('アイテムが見つかりません')) {
          errorMessage = 'アイテムが見つかりません。\n\n既に他の冒険者に売却済みの可能性があります。最新の情報を確認してください。';
        } else if (originalMessage.contains('買取期限')) {
          errorMessage = '買取期限が過ぎています。\n\nこのアイテムは買取できません。期限内に買取を行ってください。';
        } else {
          // その他のBuybackExceptionの場合、メッセージをそのまま使用
          errorMessage = '$originalMessage\n\n詳細な理由については、サーバーログを確認してください。';
        }
      }
      // DioExceptionやその他のエラーの場合
      else if (e.toString().contains('DioException')) {
        if (e.toString().contains('ゴールドが不足')) {
          errorMessage = 'ゴールドが不足しています。\n\n武器を売却するか、冒険者からの武器購入でゴールドを稼いでから再度お試しください。';
        } else {
          errorMessage = '買取処理中にエラーが発生しました。\n\nサーバーとの通信に問題があります。しばらく時間をおいて再度お試しください。';
        }
      } else {
        errorMessage = 'ネットワークエラーが発生しました。\n\nインターネット接続を確認してから再度お試しください。';
      }
      
      print('最終エラーメッセージ: $errorMessage');
      _setError(errorMessage);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 買取を拒否
  Future<bool> rejectBuyback(String questResultId) async {
    try {
      _setLoading(true);
      _clearError();

      if (_useRealApi) {
        // 実際のAPIを呼び出して買取を拒否
        final result = await _adventurerApiService.rejectBuyback(
          questResultId: questResultId,
        );
        
        // APIレスポンスに'message'フィールドがあれば成功とみなす
        if (result.containsKey('message')) {
          // 買取リストを再読み込みして最新の状態を取得
          await _loadPendingBuybacks();
          return true;
        }
        return false;
      } else {
        // モック環境では直接削除
        _pendingBuybacks.removeWhere((buyback) => buyback.id == questResultId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      _setError('買取の拒否に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 新しい訪問者を生成
  Future<void> _spawnVisitors() async {
    try {
      if (_useRealApi) {
        _visitingAdventurers = await _adventurerApiService.spawnVisitors();
      } else {
        _visitingAdventurers = await AdventurerMockService.spawnVisitors();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('新しい訪問者の生成エラー: $e');
      // 生成に失敗した場合は何もしない（空リストのまま）
    }
  }

  // 手動で訪問者を生成
  Future<void> manualSpawnVisitors() async {
    try {
      _clearError();
      if (_useRealApi) {
        _visitingAdventurers = await _adventurerApiService.spawnVisitors();
        notifyListeners();
      } else {
        _visitingAdventurers = await AdventurerMockService.spawnVisitors();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('手動訪問者生成エラー: $e');
      
      // ErrorHandlerを使用してエラーメッセージを抽出
      String errorMessage = ErrorHandler.extractErrorMessage(e);
      
      // クールダウンエラーの場合、より分かりやすいメッセージに変換
      if (errorMessage.contains('次の訪問者まで') && errorMessage.contains('分お待ちください')) {
        // メッセージをそのまま使用（既に分かりやすい）
      } else if (errorMessage.contains('認証エラー')) {
        errorMessage = '認証エラーが発生しました。再ログインしてください。';
      } else {
        errorMessage = '訪問者の生成に失敗しました。$errorMessage';
      }
      
      _setError(errorMessage);
    }
  }

  // ジェムを使って訪問者を生成
  Future<bool> spawnVisitorsWithGems() async {
    try {
      _clearError();
      if (_useRealApi) {
        final result = await _adventurerApiService.spawnVisitorsWithGems();
        
        if (result.containsKey('message')) {
          // ジェムスポーン成功後、最新の訪問者リストを取得
          await _loadVisitingAdventurers();
          notifyListeners();
          
          final total = result['breakdown']?['total'] ?? 0;
          debugPrint('ジェムで訪問者生成成功: ${total}人');
          debugPrint('メッセージ: ${result['message']}');
          return true;
        }
        return false;
      } else {
        // モック環境では通常生成と同じ処理
        _visitingAdventurers = await AdventurerMockService.spawnVisitors();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('ジェム訪問者生成エラー: $e');
      
      // ErrorHandlerを使用してエラーメッセージを抽出
      String errorMessage = ErrorHandler.extractErrorMessage(e);
      
      // ジェム不足エラーの場合、より分かりやすいメッセージに変換
      if (errorMessage.contains('ジェムが不足')) {
        errorMessage = 'ジェムが不足しています。\n\nジェムを購入するか、ミッション報酬でジェムを獲得してからお試しください。';
      } else if (errorMessage.contains('認証エラー')) {
        errorMessage = '認証エラーが発生しました。再ログインしてください。';
      } else {
        errorMessage = 'ジェムでの訪問者生成に失敗しました。$errorMessage';
      }
      
      _setError(errorMessage);
      return false;
    }
  }

  // プライベートメソッド
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

}