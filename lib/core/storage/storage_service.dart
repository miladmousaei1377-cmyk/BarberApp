import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _keyToken = 'auth_token';
  static const _keyUser = 'user_data';
  static const _keyOnboardingSeen = 'onboarding_seen';
  static const _keyBiometric = 'biometric_enabled';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveToken(String token) async {
    await _prefs.setString(_keyToken, token);
  }

  static String? getToken() => _prefs.getString(_keyToken);

  static Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  static UserModel? getUser() {
    final data = _prefs.getString(_keyUser);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  static bool get isLoggedIn => getToken() != null && getUser() != null;

  static bool get onboardingSeen => _prefs.getBool(_keyOnboardingSeen) ?? false;

  static Future<void> setOnboardingSeen() async {
    await _prefs.setBool(_keyOnboardingSeen, true);
  }

  static bool get biometricEnabled => _prefs.getBool(_keyBiometric) ?? false;

  static Future<void> setBiometricEnabled(bool value) async {
    await _prefs.setBool(_keyBiometric, value);
  }

  /// Clears only auth data — does NOT reset onboarding flag.
  static Future<void> logout() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyUser);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}

