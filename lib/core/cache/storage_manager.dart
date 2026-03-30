import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageManager {
  StorageManager._();
  static final StorageManager instance = StorageManager._();

  late SharedPreferences _sharedPreferences;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// لازم تتنادي قبل runApp
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  // ================= SharedPreferences =================

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) {
      return _sharedPreferences.setString(key, value);
    }
    if (value is bool) {
      return _sharedPreferences.setBool(key, value);
    }
    if (value is int) {
      return _sharedPreferences.setInt(key, value);
    }
    if (value is double) {
      return _sharedPreferences.setDouble(key, value);
    }
    throw UnsupportedError('Unsupported type');
  }

  T? getData<T>({required String key}) {
    return _sharedPreferences.get(key) as T?;
  }

  Future<bool> removeData({required String key}) async {
    return _sharedPreferences.remove(key);
  }

  bool containsKey(String key) {
    return _sharedPreferences.containsKey(key);
  }

  // ================= Onboarding =================

  bool hasSeenOnboarding() {
    return getData<bool>(key: 'hasSeenOnboarding') ?? false;
  }

  Future<void> setHasSeenOnboarding() async {
    await saveData(key: 'hasSeenOnboarding', value: true);
  }

  // ================= Secure Storage =================

  Future<void> setSecuredString({
    required String key,
    required String value,
  }) async {
    await _secureStorage.write(key: key, value: value);
  }

  Future<String> getSecuredString({required String key}) async {
    return await _secureStorage.read(key: key) ?? '';
  }

  Future<void> removeSecuredString({required String key}) async {
    await _secureStorage.delete(key: key);
  }

  Future<void> clearAllSecuredData() async {
    await _secureStorage.deleteAll();
  }
}
