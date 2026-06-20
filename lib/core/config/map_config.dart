class MapConfig {
  static const neshanApiKey = 'service.2109677e8eda48f79d245b2cbf8a2ad2';
  // Base tile URL — key is sent via Api-Key header by NeshanTileProvider
  static const neshanTileUrl =
      'https://api.neshan.org/v4/tile/{z}/{x}/{y}.png';
  static const neshanGeocodeUrl = 'https://api.neshan.org/v5/geocoding';
}
