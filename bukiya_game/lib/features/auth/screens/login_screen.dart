import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const LoadingScreen(
            message: '認証中...',
          );
        }

        return Scaffold(
          backgroundColor: AppTheme.backgroundColor,
          body: Container(
            color: AppTheme.backgroundColor,
            width: double.infinity,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // レトロヘッダー
                    _buildRetroHeader(),
                    const SizedBox(height: 4),
                    
                    // タブメニュー
                    _buildRetroTabs(),
                    const SizedBox(height: 4),
                    
                    // フォームエリア
                    _buildRetroForm(authProvider),
                    
                    // エラーメッセージ
                    if (authProvider.errorMessage != null)
                      _buildRetroErrorMessage(authProvider.errorMessage!),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // ロゴ
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppTheme.cardShadow,
            ),
            child: const Icon(
              Icons.store,
              size: 50,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          // タイトル
          Text(
            '武器屋放置ゲーム',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // サブタイトル
          Text(
            '最強の武器屋を目指そう！',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: AppTheme.primaryColor,
        unselectedLabelColor: Colors.white,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        tabs: const [
          Tab(text: 'ログイン'),
          Tab(text: '新規登録'),
        ],
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.errorColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(String email, String password, {bool rememberLogin = true}) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(email, password, rememberLogin: rememberLogin);
    
    if (success && mounted) {
      // ログイン成功時は自動的にDashboardScreenに遷移される
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.loginSuccessMessage),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  Future<void> _handleRegister(String username, String email, String password) async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(username, email, password);
    
    if (success && mounted) {
      // 登録成功時は自動的にDashboardScreenに遷移される
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppConstants.registerSuccessMessage),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }

  // レトロ風UIメソッド
  Widget _buildRetroHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            '=== 武器屋経営システム ===',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ユーザー認証',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '最強の武器屋を目指そう！',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroTabs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: _tabController.index == 0 
                    ? Border.all(color: AppTheme.primaryColor, width: 1)
                    : null,
                ),
                child: Text(
                  '[1] ログイン',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _tabController.index == 0 
                      ? AppTheme.primaryColor 
                      : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: _tabController.index == 1 
                    ? Border.all(color: AppTheme.primaryColor, width: 1)
                    : null,
                ),
                child: Text(
                  '[2] 新規登録',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _tabController.index == 1 
                      ? AppTheme.primaryColor 
                      : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRetroForm(AuthProvider authProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.primaryColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tabController.index == 0 ? '--- ログイン ---' : '--- 新規登録 ---',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_tabController.index == 0)
            LoginForm(
              onSubmit: _handleLogin,
              isLoading: authProvider.isLoading,
            )
          else
            RegisterForm(
              onSubmit: _handleRegister,
              isLoading: authProvider.isLoading,
            ),
        ],
      ),
    );
  }

  Widget _buildRetroErrorMessage(String message) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.errorColor, width: 1),
      ),
      child: Row(
        children: [
          Text(
            '--- エラー ---',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
