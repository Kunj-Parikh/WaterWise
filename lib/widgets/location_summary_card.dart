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
              width: 18,
              borderRadius: BorderRadius.circular(6),
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
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        locationName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      label: Text(state),
                      backgroundColor: Colors.teal.shade100,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(locationType, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      BarChart(
                        BarChartData(
                          barGroups: barGroups,
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final idx = value.toInt();
                                  if (idx < 0 ||
                                      idx >=
                                          filteredContaminantEntries.length ||
                                      value != idx) {
                                    return const SizedBox.shrink();
                                  }
                                  // Label each bar with the contaminant name, rotated for space
                                  return Transform.rotate(
                                    angle: -0.5, // ~-28 degrees
                                    child: SizedBox(
                                      width: 80,
                                      child: Text(
                                        filteredContaminantEntries[idx].key,
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                                interval: 1,
                                reservedSize: 40,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ), // Hide top index labels
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          barTouchData: BarTouchData(enabled: false),
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Text(
                          'ng/L',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
