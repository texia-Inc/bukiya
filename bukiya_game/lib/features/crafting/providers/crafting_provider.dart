import 'package:flutter/foundation.dart';
import 'package:bukiya_game/core/models/crafting.dart';
import 'package:bukiya_game/core/services/api_service.dart';

class CraftingProvider extends ChangeNotifier {
  final ApiService _apiService;

  CraftingProvider(this._apiService);

  // 錬成状態
  List<CraftingRecipe> _recipes = [];
  List<CraftingRecipe> _availableRecipes = [];
  List<PlayerMaterial> _playerMaterials = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRefresh;

  // 錬成中の状態
  bool _isCrafting = false;
  CraftingResult? _lastCraftingResult;

  // ゲッター
  List<CraftingRecipe> get recipes => _recipes;
  List<CraftingRecipe> get availableRecipes => _availableRecipes;
  List<PlayerMaterial> get playerMaterials => _playerMaterials;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastRefresh => _lastRefresh;
  bool get isCrafting => _isCrafting;
  CraftingResult? get lastCraftingResult => _lastCraftingResult;

  // 合成可能なレシピ数
  int get craftableRecipesCount => 
      _availableRecipes.where((recipe) => recipe.isCraftable).length;

  // 全レシピを取得
  Future<void> fetchAllRecipes() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        fetchRecipes(),
        fetchAvailableRecipes(),
        fetchPlayerMaterials(),
      ]);
      _lastRefresh = DateTime.now();
    } catch (e) {
      _setError('レシピの取得に失敗しました: $e');
    } finally {
      _setLoading(false);
    }
  }

  // レシピ一覧を取得
  Future<void> fetchRecipes({
    int page = 1,
    int limit = 50,
    String? weaponTypeId,
    int? rarityId,
    int? maxLevel,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      
      if (weaponTypeId != null) queryParams['weapon_type_id'] = weaponTypeId;
      if (rarityId != null) queryParams['rarity_id'] = rarityId;
      if (maxLevel != null) queryParams['max_level'] = maxLevel;

      final response = await _apiService.dio.get(
        '/api/v1/crafting/recipes',
        queryParameters: queryParams,
      );

      if (response.data['success']) {
        final List<dynamic> recipesData = response.data['data'];
        _recipes = recipesData
            .map((json) => CraftingRecipe.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('レシピ一覧の取得に失敗しました: $e');
    }
  }

  // プレイヤー所持素材を取得
  Future<void> fetchPlayerMaterials() async {
    try {
      final response = await _apiService.dio.get('/api/v1/materials/player/inventory');
      
      if (response.data['success']) {
        final List<dynamic> materialsData = response.data['data'];
        _playerMaterials = materialsData
            .map((json) => PlayerMaterial.fromJson(json))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('所持素材の取得に失敗しました: $e');
    }
  }

  // 合成可能なレシピを取得
  Future<void> fetchAvailableRecipes() async {
    try {
      // 一時的に通常のレシピ一覧を使用（availableエンドポイントが存在しないため）
      // TODO: バックエンドに合成可能レシピ専用エンドポイントを追加
      _availableRecipes = _recipes;
      notifyListeners();
    } catch (e) {
      _setError('合成可能レシピの取得に失敗しました: $e');
    }
  }

  // レシピ詳細を取得
  Future<CraftingRecipe?> fetchRecipeDetail(int recipeId) async {
    try {
      final response = await _apiService.dio.get('/api/v1/crafting/recipes/$recipeId');
      
      if (response.data['success']) {
        return CraftingRecipe.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      _setError('レシピ詳細の取得に失敗しました: $e');
      return null;
    }
  }

  // 合成可能性をチェック
  Future<CraftingAvailability?> checkCraftingAvailability(int recipeId) async {
    try {
      final response = await _apiService.dio.get('/api/v1/crafting/recipes/$recipeId/availability');
      
      if (response.data['success']) {
        return CraftingAvailability.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      _setError('合成可能性チェックに失敗しました: $e');
      return null;
    }
  }

  // 武器を合成
  Future<bool> craftWeapon(int recipeId) async {
    if (_isCrafting) return false;

    _setCrafting(true);
    _clearError();

    try {
      final request = CraftingRequest(recipeId: recipeId);
      final response = await _apiService.dio.post(
        '/api/v1/crafting/craft',
        data: request.toJson(),
      );

      if (response.data['success']) {
        _lastCraftingResult = CraftingResult.fromJson(response.data['data']);
        
        // 合成後にデータを更新
        await fetchAvailableRecipes();
        await fetchPlayerMaterials();
        
        notifyListeners();
        return _lastCraftingResult!.success;
      }
      return false;
    } catch (e) {
      _setError('武器の合成に失敗しました: $e');
      return false;
    } finally {
      _setCrafting(false);
    }
  }

  // レシピをフィルタリング
  List<CraftingRecipe> filterRecipes({
    String? weaponType,
    String? rarity,
    int? maxLevel,
    bool? craftableOnly,
  }) {
    List<CraftingRecipe> filteredRecipes = List.from(_availableRecipes);

    if (weaponType != null) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe.weapon.weaponType.toLowerCase() == weaponType.toLowerCase())
          .toList();
    }

    if (rarity != null) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe.weapon.rarity.toLowerCase() == rarity.toLowerCase())
          .toList();
    }

    if (maxLevel != null) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe.requiredLevel <= maxLevel)
          .toList();
    }

    if (craftableOnly == true) {
      filteredRecipes = filteredRecipes
          .where((recipe) => recipe.isCraftable)
          .toList();
    }

    return filteredRecipes;
  }

  // レシピを検索
  List<CraftingRecipe> searchRecipes(String query) {
    if (query.isEmpty) return _availableRecipes;

    final lowerQuery = query.toLowerCase();
    return _availableRecipes.where((recipe) {
      return recipe.name.toLowerCase().contains(lowerQuery) ||
             recipe.weapon.name.toLowerCase().contains(lowerQuery) ||
             (recipe.description.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // 素材の所持数を取得
  int getMaterialQuantity(int materialId) {
    final material = _playerMaterials
        .where((pm) => pm.materialId == materialId)
        .firstOrNull;
    return material?.quantity ?? 0;
  }

  // 素材が足りているかチェック
  bool hasSufficientMaterials(CraftingRecipe recipe) {
    for (final recipeMaterial in recipe.materials) {
      final playerQuantity = getMaterialQuantity(recipeMaterial.materialId);
      if (playerQuantity < recipeMaterial.quantity) {
        return false;
      }
    }
    return true;
  }

  // 不足している素材を取得
  List<RecipeMaterial> getMissingMaterials(CraftingRecipe recipe) {
    final missing = <RecipeMaterial>[];
    
    for (final recipeMaterial in recipe.materials) {
      final playerQuantity = getMaterialQuantity(recipeMaterial.materialId);
      if (playerQuantity < recipeMaterial.quantity) {
        missing.add(recipeMaterial);
      }
    }
    
    return missing;
  }

  // レシピをソート
  List<CraftingRecipe> sortRecipes(
    List<CraftingRecipe> recipes,
    String sortBy,
  ) {
    switch (sortBy) {
      case 'name':
        recipes.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'level':
        recipes.sort((a, b) => a.requiredLevel.compareTo(b.requiredLevel));
        break;
      case 'cost':
        recipes.sort((a, b) => a.goldCost.compareTo(b.goldCost));
        break;
      case 'success_rate':
        recipes.sort((a, b) => b.successRate.compareTo(a.successRate));
        break;
      case 'craftable':
        recipes.sort((a, b) {
          if (a.isCraftable && !b.isCraftable) return -1;
          if (!a.isCraftable && b.isCraftable) return 1;
          return 0;
        });
        break;
      default:
        // デフォルトは名前順
        recipes.sort((a, b) => a.name.compareTo(b.name));
    }
    
    return recipes;
  }

  // 最後の合成結果をクリア
  void clearLastCraftingResult() {
    _lastCraftingResult = null;
    notifyListeners();
  }

  // ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 合成中状態を設定
  void _setCrafting(bool crafting) {
    _isCrafting = crafting;
    notifyListeners();
  }

  // エラーを設定
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  // エラーをクリア
  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // リフレッシュ
  Future<void> refresh() async {
    await fetchAllRecipes();
  }

}

// 拡張メソッド
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
