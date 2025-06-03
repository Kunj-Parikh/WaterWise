import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../services/water_data_service.dart';
import 'adaptive_map.dart';

class WaterQualityHomePage extends StatefulWidget {
  const WaterQualityHomePage({super.key});
  @override
  WaterQualityHomePageState createState() => WaterQualityHomePageState();
}

class WaterQualityHomePageState extends State<WaterQualityHomePage> {
  final Map<String, String> parameterNames = {
    '52644': 'PFOS',
    '53590': 'PFOS',
    '54084': 'PFOS',

    // '54117': 'PFOS',
    // '54137': 'PFOS',
    // '54205': 'PFOS',
    // '54206': 'PFOS',
    // '54248': 'PFOS',
    // '54280': 'PFOS',
    // '54312': 'PFOS',
    // '54673': 'PFOS',
    // '54674': 'PFOS',
    // '54675': 'PFOS',
    // '54784': 'PFOS',
    // '57926': 'PFOS',
    // '58010': 'PFOS',
    '53581': 'PFOA',
    '54083': 'PFOA',
    '54116': 'PFOA',
    // '54136': 'PFOA',
    // '54255': 'PFOA',
    // '54287': 'PFOA',
    // '54319': 'PFOA',
    // '54651': 'PFOA',
    // '54652': 'PFOA',
    // '54669': 'PFOA',
    // '54670': 'PFOA',
    // '54671': 'PFOA',
    // '54773': 'PFOA',
    // '57915': 'PFOA',
    // '57982': 'PFOA',
    // '58009': 'PFOA',
    // '63651': 'PFOA',
    // '65227': 'PFOA',
  };
  bool loading = false;
  LatLng? _currentPosition;
  List<Marker> _markers = [];
  List<dynamic> results = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Handle the case when permission is not granted
        return;
      }
    }
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
    await fetchLocations();
  }

  Future<void> fetchLocations() async {
    if (_currentPosition == null) return;
    setState(() => loading = true);
    final data = await WaterDataService.fetchLocations(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      radiusMiles: 10,
      parameterCodes: parameterNames.keys.toList(),
    );
    // Expecting a flat list of maps (as in test.json)
    List<dynamic> locations = [];
    try {
      if (data is List) {
        locations = data;
      }
    } catch (e) {
      print('Error extracting locations: $e');
    }
    setState(() {
      results = locations;
      // Filter valid locations with coordinates
      final validLocations = locations.where((item) {
        double? lat =
            _parseDouble(item['Location_LatitudeStandardized']) ??
            _parseDouble(item['Location_Latitude']);
        double? lng =
            _parseDouble(item['Location_LongitudeStandardized']) ??
            _parseDouble(item['Location_Longitude']);
        return lat != null && lng != null;
      }).toList();
      // Sort by great circle distance to current location
      final Distance distance = Distance();
      validLocations.sort((a, b) {
        double latA =
            _parseDouble(a['Location_LatitudeStandardized']) ??
            _parseDouble(a['Location_Latitude'])!;
        double lngA =
            _parseDouble(a['Location_LongitudeStandardized']) ??
            _parseDouble(a['Location_Longitude'])!;
        double latB =
            _parseDouble(b['Location_LatitudeStandardized']) ??
            _parseDouble(b['Location_Latitude'])!;
        double lngB =
            _parseDouble(b['Location_LongitudeStandardized']) ??
            _parseDouble(b['Location_Longitude'])!;
        final dA = distance.as(
          LengthUnit.Kilometer,
          _currentPosition!,
          LatLng(latA, lngA),
        );
        final dB = distance.as(
          LengthUnit.Kilometer,
          _currentPosition!,
          LatLng(latB, lngB),
        );
        return dA.compareTo(dB);
      });
      final closest = validLocations.take(50).toList();
      _markers = [
        // Red pin for current location
        Marker(
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: Colors.red, size: 36),
        ),
        ...closest.map<Marker?>((item) {
          double lat =
              _parseDouble(item['Location_LatitudeStandardized']) ??
              _parseDouble(item['Location_Latitude'])!;
          double lng =
              _parseDouble(item['Location_LongitudeStandardized']) ??
              _parseDouble(item['Location_Longitude'])!;

          final detectionCondition = item['Result_ResultDetectionCondition']
              ?.toString()
              .toLowerCase();
          final censorTypeA = item['DetectionLimit_TypeA']
              ?.toString()
              .toLowerCase();
          final isCensored =
              detectionCondition == 'not detected' ||
              (censorTypeA == 'censoring level');
          if (isCensored) return null;

          final locationId = item['Location_Identifier']?.toString();
          final allAtLocation = closest
              .where((e) => e['Location_Identifier']?.toString() == locationId)
              .toList();
          // Filter out censored results in the group
          final visibleAtLocation = allAtLocation.where((e) {
            final det = e['Result_ResultDetectionCondition']
                ?.toString()
                .toLowerCase();
            final censor = e['DetectionLimit_TypeA']?.toString().toLowerCase();
            return !(det == 'not detected' || (censor == 'censoring level'));
          }).toList();
          // Build info for all contaminants at this location
          final info = visibleAtLocation
              .map((e) {
                final code = e['USGSpcode']?.toString();
                final contaminant = parameterNames[code] ?? code ?? 'Unknown';
                final amount = e['Result_Measure']?.toString() ?? '';
                final unit = e['Result_MeasureUnit']?.toString() ?? '';
                return 'Contaminant: $contaminant\nAmount: $amount $unit';
              })
              .join('\n\n');

          // Only show one marker per location
          if (allAtLocation.isNotEmpty && item != allAtLocation.first)
            return null;

          return Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: Tooltip(
              message: info,
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
              ),
              textStyle: TextStyle(color: Colors.black, fontSize: 13),
              child: Icon(Icons.location_on, color: Colors.teal, size: 36),
            ),
          );
        }).whereType<Marker>(),
      ];
      loading = false;
    });
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String && value.trim().isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  Widget buildMap() {
    if (_currentPosition == null) {
      return Center(child: CircularProgressIndicator());
    }
    return AdaptiveMap(currentPosition: _currentPosition!, markers: _markers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WaterWise')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed: fetchLocations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Refresh Water Data Nearby'),
            ),
          ),
          if (loading)
            Center(child: CircularProgressIndicator())
          else
            buildMap(),
        ],
      ),
    );
  }
}
