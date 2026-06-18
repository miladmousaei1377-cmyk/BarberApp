import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import '../config/map_config.dart';

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
    final resp = await client
        .get(Uri.parse(url), headers: {'Api-Key': MapConfig.neshanApiKey})
        .timeout(const Duration(seconds: 10));
    if (resp.statusCode != 200) {
      throw Exception('Neshan tile HTTP ${resp.statusCode}');
    }
    final buffer = await ui.ImmutableBuffer.fromUint8List(resp.bodyBytes);
    return decode(buffer);
  }

  @override
  bool operator ==(Object other) =>
      other is _NeshanTileImage && url == other.url;

  @override
  int get hashCode => url.hashCode;
}
