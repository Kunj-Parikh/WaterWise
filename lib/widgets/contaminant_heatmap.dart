import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';

class ContaminantHeatmap extends StatelessWidget {
  final List<LatLng> points;
  final List<double> values;
  final Color color;
  final double maxRadius;

  const ContaminantHeatmap({
    required this.points,
    required this.values,
    this.color = Colors.red,
    this.maxRadius = 60,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = values.isNotEmpty
        ? values.reduce((a, b) => a > b ? a : b)
        : 1.0;
    return HeatMapLayer(
      heatMapDataSource: InMemoryHeatMapDataSource(
        data: [
          for (int i = 0; i < points.length && i < values.length; i++)
            WeightedLatLng(
              points[i],
              values[i] /
                  (maxValue == 0
                      ? 1.0
                      : maxValue), // normalize to 0-1, avoid div by zero
            ),
        ],
      ),
      heatMapOptions: HeatMapOptions(
        radius: maxRadius,
        blurFactor: 0.8,
        layerOpacity: 0.7,
        gradient: HeatMapOptions.defaultGradient,
      ),
    );
  }
}
