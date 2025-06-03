import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'shared/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/shop/providers/shop_provider.dart';
import 'features/inventory/providers/inventory_provider.dart';
import 'features/crafting/providers/crafting_provider.dart';
import 'features/mission/providers/mission_provider.dart';
import 'features/adventurer/providers/adventurer_provider.dart';
import 'features/idle/providers/idle_provider.dart';
import 'features/enchantment/providers/enchantment_provider.dart';
import 'core/services/api_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive初期化
  await Hive.initFlutter();
  
  // ボックスを開く
  await Hive.openBox(AppConstants.settingsKey);
  await Hive.openBox(AppConstants.gameDataKey);
  
  runApp(const BukiyaGameApp());
}

class BukiyaGameApp extends StatelessWidget {
  const BukiyaGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProxyProvider<ApiService, CraftingProvider>(
          create: (context) => CraftingProvider(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? CraftingProvider(apiService),
        ),
        ChangeNotifierProxyProvider2<ApiService, AuthProvider, MissionProvider>(
          create: (context) => MissionProvider(
            context.read<ApiService>(),
            context.read<AuthProvider>(),
          ),
          update: (context, apiService, authProvider, previous) => 
            previous ?? MissionProvider(apiService, authProvider),
        ),
        ChangeNotifierProxyProvider<ApiService, AdventurerProvider>(
          create: (context) => AdventurerProvider(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? AdventurerProvider(apiService),
        ),
        ChangeNotifierProxyProvider<ApiService, IdleProvider>(
          create: (context) => IdleProvider(context.read<ApiService>()),
          update: (context, apiService, previous) => previous ?? IdleProvider(apiService),
        ),
        ChangeNotifierProvider(create: (_) => EnchantmentProvider()),
      ],
      child: MaterialApp(
        title: '武器屋放置ゲーム',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AppWrapper(),
      ),
    );
  }
}
