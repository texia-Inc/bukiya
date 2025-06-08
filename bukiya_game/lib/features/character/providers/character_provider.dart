import 'package:flutter/foundation.dart';

import '../../../core/models/character.dart';
import '../../../core/services/api_service.dart';
import '../../../core/services/character_api_service.dart';

class CharacterProvider extends ChangeNotifier {
  final ApiService _apiService;
  late final CharacterApiService _characterApiService;

  CharacterProvider(this._apiService) {
    _characterApiService = CharacterApiService(_apiService);
  }

  // 状態管理
  bool _isLoading = false;
  String? _errorMessage;

  // キャラクターデータ
  List<CharacterData> _availableCharacters = [];
  List<CharacterBond> _unlockedCharacters = [];
  CharacterData? _selectedCharacter;
  Map<String, dynamic>? _bondProgress;
  
  // ゲッター
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CharacterData> get availableCharacters => _availableCharacters;
  List<CharacterBond> get unlockedCharacters => _unlockedCharacters;
  CharacterData? get selectedCharacter => _selectedCharacter;
  Map<String, dynamic>? get bondProgress => _bondProgress;

  // 解放可能なキャラクター数
  int get availableCount => _availableCharacters.where((c) => c.canUnlock).length;
  
  // 解放済みキャラクター数
  int get unlockedCount => _availableCharacters.where((c) => c.isUnlocked).length;
  
  // 龍戦参加可能なキャラクター数
  int get dragonBattleReadyCount => _unlockedCharacters.where((b) => b.canParticipateInDragonBattle).length;

  /// キャラクターデータを読み込み
  Future<void> loadCharacterData() async {
    try {
      _setLoading(true);
      _clearError();

      // 解放可能なキャラクター一覧と解放済みキャラクター一覧を並行取得
      final futures = [
        _loadAvailableCharacters(),
        _loadUnlockedCharacters(),
      ];

      await Future.wait(futures);
      
      notifyListeners();
    } catch (e) {
      _setError('キャラクターデータの読み込みに失敗しました: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// 解放可能なキャラクター一覧を取得
  Future<void> _loadAvailableCharacters() async {
    try {
      final response = await _characterApiService.getAvailableCharacters();
      _availableCharacters = response.characters;
    } catch (e) {
      debugPrint('解放可能キャラクター読み込みエラー: $e');
      _availableCharacters = [];
    }
  }

  /// 解放済みキャラクター一覧を取得
  Future<void> _loadUnlockedCharacters() async {
    try {
      _unlockedCharacters = await _characterApiService.getUnlockedCharacters();
    } catch (e) {
      debugPrint('解放済みキャラクター読み込みエラー: $e');
      _unlockedCharacters = [];
    }
  }

  /// キャラクターを解放
  Future<bool> unlockCharacter(int characterId, {String unlockMethod = 'manual'}) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _characterApiService.unlockCharacter(
        characterId: characterId,
        unlockMethod: unlockMethod,
        conditionDescription: 'プレイヤーによる手動解放',
      );

      if (result.containsKey('message')) {
        // データを再読み込み
        await loadCharacterData();
        return true;
      }
      return false;
    } catch (e) {
      _setError('キャラクターの解放に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }


  /// キャラクターの詳細情報を設定
  Future<void> selectCharacter(int characterId) async {
    try {
      _selectedCharacter = _availableCharacters.firstWhere(
        (c) => c.character.id == characterId,
      );
      
      // 解放済みの場合は絆進捗も取得
      if (_selectedCharacter?.isUnlocked == true) {
        await loadBondProgress(characterId);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('キャラクター選択エラー: $e');
    }
  }

  /// 絆進捗を読み込み
  Future<void> loadBondProgress(int characterId) async {
    try {
      _bondProgress = await _characterApiService.getBondProgress(characterId);
      notifyListeners();
    } catch (e) {
      debugPrint('絆進捗読み込みエラー: $e');
      _bondProgress = null;
    }
  }

  /// あだ名を設定
  Future<bool> setNickname(int characterId, String nickname) async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _characterApiService.setCharacterNickname(
        characterId: characterId,
        nickname: nickname,
      );

      if (result.containsKey('message')) {
        // 絆進捗を更新
        await loadBondProgress(characterId);
        return true;
      }
      return false;
    } catch (e) {
      _setError('あだ名の設定に失敗しました: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// 選択をクリア
  void clearSelection() {
    _selectedCharacter = null;
    _bondProgress = null;
    notifyListeners();
  }

  /// レア度でフィルタリング
  List<CharacterData> getCharactersByRarity(String rarity) {
    return _availableCharacters.where((c) => c.character.rarity == rarity).toList();
  }

  /// 職業でフィルタリング
  List<CharacterData> getCharactersByProfession(String profession) {
    return _availableCharacters.where((c) => c.character.profession == profession).toList();
  }

  /// 解放可能なキャラクターのみ取得
  List<CharacterData> get unlockableCharacters {
    return _availableCharacters.where((c) => c.canUnlock && !c.isUnlocked).toList();
  }

  /// 解放済みキャラクターのみ取得
  List<CharacterData> get unlockedCharacterData {
    return _availableCharacters.where((c) => c.isUnlocked).toList();
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