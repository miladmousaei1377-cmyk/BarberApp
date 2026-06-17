import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/user_model.dart';
import '../../data/models/salon_model.dart';
import '../../data/models/stylist_model.dart';
import '../../data/models/service_model.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/review_model.dart';

class DataService {
  static const _keyUsers = 'app_users';
  static const _keySalons = 'app_salons';
  static const _keyStylists = 'app_stylists';
  static const _keyServices = 'app_services';
  static const _keyAppointments = 'app_appointments';
  static const _keyReviews = 'app_reviews';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveAll() async {
    try {
      await _prefs.setString(_keyUsers, jsonEncode(MockData.users.map((u) => u.toJson()).toList()));
      await _prefs.setString(_keySalons, jsonEncode(MockData.salons.map((s) => s.toJson()).toList()));
      await _prefs.setString(_keyStylists, jsonEncode(MockData.stylists.map((s) => s.toJson()).toList()));
      await _prefs.setString(_keyServices, jsonEncode(MockData.services.map((s) => s.toJson()).toList()));
      await _prefs.setString(_keyAppointments, jsonEncode(MockData.appointments.map((a) => a.toJson()).toList()));
      await _prefs.setString(_keyReviews, jsonEncode(MockData.reviews.map((r) => r.toJson()).toList()));
    } catch (_) {}
  }

  static void loadAll() {
    try {
      _loadList(_keyUsers, (j) => UserModel.fromJson(j), (list) => MockData.users = list.cast<UserModel>());
      _loadList(_keySalons, (j) => SalonModel.fromJson(j), (list) => MockData.salons = list.cast<SalonModel>());
      _loadList(_keyStylists, (j) => StylistModel.fromJson(j), (list) => MockData.stylists = list.cast<StylistModel>());
      _loadList(_keyServices, (j) => ServiceModel.fromJson(j), (list) => MockData.services = list.cast<ServiceModel>());
      _loadList(_keyAppointments, (j) => AppointmentModel.fromJson(j), (list) => MockData.appointments = list.cast<AppointmentModel>());
      _loadList(_keyReviews, (j) => ReviewModel.fromJson(j), (list) => MockData.reviews = list.cast<ReviewModel>());
    } catch (_) {}
  }

  static void _loadList(String key, dynamic Function(Map<String, dynamic>) fromJson, void Function(List) setter) {
    final json = _prefs.getString(key);
    if (json != null) {
      final list = (jsonDecode(json) as List).map((j) => fromJson(j as Map<String, dynamic>)).toList();
      setter(list);
    }
  }

  static Future<void> clear() async {
    await _prefs.remove(_keyUsers);
    await _prefs.remove(_keySalons);
    await _prefs.remove(_keyStylists);
    await _prefs.remove(_keyServices);
    await _prefs.remove(_keyAppointments);
    await _prefs.remove(_keyReviews);
  }
}
