class MapConfig {
  static const neshanApiKey = 'service.2109677e8eda48f79d245b2cbf8a2ad2';

  // Neshan service keys don't support tile streaming — only geocoding/routing.
  // We use CartoDB Light tiles: free, no auth, white/black theme, Persian labels.
  static const tileUrl =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  static const tileSubdomains = ['a', 'b', 'c', 'd'];

  // Neshan geocoding (address ↔ coordinates) — works fine with service key.
  static const neshanGeocodeUrl = 'https://api.neshan.org/v5/geocoding';
}
