import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/performance_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class MyPerformancePage extends ConsumerStatefulWidget {
  const MyPerformancePage({super.key});

  @override
  ConsumerState<MyPerformancePage> createState() =>
      _MyPerformancePageState();
}

class _MyPerformancePageState
    extends ConsumerState<MyPerformancePage> {
  String filter = "daily";

  @override
  Widget build(BuildContext context) {
    final performanceAsync = ref.watch(performanceProvider(filter));

    return DraggableScrollableSheet(
      initialChildSize: 0.80,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: ListView(
            controller: controller,
            children: [
              _buildDragHandle(),
              _buildFilterBar(),
              SizedBox(height: 20,),
              performanceAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text("Failed to load")),
                data: (data) {
                  if (data == null) {
                    return const Text("No data");
                  }
                  return Column(
                    children: [
                      _PerformanceCard(
                        icon: Icons.timer_outlined,
                        title: "Total Watch Time",
                        value: data.summary.watchTime,
                      ),
                      _PerformanceCard(
                        icon: Icons.school_outlined,
                        title: "Total Students",
                        value: data.summary.students.toString(),
                      ),
                      _PerformanceCard(
                        icon: Icons.star_border,
                        title: "Average Rating",
                        value: data.summary.avgRating.toString(),
                      ),
                      _PerformanceCard(
                        icon: Icons.bar_chart,
                        title: "Monthly Growth",
                        value: data.summary.growth,
                      ),
                      _PerformanceCard(
                        icon: Icons.people_outline,
                        title: "Total Sessions",
                        value: data.summary.sessions.toString(),
                      ),

                      const SizedBox(height: 20),

                      _ChartSection(
                        labels: data.chart.labels,
                        values: data.chart.values,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() => Center(
    child: Column(
      children: [
        Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        SizedBox(height: 5,),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('My Performance List',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 22),)
            ]
        ),
        SizedBox(height: 20,),
      ],
    ),
  );

  Widget _buildFilterBar() {
    final items = ["daily", "weekly", "monthly"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: items.map((f) {
        final selected = filter == f;
        return GestureDetector(
          onTap: () => setState(() => filter = f),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 18),
            decoration: BoxDecoration(
              color: selected ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              f.toUpperCase(),
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}



class _ChartSection extends StatelessWidget {
  final List<String> labels;
  final List<num> values;

  const _ChartSection({required this.labels, required this.values});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) => Text(labels[v.toInt()]),
              ),
            ),
          ),
          barGroups: values
              .asMap()
              .entries
              .map((e) => BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(toY: e.value.toDouble()),
            ],
          ))
              .toList(),
        ),
      ),
    );
  }
}


class _PerformanceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _PerformanceCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
