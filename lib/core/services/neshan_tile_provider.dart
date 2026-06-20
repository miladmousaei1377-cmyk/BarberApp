import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import '../config/map_config.dart';

// Lifts blacks by +60/255 ≈ 24%:  pure black → #3C3C3C (medium grey like Divar).
// Whites stay white (255+60 clamped to 255). Streets become visible grey lines.
const _kLift = ColorFilter.matrix(<double>[
  1, 0, 0, 0, 60,
  0, 1, 0, 0, 60,
  0, 0, 1, 0, 60,
  0, 0, 0, 1,  0,
]);

/// Dark map tile layer — CartoDB Dark Matter with brightness lift to match
/// the medium-grey aesthetic of apps like Divar.
class NeshanTileLayer extends StatelessWidget {
  const NeshanTileLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: _kLift,
      child: TileLayer(
        urlTemplate: MapConfig.tileUrl,
        subdomains: MapConfig.tileSubdomains,
        userAgentPackageName: 'com.barberbook.app',
        retinaMode: MediaQuery.devicePixelRatioOf(context) > 1.0,
      ),
    );
  }
}

