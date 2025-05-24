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
  final List<String> parameterCodes = [
    '54123',
    '54124',
    '54141',
    '54142',
  ]; // TODO: implement this
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
    final geojson = await WaterDataService.fetchLocations(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      radiusMiles: 10,
    );
    // The API returns a FeatureCollection, so extract the features list
    List<dynamic> features = [];
    try {
      if (geojson is Map) {
        final dynamic featuresRaw = geojson['features'];
        if (featuresRaw is List) {
          features = featuresRaw;
        }
      }
    } catch (e) {
      print('Error extracting features: $e');
    }
    setState(() {
      results = features;
      final random = features.length > 50
          ? features.take(50).toList()
          : features;
      _markers = [
        // Red pin for current location
        Marker(
          point: _currentPosition!,
          width: 40,
          height: 40,
          child: Icon(Icons.location_on, color: Colors.red, size: 36),
        ),
        ...random.map<Marker>((item) {
          final geometry = item['geometry'];
          final coords = geometry?['coordinates'];
          final lat = coords != null && coords.length > 1
              ? coords[1]
              : _currentPosition!.latitude;
          final lng = coords != null && coords.length > 0
              ? coords[0]
              : _currentPosition!.longitude;
          final properties = item['properties'] ?? {};

          // All additional vlaues
          final info = properties.entries
              .map((e) => "${e.key}: ${e.value}")
              .join("\n");
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
        }),
      ];
      loading = false;
    });
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
