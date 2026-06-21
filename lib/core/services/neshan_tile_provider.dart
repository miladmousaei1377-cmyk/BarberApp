import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import '../config/map_config.dart';

/// Light map tile layer — CartoDB Light Matter (white background, black labels).
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
