import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_heatmap/flutter_map_heatmap.dart';
import 'dart:math';

class ContaminantHeatmap extends StatelessWidget {
  final List<LatLng> points;
  final List<double> values;
  final Color color;
  final double maxRadius;

  const ContaminantHeatmap({
    required this.points,
    required this.values,
    this.color = Colors.red,
    this.maxRadius = 80,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || values.isEmpty) {
      return const SizedBox.shrink();
    }

    print('widget values: $values');
    final maxValue = values.isNotEmpty
        ? values.reduce((a, b) => a > b ? a : b)
        : 1.0;
    print('max value: $maxValue');
    for (int i = 0; i < points.length && i < values.length; i++) {
      print(
        'Point $i: ${points[i]}, Value: ${values[i]}, Normalized: ${values[i] / (maxValue == 0 ? 1.0 : maxValue)}',
      );
    }
    print('points length: ${points.length}, values length: ${values.length}');

    final customGradient = <double, MaterialColor>{
      0.0: Colors.blue,
      0.2: Colors.blue,
      0.4: Colors.green,
      0.6: Colors.yellow,
      0.8: Colors.orange,
      1.0: Colors.red,
    };

    return Builder(
      builder: (context) {
        return HeatMapLayer(
          heatMapDataSource: InMemoryHeatMapDataSource(
            data: [
              for (int i = 0; i < min(points.length, values.length); i++)
                WeightedLatLng(
                  points[i],
                  600 * (values[i]) / (maxValue == 0 ? 1.0 : maxValue),
                ),
            ],
          ),
          heatMapOptions: HeatMapOptions(
            radius: maxRadius,
            blurFactor: 0.8,
            layerOpacity: 0.65,
            gradient: customGradient,
          ),
        );
      },
    );
  }
}
