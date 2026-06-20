import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../config/map_config.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/salon_model.dart';

// SSL bypass for *.neshan.org is handled globally via HttpOverrides in main.dart.

class NeshanService {
  static const _headers = {'Api-Key': MapConfig.neshanApiKey};

  /// Geocode a Persian address → LatLng; returns null on failure.
  static Future<LatLng?> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    try {
      final uri = Uri.parse(MapConfig.neshanGeocodeUrl)
          .replace(queryParameters: {'address': address});
      final resp = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final loc = data['location'] as Map<String, dynamic>?;
        if (loc != null) {
          return LatLng(
            (loc['y'] as num).toDouble(),
            (loc['x'] as num).toDouble(),
          );
        }
      }
    } catch (_) {}
    return null;
  }

  /// Client-side haversine filter — returns salons within [radiusKm] of [center],
  /// sorted by distance. Falls back to all salons with valid coords if center unknown.
  static List<SalonModel> getNearbySalons(LatLng? center, double radiusKm) {
    final all = MockData.salons.where((s) => s.lat != 0.0 && s.lng != 0.0).toList();
    if (center == null) return all;
    final nearby = <MapEntry<SalonModel, double>>[];
    for (final s in all) {
      final d = _haversine(center, LatLng(s.lat, s.lng));
      if (d <= radiusKm) nearby.add(MapEntry(s, d));
    }
    nearby.sort((a, b) => a.value.compareTo(b.value));
    return nearby.map((e) => e.key).toList();
  }

  static double _haversine(LatLng a, LatLng b) {
    const R = 6371.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);
    final x = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(a.latitude)) * cos(_rad(b.latitude)) *
            sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(x), sqrt(1 - x));
  }

  static double _rad(double deg) => deg * pi / 180;
}
