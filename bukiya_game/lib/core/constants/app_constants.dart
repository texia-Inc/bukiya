class AppConstants {
  // API設定
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const String apiVersion = 'v1';
  
  // 認証設定
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  
  // ローカルストレージキー
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String settingsKey = 'app_settings';
  static const String gameDataKey = 'game_data';
  
  // ゲーム設定
  static const int maxInventorySize = 100;
  static const int maxWeaponLevel = 100;
  static const int maxShopLevel = 50;
  static const int baseGoldCapacity = 10000;
  static const int baseGemsCapacity = 1000;
  
  // 放置システム設定
  static const int maxOfflineHours = 24;
  static const double baseIncomePerSecond = 1.0;
  static const double levelMultiplier = 1.1;
  
  // UI設定
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double cardElevation = 4.0;
  
  // アニメーション設定
  static const int defaultAnimationDuration = 300;
  static const int longAnimationDuration = 500;
  static const int shortAnimationDuration = 150;
  
  // ネットワーク設定
  static const int connectionTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒
  static const int sendTimeout = 30000; // 30秒
  
  // ページネーション
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // レアリティ設定
  static const List<String> rarityLevels = [
    'Common',
    'Rare', 
    'Epic',
    'Legendary'
  ];
  
  // 武器タイプ
  static const List<String> weaponTypes = [
    'sword',
    'axe',
    'bow',
    'staff',
    'dagger',
    'hammer'
  ];
  
  // エラーメッセージ
  static const String networkErrorMessage = 'ネットワークエラーが発生しました';
  static const String serverErrorMessage = 'サーバーエラーが発生しました';
  static const String unknownErrorMessage = '不明なエラーが発生しました';
  static const String authErrorMessage = '認証エラーが発生しました';
  static const String validationErrorMessage = '入力内容に誤りがあります';
  
  // 成功メッセージ
  static const String loginSuccessMessage = 'ログインしました';
  static const String logoutSuccessMessage = 'ログアウトしました';
  static const String registerSuccessMessage = 'アカウントを作成しました';
  static const String updateSuccessMessage = '更新しました';
  static const String deleteSuccessMessage = '削除しました';
  static const String craftSuccessMessage = '合成に成功しました';
  static const String purchaseSuccessMessage = '購入しました';
  static const String sellSuccessMessage = '売却しました';
  
  // バリデーション
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;
  
  // ゲームバランス
  static const Map<String, double> rarityMultipliers = {
    'Common': 1.0,
    'Rare': 1.5,
    'Epic': 2.0,
    'Legendary': 3.0,
  };
  
  static const Map<String, double> weaponTypeMultipliers = {
    'sword': 1.0,
    'axe': 1.2,
    'bow': 0.9,
    'staff': 0.8,
    'dagger': 0.7,
    'hammer': 1.3,
  };
  
  // 通知設定
  static const String craftingCompleteNotification = 'crafting_complete';
  static const String offlineIncomeNotification = 'offline_income';
  static const String levelUpNotification = 'level_up';
  
  // デバッグ設定
  static const bool isDebugMode = true;
  static const bool enableLogging = true;
  static const bool enableMockData = false;
}

class ApiEndpoints {
  // 認証
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  
  // プレイヤー
  static const String playerProfile = '/players/me';
  static const String playerStatistics = '/players/me/statistics';
  static const String playerGold = '/players/me/gold';
  static const String playerGems = '/players/me/gems';
  
  // 武器
  static const String weapons = '/weapons';
  static const String weaponTypes = '/weapons/types';
  static const String playerWeapons = '/players/me/weapons';
  
  // 素材
  static const String materials = '/materials';
  static const String playerMaterials = '/players/me/materials';
  
  // 合成
  static const String recipes = '/crafting/recipes';
  static const String craft = '/crafting/craft';
  static const String craftingHistory = '/crafting/history';
  
  // ショップ
  static const String shop = '/shop';
  static const String purchase = '/shop/purchase';
  static const String sell = '/shop/sell';
  
  // 放置システム
  static const String offlineIncome = '/idle/income';
  static const String collectIncome = '/idle/collect';
  
  // 管理
  static const String adminWeapons = '/weapons/admin';
  static const String adminMaterials = '/materials/admin';
  static const String adminRecipes = '/crafting/recipes/admin';
  static const String adminPlayers = '/players/admin';
}

class GameConstants {
  // レベルアップに必要な経験値計算
  static int getRequiredExp(int level) {
    return (level * level * 100) + (level * 50);
  }
  
  // ショップレベルによる収益倍率
  static double getIncomeMultiplier(int shopLevel) {
    return 1.0 + (shopLevel * 0.1);
  }
  
  // 武器の基本価格計算
  static int getWeaponBasePrice(int attack, String rarity) {
    final rarityMultiplier = AppConstants.rarityMultipliers[rarity] ?? 1.0;
    return (attack * 10 * rarityMultiplier).round();
  }
  
  // 素材の基本価格計算
  static int getMaterialBasePrice(String rarity) {
    final rarityMultiplier = AppConstants.rarityMultipliers[rarity] ?? 1.0;
    return (50 * rarityMultiplier).round();
  }
  
  // 合成成功率計算
  static double getCraftSuccessRate(int playerLevel, double baseRate) {
    final levelBonus = playerLevel * 0.01; // レベル1につき1%ボーナス
    return (baseRate + levelBonus).clamp(0.0, 1.0);
  }
  
  // オフライン収益計算
  static int calculateOfflineIncome(int shopLevel, int offlineMinutes) {
    final baseIncome = AppConstants.baseIncomePerSecond;
    final levelMultiplier = getIncomeMultiplier(shopLevel);
    final maxMinutes = AppConstants.maxOfflineHours * 60;
    final actualMinutes = offlineMinutes.clamp(0, maxMinutes);
    
    return (baseIncome * levelMultiplier * actualMinutes * 60).round();
  }
}
