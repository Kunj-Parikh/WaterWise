import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ComparisonDashboard extends StatefulWidget {
  final Map<String, List<double>>
  contaminantTrends; // contaminant -> list of values
  final List<DateTime> dates;
  final List<Color> colors;
  final List<String> contaminants;
  const ComparisonDashboard({
    required this.contaminantTrends,
    required this.dates,
    required this.colors,
    required this.contaminants,
    super.key,
  });

  @override
  State<ComparisonDashboard> createState() => _ComparisonDashboardState();
}

class _ComparisonDashboardState extends State<ComparisonDashboard> {
  late List<String> selectedContaminants;

  @override
  void initState() {
    super.initState();
    selectedContaminants = widget.contaminants.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contaminant Comparison Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8,
              children: widget.contaminants.map((c) {
                final isSelected = selectedContaminants.contains(c);
                return FilterChip(
                  label: Text(c),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected && selectedContaminants.length < 3) {
                        selectedContaminants.add(c);
                      } else if (!selected) {
                        selectedContaminants.remove(c);
                      }
                    });
                  },
                  backgroundColor: Colors.teal.shade50,
                  selectedColor: Colors.teal,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.teal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        for (int i = 0; i < selectedContaminants.length; i++)
                          LineChartBarData(
                            spots: [
                              for (int j = 0; j < widget.dates.length; j++)
                                FlSpot(
                                  j.toDouble(),
                                  widget.contaminantTrends[selectedContaminants[i]]?[j] ??
                                      0,
                                ),
                            ],
                            isCurved: true,
                            color: widget.colors[i % widget.colors.length],
                            barWidth: 3,
                            dotData: FlDotData(show: false),
                          ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= widget.dates.length) {
                                return Container();
                              }
                              final date = widget.dates[idx];
                              return Text(
                                '${date.month}/${date.day}',
                                style: const TextStyle(fontSize: 12),
                              );
                            },
                            interval: 1,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
