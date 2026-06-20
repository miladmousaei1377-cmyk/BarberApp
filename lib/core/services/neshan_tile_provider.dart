import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import '../config/map_config.dart';

// Dark inversion: white → #3D3D3D, streets become light on dark background.
const _kDark = ColorFilter.matrix(<double>[
  -1, 0, 0, 0, 316,
   0, -1, 0, 0, 316,
   0, 0, -1, 0, 316,
   0, 0,  0, 1,   0,
]);

/// Pre-configured dark Neshan tile layer with a one-time diagnostic badge.
class NeshanTileLayer extends StatefulWidget {
  const NeshanTileLayer({super.key});

  @override
  State<NeshanTileLayer> createState() => _NeshanTileLayerState();
}

class _NeshanTileLayerState extends State<NeshanTileLayer> {
  static String? _badge;
  String _localBadge = _badge ?? '';

  @override
  void initState() {
    super.initState();
    if (_badge == null) _runDiagnostic();
  }

  Future<void> _runDiagnostic() async {
    // Tehran centre at zoom 12
    const testUrl = 'https://api.neshan.org/v4/tile/12/2632/1608.png';
    try {
      final resp = await http
          .get(Uri.parse(testUrl), headers: {'Api-Key': MapConfig.neshanApiKey})
          .timeout(const Duration(seconds: 10));
      final result = resp.statusCode == 200
          ? '✓ نقشه OK (${resp.bodyBytes.length}B)'
          : '✗ HTTP ${resp.statusCode}';
      _badge = result;
      if (mounted) setState(() => _localBadge = result);
    } catch (e) {
      final result = '✗ $e';
      _badge = result;
      if (mounted) setState(() => _localBadge = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: _kDark,
          child: TileLayer(
            urlTemplate: MapConfig.neshanTileUrl,
            tileProvider: NeshanTileProvider(),
            userAgentPackageName: 'com.barberbook.app',
          ),
        ),
        if (_localBadge.isNotEmpty)
          Positioned(
            bottom: 2,
            left: 2,
            child: _DiagBadge(_localBadge),
          ),
      ],
    );
  }
}

class _DiagBadge extends StatelessWidget {
  final String text;
  const _DiagBadge(this.text);

  @override
  Widget build(BuildContext context) {
    final ok = text.startsWith('✓');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: (ok ? const Color(0xFF388E3C) : const Color(0xFFD32F2F))
            .withOpacity(0.88),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 10,
          fontFamily: 'Vazirmatn',
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

/// Tile provider — SSL bypass is handled globally via HttpOverrides in main.dart.
class NeshanTileProvider extends TileProvider {
  final _client = http.Client();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _NeshanTileImage(getTileUrl(coordinates, options), _client);

  @override
  void dispose() {
    _client.close();
    super.dispose();
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
        codec: _fetch(decode),
        scale: 1.0,
        informationCollector: () => [DiagnosticsProperty('URL', url)],
      );

  Future<ui.Codec> _fetch(ImageDecoderCallback decode) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final resp = await client
            .get(Uri.parse(url), headers: {'Api-Key': MapConfig.neshanApiKey})
            .timeout(const Duration(seconds: 12));
        if (resp.statusCode == 200) {
          final buffer =
              await ui.ImmutableBuffer.fromUint8List(resp.bodyBytes);
          return decode(buffer);
        }
        debugPrint('[Neshan] tile HTTP ${resp.statusCode} (attempt ${attempt + 1}) $url');
      } catch (e) {
        debugPrint('[Neshan] tile error (attempt ${attempt + 1}): $e');
      }
      if (attempt == 0) await Future.delayed(const Duration(milliseconds: 600));
    }
    throw Exception('[Neshan] tile failed after 2 attempts: $url');
  }

  @override
  bool operator ==(Object other) =>
      other is _NeshanTileImage && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
