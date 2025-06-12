import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ContaminantSparkline extends StatelessWidget {
  final List<double> values;
  final List<DateTime> dates;
  final Color color;
  final String label;
  final double latestValue;

  const ContaminantSparkline({
    required this.values,
    required this.dates,
    required this.color,
    required this.label,
    required this.latestValue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 32,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < values.length; i++)
                          FlSpot(i.toDouble(), values[i]),
                      ],
                      isCurved: true,
                      color: color,
                      barWidth: 2,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$label: ',
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              latestValue.toStringAsFixed(1),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

