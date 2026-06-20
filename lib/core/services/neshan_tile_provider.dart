import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import '../config/map_config.dart';

/// Pre-configured dark-themed tile layer.
/// Applies a color-inversion [ColorFilter] to standard Neshan tiles to produce
/// a dark/night appearance close to Neshan's standard-night style — without
/// relying on a tile-server style parameter (not supported via the REST v4
/// tile API with a web key).
class NeshanTileLayer extends StatelessWidget {
  const NeshanTileLayer({super.key});

  // Maps white (#FFF) → ~#3D3D3D dark-grey (not pure black), matching
  // Neshan's visual night palette.
  static const _kDark = ColorFilter.matrix(<double>[
    -1, 0, 0, 0, 316,
     0, -1, 0, 0, 316,
     0, 0, -1, 0, 316,
     0, 0,  0, 1,   0,
  ]);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: _kDark,
      child: TileLayer(
        urlTemplate: MapConfig.neshanTileUrl,
        tileProvider: NeshanTileProvider(),
        userAgentPackageName: 'com.barberbook.app',
      ),
    );
  }
}

/// Custom tile provider that sends the Neshan Api-Key header via
/// the `http` package directly — bypasses Flutter's NetworkImage
/// which does not reliably forward custom headers on Android.
class NeshanTileProvider extends TileProvider {
  final http.Client _client = http.Client();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _NeshanTileImage(getTileUrl(coordinates, options), _client);
  }
}

class _NeshanTileImage extends ImageProvider<_NeshanTileImage> {
  final String url;
  final http.Client client;

  const _NeshanTileImage(this.url, this.client);

  @override
  Future<_NeshanTileImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<_NeshanTileImage>(this);

  @override
  ImageStreamCompleter loadImage(
    _NeshanTileImage key,
    ImageDecoderCallback decode,
  ) =>
      MultiFrameImageStreamCompleter(
        codec: _fetch(key, decode),
        scale: 1.0,
        informationCollector: () => [DiagnosticsProperty('URL', url)],
      );

  Future<ui.Codec> _fetch(
    _NeshanTileImage key,
    ImageDecoderCallback decode,
  ) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final resp = await client
            .get(Uri.parse(url), headers: {'Api-Key': MapConfig.neshanApiKey})
            .timeout(const Duration(seconds: 10));
        if (resp.statusCode == 200) {
          final buffer = await ui.ImmutableBuffer.fromUint8List(resp.bodyBytes);
          return decode(buffer);
        }
        debugPrint(
          '[Neshan] Tile error attempt ${attempt + 1}: '
          'HTTP ${resp.statusCode} | ${resp.body.substring(0, resp.body.length.clamp(0, 200))} | $url',
        );
      } catch (e) {
        debugPrint('[Neshan] Tile exception attempt ${attempt + 1}: $e | $url');
      }
      if (attempt == 0) await Future.delayed(const Duration(milliseconds: 500));
    }
    throw Exception('[Neshan] Failed to load tile after 2 attempts: $url');
  }

  @override
  bool operator ==(Object other) =>
      other is _NeshanTileImage && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
