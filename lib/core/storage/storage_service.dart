import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';

class StorageService {
  static late SharedPreferences _prefs;

  static const _keyToken = 'auth_token';
  static const _keyUser = 'user_data';

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

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
