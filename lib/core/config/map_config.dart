class MapConfig {
  static const neshanApiKey = 'web.0e5dc896eb2f44388d6ad1c23fa3ee40';
  // Key embedded in URL — avoids custom-header auth issues on mobile
  static const neshanTileUrl =
      'https://api.neshan.org/v4/tile/{z}/{x}/{y}.png'
      '?key=web.0e5dc896eb2f44388d6ad1c23fa3ee40&type=neshan-day';
  static const neshanGeocodeUrl = 'https://api.neshan.org/v5/geocoding';
}
