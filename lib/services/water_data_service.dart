import 'package:http/http.dart' as http;
import 'package:csv2json/csv2json.dart';

// Enum for contaminants
enum ContaminantType { PFOA, Lead, Nitrates, Phosphates }

typedef ContaminantData = dynamic; // You can define a stricter type if needed

class WaterDataService {
  // Map to store data for each contaminant
  static final Map<ContaminantType, ContaminantData> _contaminantData = {};

  // Public getter for contaminant data
  static ContaminantData? getContaminantData(dynamic type) {
    if (type is ContaminantType) {
      return _contaminantData[type];
    } else if (type is List<ContaminantType>) {
      // Return a map of contaminant type to data
      final Map<ContaminantType, ContaminantData?> result = {};
      for (final t in type) {
        result[t] = _contaminantData[t];
      }
      return result;
    } else {
      throw ArgumentError(
        'type must be ContaminantType or List<ContaminantType>',
      );
    }
  }

  // Main entry: fetch all selected contaminants
  static Future<void> fetchAll({
    required double latitude,
    required double longitude,
    int radiusMiles = 10,
    List<ContaminantType>? contaminants,
  }) async {
    final types = contaminants ?? [ContaminantType.PFOA];
    for (final contaminant in types) {
      switch (contaminant) {
        case ContaminantType.PFOA:
          _contaminantData[ContaminantType.PFOA] = await fetchPFOAData(
            latitude,
            longitude,
            radiusMiles: radiusMiles,
          );
          break;

        case ContaminantType.Lead:
          // Implement fetchLeadData similarly
          _contaminantData[ContaminantType.Lead] = await fetchLeadData(
            latitude,
            longitude,
            radiusMiles: radiusMiles,
          );
          break;

        case ContaminantType.Nitrates:
          // Implement fetchNitratesData similarly
          _contaminantData[ContaminantType.Nitrates] = {}; // Placeholder
          break;

        case ContaminantType.Phosphates:
          // Implement fetchPhosphatesData similarly
          _contaminantData[ContaminantType.Phosphates] = {}; // Placeholder
          break;
      }
    }
  }

  static Future<ContaminantData> fetchPFOAData(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
  }) async {
    final baseUrl =
        'https://www.waterqualitydata.us/wqx3/Result/search'; // Replace with real endpoint
    final pCodes = 'pCode=53581&pCode=54083&pCode=54116';
    final locationString = 'within=$radiusMiles&lat=$latitude&long=$longitude';
    final url = Uri.parse(
      '$baseUrl?$locationString&$pCodes&mimeType=csv&dataProfile=fullPhysChem&providers=NWIS&providers=STORET',
    );
    print('Fetching PFOA data from: $url');
    try {
      final response = await http.get(url);
      final csvString = response.body;
      final data = csv2json(csvString);
      // print(csvString);
      return data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  static Future<ContaminantData> fetchLeadData(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
  }) async {
    final baseUrl = 'https://www.waterqualitydata.us/wqx3/Result/search';
    final locationString = 'within=$radiusMiles&lat=$latitude&long=$longitude';
    final characteristics =
        'characteristicName=Lead&startDateLo=06-11-2023&startDateHi=06-11-2025';
    final url = Uri.parse(
      '$baseUrl?$locationString&$characteristics&mimeType=csv&dataProfile=fullPhysChem&providers=NWIS&providers=STORET',
    );
    print('Fetching Lead data from: $url');
    try {
      final response = await http.get(url);
      final csvString = response.body;
      final data = csv2json(csvString);
      // print(data);
      return data;
    } catch (e) {
      print(e);
      return {};
    }
  }

  // TODO: More contaminant fetchers
}
