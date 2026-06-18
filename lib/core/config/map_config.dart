class MapConfig {
  static const neshanApiKey = 'web.0e5dc896eb2f44388d6ad1c23fa3ee40';
  // Base tile URL — key is sent via Api-Key header by NeshanTileProvider
  static const neshanTileUrl =
      'https://api.neshan.org/v4/tile/{z}/{x}/{y}.png';
  static const neshanGeocodeUrl = 'https://api.neshan.org/v5/geocoding';
}
