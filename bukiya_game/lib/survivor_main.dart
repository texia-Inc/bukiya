import 'package:flutter/material.dart';

import 'features/survivor/screens/survivor_screen.dart';

/// ブキヤ・サバイバーのプロトタイプだけを起動するエントリポイント。
/// バックエンドなしで動く。
///   flutter run -d chrome -t lib/survivor_main.dart
void main() {
  runApp(const SurvivorPrototypeApp());
}

class SurvivorPrototypeApp extends StatelessWidget {
  const SurvivorPrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ブキヤ・サバイバー',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFFF2C230),
        useMaterial3: true,
      ),
      home: const SurvivorScreen(),
    );
  }
}
