import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import '../config/map_config.dart';

// Slight contrast boost (×1.15) with minimal brightness lift (+10):
//   black  → near-black (deep Divar-style dark background)
//   white  → 255 (map labels stay pure white)
// Adjust _kContrast / _kLift to tune the appearance.
const _kContrast = 1.15;
const _kLiftAmt = 10.0;

const _kLift = ColorFilter.matrix(<double>[
  _kContrast, 0,          0,          0, _kLiftAmt,
  0,          _kContrast, 0,          0, _kLiftAmt,
  0,          0,          _kContrast, 0, _kLiftAmt,
  0,          0,          0,          1, 0,
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

