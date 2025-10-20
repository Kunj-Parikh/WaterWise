import 'package:http/http.dart' as http;
import 'package:csv2json/csv2json.dart';

// Enum for contaminants
enum ContaminantType { PFOAion, Lead, Nitrate, Phosphate, Arsenic }

typedef ContaminantData = dynamic;

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
    final types = contaminants ?? [ContaminantType.PFOAion];
    for (final contaminant in types) {
      switch (contaminant) {
        case ContaminantType.PFOAion:
          _contaminantData[ContaminantType.PFOAion] = await fetchPFOAIonData(
            latitude,
            longitude,
            radiusMiles: radiusMiles,
          );
          break;
        case ContaminantType.Lead:
          _contaminantData[ContaminantType.Lead] = await fetchLeadData(
            latitude,
            longitude,
            radiusMiles: radiusMiles,
          );
          break;
        case ContaminantType.Nitrate:
          _contaminantData[ContaminantType.Nitrate] = await fetchNitrateData(
            latitude,
            longitude,
            radiusMiles: radiusMiles,
          );
          break;
        case ContaminantType.Phosphate:
          _contaminantData[ContaminantType.Phosphate] =
              await fetchPhosphateData(
                latitude,
                longitude,
                radiusMiles: radiusMiles,
              );
          break;
        case ContaminantType.Arsenic:
          _contaminantData[ContaminantType.Arsenic] = await fetchArsenicData(
            latitude,
            longitude,
            radiusMiles: radiusMiles,
          );
          break;
      }
    }
  }

  static Future<ContaminantData> fetchPFOAIonData(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
  }) async {
    final baseUrl = 'https://www.waterqualitydata.us/wqx3/Result/search';
    final locationString = 'within=$radiusMiles&lat=$latitude&long=$longitude';
    final characteristics = 'characteristicName=PFOA%20ion';
    final url = Uri.parse(
      '$baseUrl?$locationString&$characteristics&mimeType=csv&dataProfile=fullPhysChem&providers=NWIS&providers=STORET',
    );
    print('Fetching PFOA ion data from: $url');
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

  static Future<ContaminantData> fetchNitrateData(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
  }) async {
    final baseUrl = 'https://www.waterqualitydata.us/wqx3/Result/search';
    final locationString = 'within=$radiusMiles&lat=$latitude&long=$longitude';
    final characteristics =
        'characteristicName=Nitrate&startDateLo=06-11-2023&startDateHi=06-11-2025';
    final url = Uri.parse(
      '$baseUrl?$locationString&$characteristics&mimeType=csv&dataProfile=fullPhysChem&providers=NWIS&providers=STORET',
    );
    print('Fetching Nitrate data from: $url');
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

  static Future<ContaminantData> fetchPhosphateData(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
  }) async {
    final baseUrl = 'https://www.waterqualitydata.us/wqx3/Result/search';
    final locationString = 'within=$radiusMiles&lat=$latitude&long=$longitude';
    final characteristics =
        'characteristicName=Phosphate&startDateLo=06-11-2023&startDateHi=06-11-2025';
    final url = Uri.parse(
      '$baseUrl?$locationString&$characteristics&mimeType=csv&dataProfile=fullPhysChem&providers=NWIS&providers=STORET',
    );
    print('Fetching Phosphate data from: $url');
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

  static Future<ContaminantData> fetchArsenicData(
    double latitude,
    double longitude, {
    int radiusMiles = 10,
  }) async {
    final baseUrl = 'https://www.waterqualitydata.us/wqx3/Result/search';
    final locationString = 'within=$radiusMiles&lat=$latitude&long=$longitude';
    final characteristics =
        'characteristicName=Arsenic&startDateLo=06-11-2023&startDateHi=06-11-2025';
    final url = Uri.parse(
      '$baseUrl?$locationString&$characteristics&mimeType=csv&dataProfile=fullPhysChem&providers=NWIS&providers=STORET',
    );
    print('Fetching Arsenic data from: $url');
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
}
