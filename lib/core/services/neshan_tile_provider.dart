import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import '../config/map_config.dart';

// Tile URL candidates to probe — first 200-OK wins.
// SSL bypass for *.neshan.org is handled globally via HttpOverrides in main.dart.
const _kCandidates = [
  // Dedicated tile subdomain — night & day styles
  'https://tile.neshan.org/v1/neshan-night/256/12/2632/1608',
  'https://tile.neshan.org/v1/neshan-day/256/12/2632/1608',
  'https://tile.neshan.org/v1/standard-night/256/12/2632/1608',
  'https://tile.neshan.org/v1/standard/256/12/2632/1608',
  // api subdomain variants
  'https://api.neshan.org/v4/map/12/2632/1608.png',
  'https://api.neshan.org/v4/tiles/12/2632/1608.png',
  'https://api.neshan.org/v4/tile/12/2632/1608.png',
];

// URL templates that correspond to each candidate (placeholders for flutter_map)
const _kTemplates = {
  'tile.neshan.org/v1/neshan-night': 'https://tile.neshan.org/v1/neshan-night/256/{z}/{x}/{y}',
  'tile.neshan.org/v1/neshan-day':   'https://tile.neshan.org/v1/neshan-day/256/{z}/{x}/{y}',
  'tile.neshan.org/v1/standard-night': 'https://tile.neshan.org/v1/standard-night/256/{z}/{x}/{y}',
  'tile.neshan.org/v1/standard':     'https://tile.neshan.org/v1/standard/256/{z}/{x}/{y}',
  'api.neshan.org/v4/map':           'https://api.neshan.org/v4/map/{z}/{x}/{y}.png',
  'api.neshan.org/v4/tiles':         'https://api.neshan.org/v4/tiles/{z}/{x}/{y}.png',
  'api.neshan.org/v4/tile':          'https://api.neshan.org/v4/tile/{z}/{x}/{y}.png',
};

String _templateFor(String candidate) {
  for (final e in _kTemplates.entries) {
    if (candidate.contains(e.key)) return e.value;
  }
  return MapConfig.neshanTileUrl;
}

bool _isNightStyle(String url) =>
    url.contains('night') || url.contains('Night');

// Dark inversion fallback — used only when night tiles are unavailable.
const _kDark = ColorFilter.matrix(<double>[
  -1, 0, 0, 0, 316,
   0, -1, 0, 0, 316,
   0, 0, -1, 0, 316,
   0, 0,  0, 1,   0,
]);

/// Dark Neshan tile layer. Auto-detects the correct tile URL on first load
/// and shows a badge with the result.
class NeshanTileLayer extends StatefulWidget {
  const NeshanTileLayer({super.key});

  @override
  State<NeshanTileLayer> createState() => _NeshanTileLayerState();
}

class _NeshanTileLayerState extends State<NeshanTileLayer> {
  static String? _badge;
  static String? _workingTemplate; // discovered at runtime

  String _localBadge = _badge ?? '';
  String _activeTemplate = _workingTemplate ?? MapConfig.neshanTileUrl;
  bool _useColorFilter = !_isNightStyle(_workingTemplate ?? '');

  @override
  void initState() {
    super.initState();
    if (_badge == null) _probe();
  }

  Future<void> _probe() async {
    for (final url in _kCandidates) {
      try {
        final resp = await http
            .get(Uri.parse(url), headers: {'Api-Key': MapConfig.neshanApiKey})
            .timeout(const Duration(seconds: 8));
        if (resp.statusCode == 200 && resp.bodyBytes.length > 500) {
          final template = _templateFor(url);
          final night = _isNightStyle(url);
          final badge =
              '✓ OK — ${url.replaceAll('https://', '').split('/').take(4).join('/')}';
          _badge = badge;
          _workingTemplate = template;
          if (mounted) {
            setState(() {
              _localBadge = badge;
              _activeTemplate = template;
              _useColorFilter = !night;
            });
          }
          return;
        }
        debugPrint('[Neshan] probe ${resp.statusCode} $url');
      } catch (e) {
        debugPrint('[Neshan] probe error $url: $e');
      }
    }
    const fail = '✗ نقشه: همه آدرس‌ها ۴۰۴/خطا';
    _badge = fail;
    if (mounted) setState(() => _localBadge = fail);
  }

  @override
  Widget build(BuildContext context) {
    final layer = TileLayer(
      urlTemplate: _activeTemplate,
      tileProvider: NeshanTileProvider(),
      userAgentPackageName: 'com.barberbook.app',
    );

    return Stack(
      children: [
        _useColorFilter
            ? ColorFiltered(colorFilter: _kDark, child: layer)
            : layer,
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

/// Tile provider — SSL bypass handled globally via HttpOverrides in main.dart.
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
    throw Exception('[Neshan] tile failed: $url');
  }

  @override
  bool operator ==(Object other) =>
      other is _NeshanTileImage && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
