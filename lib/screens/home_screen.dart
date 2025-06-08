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
    if (_currentPosition == null) return;
    setState(() => loading = true);
    final data = await WaterDataService.fetchLocations(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
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
            return (det != 'not detected' && censor != 'censoring level');
          }).toList();
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
            child: _CustomTooltip(
              info: info,
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

  // TODO: Kunj's manu bar
  Widget buildMenuBar() {
    return FilterMenuBar();
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
                      onPressed: _getCurrentLocation,
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
          buildMenuBar()
        ],
      ),
    );
  }
}

class _CustomTooltip extends StatefulWidget {
  final String info;
  final Widget child;
  const _CustomTooltip({required this.info, required this.child});

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
