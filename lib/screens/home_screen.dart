import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/water_data_service.dart';
import 'adaptive_map.dart';
import '../widgets/menu_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import '../widgets/contaminant_sparkline.dart';
import '../widgets/location_summary_card.dart';
import '../widgets/alert_badge.dart';
import '../widgets/contaminant_heatmap.dart';
import 'comparison_dashboard.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

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
  LatLng? _newPosition;

  List<Marker> _markers = [];
  List<dynamic> results = [];
  Map<String, dynamic>? _selectedLocation;
  bool _showSidebar = false;
  bool _showHeatmap = false;

  // ignore: unused_field, prefer_final_fields
  String _searchQuery = '';

  // ignore: unused_field, prefer_final_fields
  List<String> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();

  // ignore: unused_field, prefer_final_fields
  bool _searching = false;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final target = _newPosition ?? _currentPosition;

    if (target == null) return;

    setState(() => loading = true);

    final data = await WaterDataService.fetchLocations(
      target.latitude,
      target.longitude,
      radiusMiles: 10,
      parameterCodes: parameterNames.keys.toList(),
    );
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
          Color getMarkerColor(double value) {
            if (value < 1) return Colors.green;
            if (value < 10) return Colors.orange;
            return Colors.red;
          }

          double lat = _parseDouble(item['Location_Latitude'])!;
          double lng = _parseDouble(item['Location_Longitude'])!;

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
            return (det != 'not detected' && censor != 'censoring level');
          }).toList();

          final firstVisible = visibleAtLocation.isNotEmpty
              ? visibleAtLocation.first
              : null;
          final amount =
              double.tryParse(
                firstVisible?['Result_Measure']?.toString() ?? '',
              ) ??
              0;

          final locationName = item['Location_Name']?.toString() ?? '';

          final info = [
            if (locationName.isNotEmpty)
              // Use a special marker for bold, then parse in Tooltip child
              '[BOLD]Location: $locationName[/BOLD]',
            ...visibleAtLocation.take(3).map((e) {
              final code = e['USGSpcode']?.toString();
              final contaminant = parameterNames[code] ?? code ?? 'Unknown';
              final amount = e['Result_Measure']?.toString() ?? '';
              final unit = e['Result_MeasureUnit']?.toString() ?? '';
              final date = e['Activity_StartDate']?.toString();
              String dateInfo = '';
              if (date != null && date.isNotEmpty) {
                dateInfo += 'Date: $date';
              }
              return 'Contaminant: $contaminant\nAmount: $amount $unit${dateInfo.isNotEmpty ? '\n$dateInfo' : ''}';
            }),
          ].join('\n\n');

          // Only show one marker per location
          if (allAtLocation.isNotEmpty && item != allAtLocation.first) {
            return null;
          }

          return Marker(
            point: LatLng(lat, lng),
            width: 40,
            height: 40,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                child: _CustomTooltip(
                  info: info,
                  onTap: () {
                    print(
                      'Marker tapped: ${item['Location_Name']?.toString() ?? ''}',
                    );
                    setState(() {
                      _selectedLocation = item;
                      _showSidebar = true;
                    });
                  },
                  child: Icon(
                    Icons.location_on,
                    color: getMarkerColor(amount),
                    size: 36,
                  ),
                ),
              ),
            ),
          );
        }).whereType<Marker>(),
      ];
      loading = false;
    });
  }

  void _updateMapCenter(LatLng center) {
    setState(() {
      _newPosition = center;
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
    // Use kIsWeb to avoid Platform on web
    final isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
    if (isDesktop) {
      return Row(
        children: [
          Expanded(
            flex: _showSidebar && _selectedLocation != null
                ? 3
                : 2, // decrease map width when sidebar is open
            child: Stack(
              children: [
                AdaptiveMap(
                  currentPosition: _newPosition ?? _currentPosition!,
                  markers: _markers,
                  onMapMoved: _updateMapCenter,
                ),
                // Floating action button for dashboard
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'dashboard',
                    backgroundColor: Colors.teal,
                    icon: Icon(Icons.dashboard),
                    label: Text('Compare'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ComparisonDashboard(
                            contaminantTrends: _buildTrends(),
                            dates: _buildDates(),
                            colors: [
                              Colors.teal,
                              Colors.orange,
                              Colors.red,
                              Colors.blue,
                            ],
                            contaminants: parameterNames.values
                                .toSet()
                                .toList(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 80,
                  right: 16,
                  child: FloatingActionButton.extended(
                    heroTag: 'heatmap',
                    backgroundColor: Colors.deepOrange,
                    icon: Icon(Icons.thermostat),
                    label: Text('Heatmap'),
                    onPressed: () {
                      setState(() {
                        _showSidebar = false;
                        _selectedLocation = null;
                        _showHeatmap = !_showHeatmap;
                      });
                    },
                  ),
                ),
                if (_showHeatmap)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ContaminantHeatmap(
                        points: _buildHeatmapPoints(),
                        values: _buildHeatmapValues(),
                        color: Colors.deepOrange,
                        maxRadius: 60,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_showSidebar && _selectedLocation != null)
            Container(
              width: 480, // wider sidebar
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showSidebar = false;
                        });
                      },
                    ),
                    LocationSummaryCard(
                      locationName: _selectedLocation?['Location_Name'] ?? '',
                      locationType:
                          _selectedLocation?['MonitoringLocationTypeName'] ??
                          '',
                      state: _selectedLocation?['StateCode'] ?? '',
                      contaminantValues: _buildContaminantValues(
                        _selectedLocation,
                      ),
                      contaminantColors: _contaminantColors(),
                    ),
                    if (_buildSparklines(_selectedLocation).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: _buildSparklines(_selectedLocation)
                                .map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: w,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    if (_hasAlert(_selectedLocation))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AlertBadge(
                          show: true,
                          label: 'High Contaminant!',
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      );
    }
    // Mobile/web: overlay sidebar
    return Stack(
      children: [
        AdaptiveMap(
          currentPosition: _newPosition ?? _currentPosition!,
          markers: _markers,
          onMapMoved: _updateMapCenter,
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'dashboard',
            backgroundColor: Colors.teal,
            icon: Icon(Icons.dashboard),
            label: Text('Compare'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ComparisonDashboard(
                    contaminantTrends: _buildTrends(),
                    dates: _buildDates(),
                    colors: [
                      Colors.teal,
                      Colors.orange,
                      Colors.red,
                      Colors.blue,
                    ],
                    contaminants: parameterNames.values.toSet().toList(),
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 80,
          right: 16,
          child: FloatingActionButton.extended(
            heroTag: 'heatmap',
            backgroundColor: Colors.deepOrange,
            icon: Icon(Icons.thermostat),
            label: Text('Heatmap'),
            onPressed: () {
              setState(() {
                _showSidebar = false;
                _selectedLocation = null;
                _showHeatmap = !_showHeatmap;
              });
            },
          ),
        ),
        if (_showSidebar && _selectedLocation != null)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: 350,
              color: Colors.white,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showSidebar = false;
                        });
                      },
                    ),
                    LocationSummaryCard(
                      locationName: _selectedLocation?['Location_Name'] ?? '',
                      locationType:
                          _selectedLocation?['MonitoringLocationTypeName'] ??
                          '',
                      state: _selectedLocation?['StateCode'] ?? '',
                      contaminantValues: _buildContaminantValues(
                        _selectedLocation,
                      ),
                      contaminantColors: _contaminantColors(),
                    ),
                    if (_buildSparklines(_selectedLocation).isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: _buildSparklines(_selectedLocation)
                                .map(
                                  (w) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: w,
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    if (_hasAlert(_selectedLocation))
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: AlertBadge(
                          show: true,
                          label: 'High Contaminant!',
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        if (_showHeatmap)
          Positioned.fill(
            child: IgnorePointer(
              child: ContaminantHeatmap(
                points: _buildHeatmapPoints(),
                values: _buildHeatmapValues(),
                color: Colors.deepOrange,
                maxRadius: 60,
              ),
            ),
          ),
      ],
    );
  }

  // TODO: Kunj's manu bar
  Widget buildMenuBar() {
    return DropDown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WaterWise')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      // Map<String, dynamic> is JSON format
                      child: TypeAheadField<Map<String, dynamic>>(
                        builder: (context, controller, focusNode) => TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Search city, state, country, zip, etc.',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        // callback every time user types
                        suggestionsCallback: (pattern) async {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          final completer =
                              Completer<List<Map<String, dynamic>>>();
                          _debounce = Timer(
                            const Duration(milliseconds: 500),
                            () async {
                              if (pattern.trim().isEmpty) {
                                completer.complete([]);
                                return;
                              }
                              print('Callback');
                              final url = Uri.parse(
                                'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(pattern)}&countrycodes=us&limit=10',
                              );
                              print('Fetching suggestions from: $url');
                              final response = await http.get(url);
                              if (response.statusCode == 200) {
                                print('Received response 200');
                                final List data = jsonDecode(response.body);
                                completer.complete(
                                  data.cast<Map<String, dynamic>>(),
                                );
                                return;
                              }
                              completer.complete([]);
                            },
                          );
                          return completer.future;
                        },
                        itemBuilder: (context, suggestion) {
                          final display = suggestion['display_name'] ?? '';
                          return ListTile(title: Text(display));
                        },
                        onSelected: (suggestion) {
                          _searchController.text =
                              suggestion['display_name'] ?? '';
                          final lat = double.tryParse(suggestion['lat'] ?? '');
                          final lon = double.tryParse(suggestion['lon'] ?? '');
                          if (lat != null && lon != null) {
                            setState(() {
                              _currentPosition = LatLng(lat, lon);
                            });
                            fetchLocations();
                          }
                        },
                        emptyBuilder: (context) {
                          if (_searchController.text.trim().isEmpty) {
                            return SizedBox.shrink();
                          }
                          return const ListTile(title: Text('No items found!'));
                        },
                      ),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: fetchLocations,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.my_location),
                          SizedBox(width: 4),
                          Text('My Location'),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                ElevatedButton(
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
                Row(children: [Text('View specific contamination amounts: '), buildMenuBar()]),
              ],
            ),
          ),
          if (loading)
            Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: Stack(
                children: [
                  buildMap(),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FloatingActionButton(
                      heroTag: 'my_location',
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      onPressed: _getCurrentLocation,
                      child: Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),
          // buildMenuBar(),
        ],
      ),
    );
  }

  // Helper methods for dashboard, sparklines, heatmap, etc.
  Map<String, List<double>> _buildTrends() {
    // Example: build time series for each contaminant (mocked for now)
    final Map<String, List<double>> trends = {};
    for (var code in parameterNames.keys) {
      trends[parameterNames[code] ?? code] = List.generate(
        10,
        (i) => (i + 1) * 2.0,
      );
    }
    return trends;
  }

  List<DateTime> _buildDates() {
    // Example: 10 days
    return List.generate(
      10,
      (i) => DateTime.now().subtract(Duration(days: 10 - i)),
    );
  }

  Map<String, double> _buildContaminantValues(Map<String, dynamic>? location) {
    if (location == null) return {};
    // Find all contaminant results for this location (by Location_Identifier)
    final locationId = location['Location_Identifier']?.toString();
    final allResults = results
        .where(
          (item) =>
              item['Location_Identifier']?.toString() == locationId &&
              item['Result_Measure'] != null &&
              item['USGSpcode'] != null,
        )
        .toList();
    // For each contaminant, get the most recent value
    final Map<String, double> values = {};
    final Map<String, List<Map<String, dynamic>>> byContaminant = {};
    for (final item in allResults) {
      final code = item['USGSpcode']?.toString();
      if (code == null) continue;
      byContaminant.putIfAbsent(code, () => []).add(item);
    }
    byContaminant.forEach((code, group) {
      // Sort by date descending
      group.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['Activity_StartDate'] ?? '') ?? DateTime(1970);
        final bDate =
            DateTime.tryParse(b['Activity_StartDate'] ?? '') ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });
      final name = parameterNames[code] ?? code;
      final value = double.tryParse(
        group.first['Result_Measure']?.toString() ?? '',
      );
      if (value != null) values[name] = value;
    });
    return values;
  }

  Map<String, Color> _contaminantColors() {
    return {
      'PFOS': Colors.teal,
      'PFOA': Colors.orange,
      'Lead': Colors.red,
      'Nitrogen': Colors.blue,
      'Phosphorus': Colors.green,
    };
  }

  List<Widget> _buildSparklines(Map<String, dynamic>? location) {
    if (location == null) return [];
    // Find all contaminant results for this location (by Location_Identifier)
    final locationId = location['Location_Identifier']?.toString();
    final allResults = results
        .where(
          (item) =>
              item['Location_Identifier']?.toString() == locationId &&
              item['Result_Measure'] != null &&
              item['USGSpcode'] != null,
        )
        .toList();
    // Group by contaminant code
    final Map<String, List<Map<String, dynamic>>> byContaminant = {};
    for (final item in allResults) {
      final code = item['USGSpcode']?.toString();
      if (code == null) continue;
      byContaminant.putIfAbsent(code, () => []).add(item);
    }
    final List<Widget> sparklines = [];
    for (final code in byContaminant.keys) {
      final name = parameterNames[code] ?? code;
      final group = byContaminant[code]!;
      // Sort by date
      group.sort((a, b) {
        final aDate =
            DateTime.tryParse(a['Activity_StartDate'] ?? '') ?? DateTime(1970);
        final bDate =
            DateTime.tryParse(b['Activity_StartDate'] ?? '') ?? DateTime(1970);
        return aDate.compareTo(bDate);
      });
      final values = group
          .map(
            (e) =>
                double.tryParse(e['Result_Measure']?.toString() ?? '') ?? 0.0,
          )
          .toList();
      final dates = group
          .map(
            (e) =>
                DateTime.tryParse(e['Activity_StartDate'] ?? '') ??
                DateTime(1970),
          )
          .toList();
      if (values.isEmpty) continue;
      sparklines.add(
        ContaminantSparkline(
          values: values,
          dates: dates,
          color: _contaminantColors()[name] ?? Colors.teal,
          label: name,
          latestValue: values.last,
        ),
      );
    }
    if (sparklines.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('No contaminant data available for this location.'),
        ),
      ];
    }
    return sparklines;
  }

  bool _hasAlert(Map<String, dynamic>? location) {
    if (location == null) return false;
    // Example: alert if any value > 10
    for (var code in parameterNames.keys) {
      final val = double.tryParse(location[code]?.toString() ?? '');
      if (val != null && val > 10) return true;
    }
    return false;
  }

  List<LatLng> _buildHeatmapPoints() {
    // Build a list of (LatLng, value) pairs where both are valid
    final pairs = results
        .map((item) {
          final lat = _parseDouble(item['Location_Latitude']);
          final lng = _parseDouble(item['Location_Longitude']);
          final val = double.tryParse(item['Result_Measure']?.toString() ?? '');
          if (lat != null && lng != null && val != null) {
            return {'point': LatLng(lat, lng), 'value': val};
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    return pairs.map((e) => e['point'] as LatLng).toList();
  }

  List<double> _buildHeatmapValues() {
    // Ensure values list matches points list length
    final pairs = results
        .map((item) {
          final lat = _parseDouble(item['Location_Latitude']);
          final lng = _parseDouble(item['Location_Longitude']);
          final val = double.tryParse(item['Result_Measure']?.toString() ?? '');
          if (lat != null && lng != null && val != null) {
            return {'point': LatLng(lat, lng), 'value': val};
          }
          return null;
        })
        .whereType<Map<String, dynamic>>()
        .toList();
    return pairs.map((e) => e['value'] as double).toList();
  }
}

class _CustomTooltip extends StatefulWidget {
  final String info;
  final Widget child;
  final VoidCallback? onTap;
  const _CustomTooltip({required this.info, required this.child, this.onTap});

  @override
  State<_CustomTooltip> createState() => _CustomTooltipState();
}

class _CustomTooltipState extends State<_CustomTooltip> {
  OverlayEntry? _overlayEntry;
  bool _isHovering = false;
  bool _overlayVisible = false;

  void _showOverlay(BuildContext context, Offset position) {
    if (_overlayVisible) return;
    _overlayVisible = true;
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx + 50,
        top: position.dy - 12,
        child: MouseRegion(
          onEnter: (_) {
            _isHovering = true;
          },
          onExit: (_) {
            _isHovering = false;
            _removeOverlay();
          },
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: _buildRichContent(),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    if (!_overlayVisible) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    _overlayVisible = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        _isHovering = true;
        final renderBox = context.findRenderObject() as RenderBox;
        final offset = renderBox.localToGlobal(Offset.zero);
        _showOverlay(context, offset);
      },
      onExit: (event) {
        _isHovering = false;
        // Delay removal to allow entering overlay
        Future.delayed(Duration(milliseconds: 100), () {
          if (!_isHovering) _removeOverlay();
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          if (widget.onTap != null) {
            widget.onTap!();
          } else {
            showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  content: _buildRichContent(),
                  contentPadding: EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            );
          }
        },
        child: widget.child,
      ),
    );
  }

  Widget _buildRichContent() {
    final lines = widget.info.split('\n\n');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('[BOLD]') && line.endsWith('[/BOLD]')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              line.replaceAll('[BOLD]', '').replaceAll('[/BOLD]', ''),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(line, style: TextStyle(fontSize: 13)),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
