import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

class AdaptiveMap extends StatelessWidget {
  final LatLng currentPosition;
  final List<Marker> markers;
  final void Function(LatLng newCenter)? onMapMoved;

  const AdaptiveMap({
    super.key,
    required this.currentPosition,
    required this.markers,
    this.onMapMoved,
  });

  @override
  Widget build(BuildContext context) {
    final mapController = MapController();
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: MapOptions(
            initialCenter: currentPosition,
            initialZoom: 10,

            // tracking the user's position
            onPositionChanged: (MapPosition position, bool hasGesture) {
              if (hasGesture && onMapMoved != null && position.center != null) {
                onMapMoved!(position.center!);
              }
            },
            interactionOptions: const InteractionOptions(
              enableMultiFingerGestureRace: true,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.waterwise',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'zoom_in',
                mini: true,
                backgroundColor: Colors.white,
                child: Icon(Icons.add, color: Colors.teal),
                onPressed: () {
                  mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom + 1,
                  );
                },
              ),
              SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'zoom_out',
                mini: true,
                backgroundColor: Colors.white,
                child: Icon(Icons.remove, color: Colors.teal),
                onPressed: () {
                  mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom - 1,
                  );
                },
              ),
              SizedBox(height: 8),
              FloatingActionButton(
                heroTag: 'fit_bounds',
                mini: true,
                backgroundColor: Colors.white,
                child: Icon(Icons.fit_screen, color: Colors.teal),
                onPressed: () {
                  if (markers.isNotEmpty) {
                    var bounds = LatLngBounds(
                      markers.first.point,
                      markers.first.point,
                    );
                    for (final marker in markers) {
                      bounds.extend(marker.point);
                    }
                    mapController.fitCamera(
                      CameraFit.bounds(
                        bounds: bounds,
                        padding: const EdgeInsets.all(32),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
