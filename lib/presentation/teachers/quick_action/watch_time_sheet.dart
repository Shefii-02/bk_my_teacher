import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../model/statistics_model.dart';
import '../../../services/teacher_api_service.dart';

class WatchTimeSheet extends StatefulWidget {
  const WatchTimeSheet({super.key});

  @override
  State<WatchTimeSheet> createState() => _WatchTimeSheetState();
}

class _WatchTimeSheetState extends State<WatchTimeSheet>
    with SingleTickerProviderStateMixin {
  final GlobalKey repaintKey = GlobalKey();
  late TabController _tabController;
  String selectedRange = "Last 7 Days";
  String totalWatch = "0";

  bool loading = true;
  StatisticsModel? stats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadStatistics();
  }

  // API Converted Data
  Map<String, Map<String, List<double>>> watchMap = {};

  Future<void> loadStatistics() async {
    try {
      stats = await TeacherApiService().fetchStatistics();
      if (stats != null) {
        watchMap = {
          "Last 2 Days": {
            "Individual": stats!.watch["Last 2 Days"]!.individual ?? [],
            "Own Courses": stats!.watch["Last 2 Days"]!.ownCourses ?? [],
            "YouTube": stats!.watch["Last 2 Days"]!.youtube ?? [],
            "Workshops": stats!.watch["Last 2 Days"]!.workshops ?? [],
            "Webinar": stats!.watch["Last 2 Days"]!.webinar ?? [],
          },
          "Last 7 Days": {
            "Individual": stats!.watch["Last 7 Days"]!.individual ?? [],
            "Own Courses": stats!.watch["Last 7 Days"]!.ownCourses ?? [],
            "YouTube": stats!.watch["Last 7 Days"]!.youtube ?? [],
            "Workshops": stats!.watch["Last 7 Days"]!.workshops ?? [],
            "Webinar": stats!.watch["Last 7 Days"]!.webinar ?? [],
          },
          "Current Month": {
            "Individual": stats!.watch["Current Month"]!.individual ?? [],
            "Own Courses": stats!.watch["Current Month"]!.ownCourses ?? [],
            "YouTube": stats!.watch["Current Month"]!.youtube ?? [],
            "Workshops": stats!.watch["Current Month"]!.workshops ?? [],
            "Webinar": stats!.watch["Current Month"]!.webinar ?? [],
          },
          "Last Month": {
            "Individual": stats!.watch["Last Month"]!.individual ?? [],
            "Own Courses": stats!.watch["Last Month"]!.ownCourses ?? [],
            "YouTube": stats!.watch["Last Month"]!.youtube ?? [],
            "Workshops": stats!.watch["Last Month"]!.workshops ?? [],
            "Webinar": stats!.watch["Last Month"]!.webinar ?? [],
          },
        };
      }

      totalWatch = stats!.totalWatch;

      setState(() => loading = false);
    } catch (e) {
      debugPrint("Error fetching statistics → $e");
      setState(() => loading = false);
    }
  }

  /// 🧩 Capture screenshot for sharing
  Future<void> _captureAndShare() async {
    try {
      RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/teaching_stats.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: "📊 Teaching Statistics Report");
    } catch (e) {
      debugPrint("Error sharing screenshot: $e");
    }
  }

  Future<void> _downloadPDF() async {
    try {
      RenderRepaintBoundary boundary =
      repaintKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final pdf = pw.Document();
      final imageWidget = pw.MemoryImage(pngBytes);
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) =>
              pw.Center(child: pw.Image(imageWidget, fit: pw.BoxFit.contain)),
        ),
      );

      Directory? baseDir;

      if (Platform.isAndroid) {
        // ✅ Use public Downloads directory
        baseDir = Directory("/storage/emulated/0/Download/Teaching_Reports");
      } else {
        // Fallback for iOS / desktop
        baseDir = await getApplicationDocumentsDirectory();
        baseDir = Directory("${baseDir.path}/Teaching_Reports");
      }

      if (!(await baseDir.exists())) {
        await baseDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File("${baseDir.path}/teaching_statistics_$timestamp.pdf");

      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ PDF saved to: ${file.path}"),
          duration: const Duration(seconds: 4),
        ),
      );

      debugPrint("PDF saved at: ${file.path}");
    } catch (e) {
      debugPrint("Error generating PDF: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to generate PDF")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading ||

        watchMap.isEmpty ||
        watchMap[selectedRange] == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final dataSetWatch = watchMap[selectedRange]!;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7, // Start smaller
      minChildSize: 0.5, // Minimum collapsed size
      maxChildSize: 0.9, // Maximum expanded size
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color:
            Colors.white, // ALWAYS add color for shadows to render cleanly
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, -2),
                blurRadius: 12,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "📊 Watch Statistics",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.redAccent,
                          ),
                          onPressed: _downloadPDF,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.blueAccent,
                          ),
                          onPressed: _captureAndShare,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () =>
                              Navigator.pop(context), // closes the bottom sheet
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _buildSpendWatchCards(),
              SizedBox(height: 15),
              _buildRangeSelector(),
              SizedBox(height: 15),

              // ✅ Fixed Tab UI
              TabBar(
                controller: _tabController,
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blueAccent,
                tabs: const [
                  Tab(icon: Icon(Icons.show_chart), text: "Line Chart"),
                  Tab(icon: Icon(Icons.bar_chart), text: "Bar Chart"),
                ],
              ),

              // ✅ Full chart captured
              RepaintBoundary(
                key: repaintKey,
                child: SizedBox(
                  height: 450,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildScrollableCharts(
                        dataSetWatch,
                        chartType: 'line',
                      ),
                      _buildScrollableCharts(
                        dataSetWatch,
                        chartType: 'bar',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLegend(),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSpendWatchCards() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _infoCard("👁 Watch Time", totalWatch, Colors.teal),
      ],
    ),
  );

  Widget _infoCard(String title, String value, Color color) => Expanded(
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildRangeSelector() {
    final ranges = ["Last 2 Days", "Last 7 Days", "Current Month", "Last Month"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: ranges.map((range) {
          final selected = selectedRange == range;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(range),
              selected: selected,
              selectedColor: Colors.blueAccent,
              backgroundColor: Colors.grey.shade200,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              onSelected: (_) => setState(() => selectedRange = range),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScrollableCharts(
      Map<String, List<double>> watchDataSet, {
        required String chartType,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // --- Watch Time Chart ---
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "👁 Watch Time",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: (watchDataSet.values.first.length * 50).toDouble().clamp(
              400,
              double.infinity,
            ),
            height: 320,
            child: chartType == 'line'
                ? _buildMultiLineChart(watchDataSet)
                : _buildBarChart(watchDataSet),
          ),
        ),
      ],
    );
  }

  // --- MultiLine Chart Function ---
  Widget _buildMultiLineChart(Map<String, List<double>> dataSet) {
    final colors = {
      "Individual": Colors.blueAccent,
      "Own Courses": Colors.teal,
      "YouTube": Colors.redAccent,
      "Workshops": Colors.orange,
      "Webinar": Colors.purple,
    };

    final maxY =
        dataSet.values.expand((e) => e).reduce((a, b) => a > b ? a : b) + 1;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
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
                colors: [color.withOpacity(0.25), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          );
        }).toList(),
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 2,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1),
          ),
        ),
      ),
    );
  }

  // --- Bar Chart Function ---
  Widget _buildBarChart(Map<String, List<double>> dataSet) {
    final colors = {
      "Individual": Colors.blueAccent,
      "Own Courses": Colors.teal,
      "YouTube": Colors.redAccent,
      "Workshops": Colors.orange,
      "Webinar": Colors.purple,
    };

    final barGroups = <BarChartGroupData>[];
    for (int i = 0; i < dataSet.values.first.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: dataSet.entries
              .map(
                (entry) => BarChartRodData(
              toY: entry.value[i],
              color: colors[entry.key],
              width: 6,
            ),
          )
              .toList(),
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        titlesData: const FlTitlesData(
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 2,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 1),
          ),
        ),
      ),
    );
  }

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
      spacing: 12,
      runSpacing: 8,
      children: legends.entries
          .map(
            (e) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: e.value,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Text(e.key, style: const TextStyle(fontSize: 12)),
          ],
        ),
      )
          .toList(),
    );
  }

