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

  static const _keyBiometricUserId = 'biometric_user_id';
  static String? get biometricUserId => _prefs.getString(_keyBiometricUserId);
  static Future<void> setBiometricUserId(String? id) async {
    if (id == null) {
      await _prefs.remove(_keyBiometricUserId);
    } else {
      await _prefs.setString(_keyBiometricUserId, id);
    }
  }

  static const _keyCity = 'selected_city';

  static String? get selectedCity => _prefs.getString(_keyCity);
  static bool get hasCitySelected => _prefs.containsKey(_keyCity);
  static Future<void> setSelectedCity(String city) async {
    await _prefs.setString(_keyCity, city);
  }

  static const _keySelectedCities = 'selected_cities';

  static List<String> get selectedCities {
    final raw = _prefs.getString(_keySelectedCities);
    if (raw == null || raw.isEmpty) return [];
    try {
      return List<String>.from(jsonDecode(raw));
    } catch (_) {
      return [];
    }
  }

  static Future<void> setSelectedCities(List<String> cities) async {
    await _prefs.setString(_keySelectedCities, jsonEncode(cities));
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

