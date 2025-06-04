import 'package:http/http.dart' as http;
import 'package:csv2json/csv2json.dart';

class WaterDataService {
  static Future<dynamic> fetchLocations(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
    List<String> parameterCodes = const [],
  }) async {
    // https://www.waterqualitydata.us/data/Station/search?within=50&lat=40.8450086&long=-73.9813876&startDateLo=01-01-2025&startDateHi=05-24-2025&mimeType=geojson&providers=NWIS&providers=STORET
    // https://www.waterqualitydata.us/data/Station/search&within=50&lat=40.8449793&long=-73.9813663&startDateLo=01-01-2025&startDateHi=05-24-2025&mimeType=geojson&providers=NWIS&providers=STORET
    final baseUrl = 'https://www.waterqualitydata.us/wqx3/Result/search';
    final locationString = 'within=$radiusMiles&lat=$latitude&long=$longitude';
    final pCodes = parameterCodes.isNotEmpty
        ? parameterCodes.map((code) => 'pCode=$code').join('&')
        : '';
    final url = Uri.parse(
      '$baseUrl?$locationString&${pCodes.isNotEmpty ? '$pCodes&' : ''}mimeType=csv&dataProfile=fullPhysChem&providers=NWIS&providers=STORET',
    );
    print('Fetching data from: $url');

    try {
      final response = await http.get(url);
      final csvString = response.body;
      final data = csv2json(csvString);
      print(data);

      return data;
    } catch (e) {
      print(e);
      return {};
    }
  }
}
