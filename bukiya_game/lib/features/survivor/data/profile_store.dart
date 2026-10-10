import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/profile.dart';

/// 記録を端末（Web ならブラウザ）に保存する
class ProfileStore {
  static const _key = 'survivor_profile_v1';

  Future<SurvivorProfile> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return SurvivorProfile();
      final json = jsonDecode(raw);
      if (json is Map<String, Object?>) return SurvivorProfile.fromJson(json);
    } catch (e) {
      // 読めなくても最初から遊べるようにする
      debugPrint('記録を読み込めませんでした: $e');
    }
    return SurvivorProfile();
  }

  Future<void> save(SurvivorProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, jsonEncode(profile.toJson()));
    } catch (e) {
      debugPrint('記録を保存できませんでした: $e');
    }
  }
}
