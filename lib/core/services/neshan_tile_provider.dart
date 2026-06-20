import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import '../config/map_config.dart';

/// Dark map tile layer using CartoDB Dark Matter.
/// Free, no authentication, native dark theme, Persian labels via OSM data.
/// Neshan service keys do not support tile streaming — only geocoding.
class NeshanTileLayer extends StatelessWidget {
  const NeshanTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: MapConfig.tileUrl,
      subdomains: MapConfig.tileSubdomains,
      userAgentPackageName: 'com.barberbook.app',
      retinaMode: MediaQuery.devicePixelRatioOf(context) > 1.0,
    );
  }
}
