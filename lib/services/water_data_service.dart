// lib/services/water_data_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class WaterDataService {
  static Future<dynamic> fetchLocations(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
  }) async {
    // https://www.waterqualitydata.us/data/Station/search?within=50&lat=40.8450086&long=-73.9813876&startDateLo=01-01-2025&startDateHi=05-24-2025&mimeType=geojson&providers=NWIS&providers=STORET
    // https://www.waterqualitydata.us/data/Station/search&within=50&lat=40.8449793&long=-73.9813663&startDateLo=01-01-2025&startDateHi=05-24-2025&mimeType=geojson&providers=NWIS&providers=STORET
    final baseUrl = 'https://www.waterqualitydata.us/data/Station/search';
    final locationString =
        'within=$radiusMiles&lat=$latitude&long=$longitude&mimeType=geojson&providers=NWIS&providers=STORET';
    final url = Uri.parse('$baseUrl?$locationString');
    print('Fetching data from: $url');

    try {
      final response = await http.get(url);
      // print('Response: [1m${response.body}[0m');
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
      return {};
    }
  }
}
