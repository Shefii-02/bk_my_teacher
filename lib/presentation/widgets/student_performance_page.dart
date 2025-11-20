import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/student_performance_provider.dart';

class StudentPerformancePage extends ConsumerWidget {
  const StudentPerformancePage({super.key,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(studentPerformanceProvider);
    return Scaffold(

      body: asyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (e, _) => Center(
          child: Text("Error: $e"),
        ),

        data: (performance) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// SUMMARY SECTION
                Row(
                  children: [
                    _summaryCard("Attended", performance.attended, Colors.green),
                    const SizedBox(width: 12),
                    _summaryCard("Missed", performance.missed, Colors.red),
                  ],
                ),
                const SizedBox(height: 12),
                _summaryCard(
                  "Performance",
                  "${performance.performancePercentage.toStringAsFixed(1)}%",
                  Colors.blue,
                  bigText: true,
                ),

                const SizedBox(height: 20),
                const Text(
                  "Monthly Performance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                /// BAR CHART
                SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true, interval: 5),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= performance.monthWise.length) {
                                return const SizedBox();
                              }
                              return Text(
                                performance.monthWise[index].month.substring(0, 3),
                                style: const TextStyle(fontSize: 11),
                              );
                            },
                          ),
                        ),
                      ),
                      barGroups: performance.monthWise.asMap().entries.map((entry) {
                        final index = entry.key;
                        final monthData = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: monthData.attended.toDouble(),
                              width: 16,
                              color: Colors.green,
                            ),
                            BarChartRodData(
                              toY: monthData.missed.toDouble(),
                              width: 16,
                              color: Colors.red,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                /// LIST VIEW
                const Text(
                  "Month-wise Breakdown",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ...performance.monthWise.map((m) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m.month, style: const TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            Text("A: ${m.attended}", style: const TextStyle(color: Colors.green)),
                            const SizedBox(width: 14),
                            Text("M: ${m.missed}", style: const TextStyle(color: Colors.red)),
                          ],
                        )
                      ],
                    ),
                  );
                }),

              ],
            ),
          );
        },
      ),
    );
  }

  /// CARD WIDGET
  Widget _summaryCard(String title, dynamic value, Color color, {bool bigText = false}) {
    return Container(
      width: 160, // << optional, based on your design
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: color)),
          const SizedBox(height: 4),
          Text(
            "$value",
            style: TextStyle(
              fontSize: bigText ? 26 : 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
