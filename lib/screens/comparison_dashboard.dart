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
      appBar: AppBar(
        title: const Text('Contaminant Comparison Dashboard'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.filter_list, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Select Contaminants (up to 3)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
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
                            backgroundColor: Colors.grey.shade100,
                            selectedColor: Colors.teal,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey.shade800,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            elevation: isSelected ? 4 : 0,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Legend
              if (selectedContaminants.isNotEmpty)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < selectedContaminants.length; i++)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: widget.colors[i % widget.colors.length],
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                selectedContaminants[i],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: selectedContaminants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  size: 80,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Select contaminants to compare',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Historical Trends',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Contaminant levels over time (ng/L)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: LineChart(
                                  LineChartData(
                                    lineBarsData: [
                                      for (int i = 0; i < selectedContaminants.length; i++)
                                        LineChartBarData(
                                          spots: [
                                            for (int j = 0; j < widget.dates.length; j++)
                                              FlSpot(
                                                j.toDouble(),
                                                widget.contaminantTrends[
                                                            selectedContaminants[i]]
                                                        ?[j] ??
                                                    0,
                                              ),
                                          ],
                                          isCurved: true,
                                          color: widget.colors[i % widget.colors.length],
                                          barWidth: 4,
                                          dotData: FlDotData(
                                            show: true,
                                            getDotPainter: (spot, percent, barData, index) {
                                              return FlDotCirclePainter(
                                                radius: 4,
                                                color: barData.color!,
                                                strokeWidth: 2,
                                                strokeColor: Colors.white,
                                              );
                                            },
                                          ),
                                          belowBarData: BarAreaData(
                                            show: true,
                                            color: widget.colors[i % widget.colors.length]
                                                .withOpacity(0.1),
                                          ),
                                        ),
                                    ],
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 45,
                                          getTitlesWidget: (value, meta) {
                                            return Text(
                                              value.toStringAsFixed(0),
                                              style: TextStyle(fontSize: 12),
                                            );
                                          },
                                        ),
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
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                '${date.month}/${date.day}',
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                            );
                                          },
                                          interval: 1,
                                          reservedSize: 30,
                                        ),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
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
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipItems: (touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            return LineTooltipItem(
                                              '${selectedContaminants[spot.barIndex]}\n${spot.y.toStringAsFixed(1)} ng/L',
                                              TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

