import 'package:geocoding/geocoding.dart';
import 'package:dart_geohash/dart_geohash.dart';

// 根據地址產生對應的 google map 連結
String generateGoogleMapLink(String address) {
  final q = Uri.encodeComponent(address);
  final url = 'https://www.google.com/maps/search/?api=1&query=$q';
  return url;
}

// 根據地址回傳 latitude, longitude, geohash
Future<Map<String, dynamic>> convertAddressToGeohash(String address) async {
  try {
    // get the lat lon from address
    List<Location> locations = await locationFromAddress(address);
    if (locations.isEmpty) {
      throw Exception('查無地址對應的經緯度');
    }

    final location = locations.first;
    final lat = location.latitude;
    final lon = location.longitude;

    // turn into geohash
    final geoHasher = GeoHasher();
    // precision can be larger ?
    final hash = geoHasher.encode(lon, lat, precision: 5);

    return {
      'latitude': lat,
      'longitude': lon,
      'geohash': hash,
    };
  } catch (e) {
    throw Exception('地址轉換失敗：$e');
  }
}
