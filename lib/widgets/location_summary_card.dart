import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LocationSummaryCard extends StatelessWidget {
  final String locationName;
  final String locationType;
  final String state;
  final Map<String, double> contaminantValues; // contaminant name -> value
  final Map<String, Color> contaminantColors;

  const LocationSummaryCard({
    required this.locationName,
    required this.locationType,
    required this.state,
    required this.contaminantValues,
    required this.contaminantColors,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Only include contaminants with value > 0
    final filteredContaminantEntries = contaminantValues.entries
        .where((e) => e.value > 0)
        .toList();
    print('Filtered contaminants: $filteredContaminantEntries');
    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < filteredContaminantEntries.length; i++) {
      final contaminant = filteredContaminantEntries[i].key;
      final value = filteredContaminantEntries[i].value;
      print('Contaminant: $contaminant, Value: $value');
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: contaminantColors[contaminant] ?? Colors.teal,
              width: 20,
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  contaminantColors[contaminant] ?? Colors.teal,
                  (contaminantColors[contaminant] ?? Colors.teal)
                      .withOpacity(0.6),
                ],
              ),
            ),
          ],
          showingTooltipIndicators: [], // Hide tooltip indicators
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          margin: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.grey.shade50],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.teal.shade700,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              locationName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              locationType,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        label: Text(state),
                        backgroundColor: Colors.teal.shade600,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (filteredContaminantEntries.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(Icons.analytics, color: Colors.teal, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Contaminant Levels',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: Stack(
                        children: [
                          BarChart(
                            BarChartData(
                              barGroups: barGroups,
                              borderData: FlBorderData(
                                show: true,
                                border: Border(
                                  left: BorderSide(color: Colors.grey.shade300),
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 5,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.shade200,
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toStringAsFixed(0),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final idx = value.toInt();
                                      if (idx < 0 ||
                                          idx >= filteredContaminantEntries.length ||
                                          value != idx) {
                                        return const SizedBox.shrink();
                                      }
                                      // Label each bar with the contaminant name, rotated for space
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Transform.rotate(
                                          angle: -0.5, // ~-28 degrees
                                          child: SizedBox(
                                            width: 80,
                                            child: Text(
                                              filteredContaminantEntries[idx].key,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    interval: 1,
                                    reservedSize: 45,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    return BarTooltipItem(
                                      '${filteredContaminantEntries[group.x].key}\n${rod.toY.toStringAsFixed(1)} ng/L',
                                      TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ng/L',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.teal.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No contaminant data available',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
