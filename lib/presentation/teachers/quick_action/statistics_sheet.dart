import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsSheet extends StatefulWidget {
  const StatisticsSheet({super.key});

  @override
  State<StatisticsSheet> createState() => _StatisticsSheetState();
}

class _StatisticsSheetState extends State<StatisticsSheet> {
  String selectedRange = "Last 7 Days";

  // Teaching stats (Spend time)
  final Map<String, Map<String, List<double>>> multiLineData = {
    "Last Day": {
      "Individual": [5],
      "Own Courses": [3],
      "YouTube": [7],
      "Workshops": [2],
      "Webinar": [4],
    },
    "Last 7 Days": {
      "Individual": [3, 6, 8, 7, 10, 9, 12],
      "Own Courses": [2, 4, 5, 6, 7, 8, 9],
      "YouTube": [5, 7, 8, 10, 9, 11, 13],
      "Workshops": [1, 3, 2, 4, 3, 5, 4],
      "Webinar": [2, 3, 4, 5, 6, 7, 8],
    },
    "Current Month": {
      "Individual": List.generate(14, (i) => (i + 3) * 1.2),
      "Own Courses": List.generate(14, (i) => (i + 2) * 1.0),
      "YouTube": List.generate(14, (i) => (i + 3) * 1.5),
      "Workshops": List.generate(14, (i) => (i + 1) * 0.9),
      "Webinar": List.generate(14, (i) => (i + 2) * 1.3),
    },
    "Last Month": {
      "Individual": List.generate(30, (i) => (i + 3) * 0.9),
      "Own Courses": List.generate(30, (i) => (i + 2) * 0.8),
      "YouTube": List.generate(30, (i) => (i + 3) * 1.4),
      "Workshops": List.generate(30, (i) => (i + 1) * 0.7),
      "Webinar": List.generate(30, (i) => (i + 2) * 1.0),
    },
  };

  // Watch stats (Students viewing)
  final Map<String, Map<String, List<double>>> watchData = {
    "Last Day": {
      "Individual": [10],
      "Own Courses": [8],
      "YouTube": [15],
      "Workshops": [6],
      "Webinar": [9],
    },
    "Last 7 Days": {
      "Individual": [8, 10, 12, 14, 15, 16, 18],
      "Own Courses": [5, 6, 7, 8, 9, 10, 11],
      "YouTube": [12, 14, 16, 18, 19, 20, 22],
      "Workshops": [3, 4, 5, 6, 6, 7, 8],
      "Webinar": [4, 5, 6, 7, 8, 9, 10],
    },
    "Current Month": {
      "Individual": List.generate(14, (i) => (i + 4) * 1.4),
      "Own Courses": List.generate(14, (i) => (i + 2) * 1.2),
      "YouTube": List.generate(14, (i) => (i + 3) * 1.8),
      "Workshops": List.generate(14, (i) => (i + 1) * 1.0),
      "Webinar": List.generate(14, (i) => (i + 2) * 1.3),
    },
    "Last Month": {
      "Individual": List.generate(30, (i) => (i + 3) * 1.3),
      "Own Courses": List.generate(30, (i) => (i + 2) * 1.1),
      "YouTube": List.generate(30, (i) => (i + 3) * 1.7),
      "Workshops": List.generate(30, (i) => (i + 1) * 0.9),
      "Webinar": List.generate(30, (i) => (i + 2) * 1.2),
    },
  };

  @override
  Widget build(BuildContext context) {
    final dataSet = multiLineData[selectedRange]!;
    final watchSet = watchData[selectedRange]!;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              const Center(
                child: Text(
                  "📊 Teaching Statistics",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),

              /// 🔹 Spend Time
              const Text(
                "🕒 Spend Time (Hours)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildRangeSelector(),
              const SizedBox(height: 15),
              _buildScrollableChart(dataSet),

              const SizedBox(height: 30),

              /// 🔹 Watch Time
              const Text(
                "👀 Students Watch Time",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildScrollableChart(watchSet),

              const SizedBox(height: 30),
              _buildLegend(),
            ],
          ),
        );
      },
    );
  }

  /// 🧭 Range Selector
  Widget _buildRangeSelector() {
    final ranges = ["Last Day", "Last 7 Days", "Current Month", "Last Month"];
    return SizedBox(
      height: 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: ranges.map((range) {
            final bool isSelected = selectedRange == range;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(range),
                selected: isSelected,
                selectedColor: Colors.blueAccent,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                onSelected: (_) => setState(() => selectedRange = range),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 📈 Scrollable Multi Line Chart
  Widget _buildScrollableChart(Map<String, List<double>> dataSet) {
    // Make it scrollable if dataset > 14 points
    final bool isWide = dataSet.values.first.length > 14;
    final double chartWidth = isWide
        ? dataSet.values.first.length * 40.0
        : MediaQuery.of(context).size.width;

    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: chartWidth,
          child: _buildMultiLineChart(dataSet),
        ),
      ),
    );
  }

  /// 📈 Multi Line Chart Core
  Widget _buildMultiLineChart(Map<String, List<double>> dataSet) {
    final colors = {
      "Individual": Colors.blueAccent,
      "Own Courses": Colors.teal,
      "YouTube": Colors.redAccent,
      "Workshops": Colors.orange,
      "Webinar": Colors.purple,
    };
    // Find max Y value for proper top spacing
    final double maxY = dataSet.values
        .expand((e) => e)
        .reduce((a, b) => a > b ? a : b);

    final double minY = dataSet.values
        .expand((e) => e)
        .reduce((a, b) => a < b ? a : b);

    return LineChart(
      LineChartData(
        minY: minY - 1, // add bottom padding
        maxY: maxY + 1, // add top padding
        minX: -0.2, // add left padding
        maxX: dataSet.values.first.length.toDouble() - 0.5, // right padding
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              reservedSize: 30,
              showTitles: true,
              getTitlesWidget: (v, _) =>
                  Text(v.toInt().toString(), style: const TextStyle(fontSize: 10)),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) => Text(
                "${v.toInt() + 1}",
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: dataSet.entries.map((entry) {
          final color = colors[entry.key]!;
          return LineChartBarData(
            isCurved: true,
            spots: List.generate(
              entry.value.length,
                  (i) => FlSpot(i.toDouble(), entry.value[i]),
            ),
            color: color,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [color.withOpacity(0.3), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 🎨 Legend Section
  Widget _buildLegend() {
    final legends = {
      "Individual": Colors.blueAccent,
      "Own Courses": Colors.teal,
      "YouTube": Colors.redAccent,
      "Workshops": Colors.orange,
      "Webinar": Colors.purple,
    };

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: legends.entries.map((entry) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: entry.value,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(entry.key, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}
