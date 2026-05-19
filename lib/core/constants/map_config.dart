class MapConfig {
  static const String _stadiaKey = String.fromEnvironment('STADIA_MAPS_API_KEY');

  static String get tileUrlTemplate {
    if (_stadiaKey.isEmpty) {
      // Key verilmemişse OpenStreetMap tile'ları kullan (key gerektirmez)
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
    return 'https://tiles.stadiamaps.com/tiles/osm_bright/{z}/{x}/{y}.png'
        '?api_key=$_stadiaKey';
  }
}
