import 'package:flutter/material.dart';

import '../../../shared/themes/app_theme.dart';
import '../../../shared/widgets/loading_screen.dart';
import '../../../core/constants/app_constants.dart';

class LoginForm extends StatefulWidget {
  final Function(String email, String password) onSubmit;
  final bool isLoading;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 32),
            
            // タイトル
            Text(
              'ログイン',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // メールアドレス
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                prefixIcon: Icon(Icons.email_outlined),
                hintText: 'example@example.com',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                  return '有効なメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // パスワード
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'パスワード',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                if (value.length < AppConstants.minPasswordLength) {
                  return 'パスワードは${AppConstants.minPasswordLength}文字以上で入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // ログインボタン
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: widget.isLoading
                  ? const GameLoadingIndicator(
                      size: 20,
                      color: Colors.white,
                    )
                  : const Text('ログイン'),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_emailController.text, _passwordController.text);
    }
  }
}

class RegisterForm extends StatefulWidget {
  final Function(String username, String email, String password) onSubmit;
  final bool isLoading;

  const RegisterForm({
    super.key,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            
            // タイトル
            Text(
              '新規登録',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // ユーザー名
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ユーザー名',
                prefixIcon: Icon(Icons.person_outlined),
                hintText: '武器屋の店主',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'ユーザー名を入力してください';
                }
                if (value.length < AppConstants.minUsernameLength) {
                  return 'ユーザー名は${AppConstants.minUsernameLength}文字以上で入力してください';
                }
                if (value.length > AppConstants.maxUsernameLength) {
                  return 'ユーザー名は${AppConstants.maxUsernameLength}文字以下で入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // メールアドレス
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'メールアドレス',
                prefixIcon: Icon(Icons.email_outlined),
                hintText: 'example@example.com',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'メールアドレスを入力してください';
                }
                if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                  return '有効なメールアドレスを入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // パスワード
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'パスワード',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワードを入力してください';
                }
                if (value.length < AppConstants.minPasswordLength) {
                  return 'パスワードは${AppConstants.minPasswordLength}文字以上で入力してください';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // パスワード確認
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText: 'パスワード確認',
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'パスワード確認を入力してください';
                }
                if (value != _passwordController.text) {
                  return 'パスワードが一致しません';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            
            // 登録ボタン
            ElevatedButton(
              onPressed: widget.isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: widget.isLoading
                  ? const GameLoadingIndicator(
                      size: 20,
                      color: Colors.white,
                    )
                  : const Text('新規登録'),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
    }
  }
}