/// 🧾 Generate PDF and save to Android Download directory
// Future<void> _downloadPDF() async {
//   try {
//     // ✅ Request permission (Android 10+)
//     if (await Permission.manageExternalStorage.request().isDenied) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("❌ Storage permission denied")),
//       );
//       return;
//     }
//
//     // ✅ Capture the full widget image
//     RenderRepaintBoundary boundary =
//     repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData =
//     await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();
//
//     final pdf = pw.Document();
//     final imageWidget = pw.MemoryImage(pngBytes);
//
//     final now = DateTime.now();
//     final formattedDate =
//         "${now.day}-${now.month}-${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}";
//
//     pdf.addPage(
//       pw.Page(
//         margin: const pw.EdgeInsets.all(24),
//         build: (pw.Context context) => pw.Column(
//           crossAxisAlignment: pw.CrossAxisAlignment.center,
//           children: [
//             pw.Text("📊 Teaching Statistics Report",
//                 style: pw.TextStyle(
//                     fontSize: 20, fontWeight: pw.FontWeight.bold)),
//             pw.SizedBox(height: 8),
//             pw.Text("Date Range: $selectedRange",
//                 style: const pw.TextStyle(fontSize: 14)),
//             pw.Text("Generated on: $formattedDate",
//                 style:
//                 const pw.TextStyle(fontSize: 12, color: PdfColors.grey)),
//             pw.Divider(),
//             pw.SizedBox(height: 10),
//             pw.Image(imageWidget, fit: pw.BoxFit.contain, width: 450),
//           ],
//         ),
//       ),
//     );
//
//     /// ✅ Save to Android Download folder
//     Directory downloadsDir = Directory('/storage/emulated/0/Download');
//     Directory targetDir =
//     Directory("${downloadsDir.path}/Teaching_Reports");
//
//     if (!await targetDir.exists()) {
//       await targetDir.create(recursive: true);
//     }
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final file =
//     File("${targetDir.path}/teaching_statistics_$timestamp.pdf");
//     await file.writeAsBytes(await pdf.save());
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text("✅ PDF saved to Downloads/Teaching_Reports"),
//         duration: Duration(seconds: 4),
//       ),
//     );
//
//     debugPrint("PDF saved at: ${file.path}");
//   } catch (e) {
//     debugPrint("Error generating PDF: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("❌ Failed to generate PDF")),
//     );
//   }
// }
// Future<void> _downloadPDF() async {
//   try {
//     RenderRepaintBoundary boundary =
//     repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//     ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     Uint8List pngBytes = byteData!.buffer.asUint8List();
//
//     final pdf = pw.Document();
//     final imageWidget = pw.MemoryImage(pngBytes);
//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) =>
//             pw.Center(child: pw.Image(imageWidget, fit: pw.BoxFit.contain)),
//       ),
//     );
//
//     Directory? baseDir;
//
//     if (Platform.isAndroid) {
//       // ✅ Use public Downloads directory
//       baseDir = Directory("/storage/emulated/0/Download/Teaching_Reports");
//     } else {
//       // Fallback for iOS / desktop
//       baseDir = await getApplicationDocumentsDirectory();
//       baseDir = Directory("${baseDir.path}/Teaching_Reports");
//     }
//
//     if (!(await baseDir.exists())) {
//       await baseDir.create(recursive: true);
//     }
//
//     final timestamp = DateTime.now().millisecondsSinceEpoch;
//     final file = File("${baseDir.path}/teaching_statistics_$timestamp.pdf");
//
//     await file.writeAsBytes(await pdf.save());
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text("✅ PDF saved to: ${file.path}"),
//         duration: const Duration(seconds: 4),
//       ),
//     );
//
//     debugPrint("PDF saved at: ${file.path}");
//   } catch (e) {
//     debugPrint("Error generating PDF: $e");
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text("❌ Failed to generate PDF")),
//     );
//   }
// }
}
