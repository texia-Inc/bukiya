import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../constants/app_constants.dart';

class DeviceService {
  static final DeviceService _instance = DeviceService._internal();
  factory DeviceService() => _instance;
  DeviceService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _cachedDeviceId;

  /// デバイス固有IDを取得または生成
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    // 既存のデバイスIDを確認
    String? existingDeviceId = await _secureStorage.read(key: AppConstants.deviceIdKey);
    if (existingDeviceId != null && existingDeviceId.isNotEmpty) {
      _cachedDeviceId = existingDeviceId;
      return existingDeviceId;
    }

    // 新しいデバイスIDを生成
    final deviceId = await _generateDeviceId();
    await _secureStorage.write(key: AppConstants.deviceIdKey, value: deviceId);
    _cachedDeviceId = deviceId;
    
    return deviceId;
  }

  /// プラットフォーム固有のデバイス情報を取得してハッシュ化
  Future<String> _generateDeviceId() async {
    final deviceInfo = await _getDeviceInfo();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomBytes = _generateRandomBytes(16);
    
    // デバイス情報 + タイムスタンプ + ランダムバイトを組み合わせてハッシュ化
    final combinedInfo = '$deviceInfo-$timestamp-$randomBytes';
    final bytes = utf8.encode(combinedInfo);
    final digest = sha256.convert(bytes);
    
    return 'bukiya_${digest.toString().substring(0, 32)}';
  }

  /// プラットフォーム固有のデバイス情報を取得
  Future<String> _getDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.model}-${androidInfo.brand}-${androidInfo.device}-${androidInfo.id}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return '${iosInfo.model}-${iosInfo.name}-${iosInfo.systemName}-${iosInfo.identifierForVendor}';
      } else {
        // その他のプラットフォーム（Web、デスクトップ等）
        return 'unknown-platform-${Platform.operatingSystem}';
      }
    } catch (e) {
      // デバイス情報取得に失敗した場合はフォールバック
      return 'fallback-${Platform.operatingSystem}-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// ランダムバイト文字列を生成
  String _generateRandomBytes(int length) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (i) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// デバイス情報を取得（デバッグ用）
  Future<Map<String, dynamic>> getDeviceInfo() async {
    final deviceId = await getDeviceId();
    
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'deviceId': deviceId,
        'platform': 'Android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'device': androidInfo.device,
        'version': androidInfo.version.release,
        'sdkInt': androidInfo.version.sdkInt,
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'deviceId': deviceId,
        'platform': 'iOS',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemName': iosInfo.systemName,
        'systemVersion': iosInfo.systemVersion,
        'identifierForVendor': iosInfo.identifierForVendor,
      };
    }

    return {
      'deviceId': deviceId,
      'platform': Platform.operatingSystem,
    };
  }

  /// デバイスIDをリセット（テスト用）
  Future<void> resetDeviceId() async {
    await _secureStorage.delete(key: AppConstants.deviceIdKey);
    _cachedDeviceId = null;
  }

  /// 信頼済みデバイスとしてマーク
  Future<void> markAsTrustedDevice() async {
    await _secureStorage.write(key: 'is_trusted_device', value: 'true');
  }

  /// 信頼済みデバイスかどうかを確認
  Future<bool> isTrustedDevice() async {
    final trusted = await _secureStorage.read(key: 'is_trusted_device');
    return trusted == 'true';
  }
}