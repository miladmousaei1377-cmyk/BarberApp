class MapConfig {
  static const neshanApiKey = 'web.10323aaf6a5245df882040de3ad5b854';
  // Base tile URL — key is sent via Api-Key header by NeshanTileProvider
  static const neshanTileUrl =
      'https://api.neshan.org/v4/tile/{z}/{x}/{y}.png';
  static const neshanGeocodeUrl = 'https://api.neshan.org/v5/geocoding';
}
