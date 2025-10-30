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
    String trend = 'stable';
    IconData trendIcon = Icons.trending_flat;
    if (values.length >= 2) {
      final recent = values.sublist(values.length > 3 ? values.length - 3 : 0);
      final avg = recent.reduce((a, b) => a + b) / recent.length;
      if (latestValue > avg * 1.1) {
        trend = 'up';
        trendIcon = Icons.trending_up;
      } else if (latestValue < avg * 0.9) {
        trend = 'down';
        trendIcon = Icons.trending_down;
      }
    }

    return Card(
      color: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _getContaminantIcon(label),
                    color: color,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: color,
                    ),
                  ),
                ),
                Icon(
                  trendIcon,
                  color: trend == 'up'
                      ? Colors.red
                      : trend == 'down'
                          ? Colors.green
                          : Colors.grey,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
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
                            barWidth: 3,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 3,
                                  color: color,
                                  strokeWidth: 1,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: color.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(show: false),
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(enabled: false),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      latestValue.toStringAsFixed(1),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: color,
                      ),
                    ),
                    Text(
                      'ng/L',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${values.length} measurements from ${_formatDate(dates.first)} to ${_formatDate(dates.last)}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getContaminantIcon(String contaminantName) {
    if (contaminantName.contains('PFOA') || contaminantName.contains('PFOS')) {
      return Icons.science;
    } else if (contaminantName.contains('Lead')) {
      return Icons.dangerous;
    } else if (contaminantName.contains('Nitrate')) {
      return Icons.agriculture;
    } else if (contaminantName.contains('Arsenic')) {
      return Icons.landscape;
    }
    return Icons.water_drop;
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year % 100}';
  }
}

