import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import '../config/map_config.dart';

// Lifts blacks (+45) and boosts contrast (×1.2) so:
//   black  → #2D2D2D (dark grey background)
//   white  → 255     (map labels stay pure white)
//   near-white (≥175) → clamped to 255  (ensures text is clearly white)
const _kLift = ColorFilter.matrix(<double>[
  1.2, 0,   0,   0, 45,
  0,   1.2, 0,   0, 45,
  0,   0,   1.2, 0, 45,
  0,   0,   0,   1,  0,
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

