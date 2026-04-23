import 'dart:async';

import 'package:BookMyTeacher/presentation/record_section/video_class_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';

import '../../../model/webinar_details_model.dart';
import '../../students/recorded_video_with_doubt.dart';

class WebinarDetailsContent extends StatefulWidget {
  final WebinarDetailsModel course;

  const WebinarDetailsContent({super.key, required this.course});

  @override
  State<WebinarDetailsContent> createState() => _WebinarDetailsContentState();
}

class _WebinarDetailsContentState extends State<WebinarDetailsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<Map<String, Duration>> _countdownNotifier = ValueNotifier(
    {},
  );

  Timer? _ticker;

  Duration countdownThreshold = Duration(hours: 4);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.course.course;
    final classes = widget.course.classes;
    final materials = widget.course.materials;

    return Column(
      children: [
        // Banner
        SizedBox(
          width: double.infinity,
          height: 180,
          child: Image.network(info.thumbnailUrl, fit: BoxFit.cover),
        ),

        Padding(
          padding: const EdgeInsets.all(15),
          child: Text(
            info.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "About"),
            Tab(text: "Classes"),
            Tab(text: "Materials"),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _aboutTab(info),
              _classesTab(classes),
              _materialsTab(materials),
            ],
          ),
        ),
      ],
    );
  }

  // ABOUT TAB
  Widget _aboutTab(WebinarCourseInfo c) {
    final title = c.title ?? 'Untitled Class';
    final desc = c.description ?? '';
    final level = c.level ?? '';
    final duration = c.duration ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),

        // Quick highlights (if available)
        const SizedBox(height: 18),
        Text(
          'About this course',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
        ),
        const SizedBox(height: 8),
        Html(
          data: desc,
          style: {
            "body": Style(
              fontSize: FontSize(14),
              lineHeight: LineHeight(1.4),
              color: Colors.black,
            ),
          },
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statChip(Icons.timer, duration ?? '—'),
            // _statChip(Icons.school, info['certificate'] == true ? 'Certificate' : 'No cert'),
            // _statChip(
            //   Icons.folder,
            //   (info.materials_count ?? materialsCount(info)).toString(),
            // ),
          ],
        ),
      ],
    );
  }

  // CLASSES TAB
  Widget _classesTab(WebinarClassGroups cls) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Inner Tab Bar
          const TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Ongoing & Upcoming"),
              Tab(text: "Completed"),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [

                _buildClassList(cls.ongoing_upcoming),
                _buildClassList(cls.completed),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildClassList(List<ClassItem> items) {
  //   if (items.isEmpty) {
  //     return const Center(child: Text("No classes found"));
  //   }
  //
  //   return ListView.builder(
  //     padding: const EdgeInsets.all(15),
  //     itemCount: items.length,
  //     itemBuilder: (context, i) {
  //       final e = items[i];
  //
  //       return Card(
  //         child: ListTile(
  //           title: Text(e.title),
  //           subtitle: Text("Start:${e.timeStart} \nEnd:${e.timeEnd}"),
  //           trailing: Text(e.classStatus),
  //         ),
  //       );
  //     },
  //   );
  // }
  //////////////////////////////////////////////////////////
  Widget _buildClassList(List<WebinarClassItem> classes) {
    if (classes.isEmpty) {
      return const Center(child: Text("No classes available"));
    }

    return ValueListenableBuilder<Map<String, Duration>>(
      valueListenable: _countdownNotifier,
      builder: (context, countdowns, _) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: classes.length,
          separatorBuilder: (_, __) => const Divider(height: 0.5),
          itemBuilder: (context, i) {
            final c = classes[i];
            final status = (c.classStatus ?? '').toString().toLowerCase();
            final id = c.id.toString();
            final localRemaining = countdowns[id];
            final dtStr = c.timeStart ?? '-';
            final startTime = DateTime.tryParse(c.timeStart ?? '');
            final endTime = DateTime.tryParse(c.timeEnd ?? '');
            final now = DateTime.now();

            bool isUpcoming = startTime != null && now.isBefore(startTime);
            bool isOngoing =
                startTime != null &&
                endTime != null &&
                now.isAfter(startTime) &&
                now.isBefore(endTime);
            bool isCompleted = endTime != null && now.isAfter(endTime);

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: const Icon(
                Icons.video_library,
                size: 34,
                color: Colors.green,
              ),
              title: Text(
                c.title ?? 'Unnamed Class',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (status == 'upcoming' && localRemaining != null)
                  //   Text('Starts in: ${_humanDuration(localRemaining)}'),
                  // if (status != 'upcoming') Text('Date: ${_formatDateTime(c['start_date_time'])}'),
                  // if (status == 'upcoming' && localRemaining != null) ...[
                  //   if (localRemaining <= countdownThreshold)
                  //     Text('Starts in: ${_humanDuration(localRemaining)}')
                  //   else
                  //     Text('Date: ${_formatDateTime(c['start_date_time'])}'),
                  // ] else ...[
                  //   Text('Date: ${_formatDateTime(c['start_date_time'])}'),
                  // ],
                  // if ((c['duration'] ?? '').toString().isNotEmpty) Text('Duration: ${c['duration']}'),
                  /// UPCOMING
                  if (isUpcoming && localRemaining != null) ...[
                    if (localRemaining <= countdownThreshold)
                      Text('Starts in: ${_humanDuration(localRemaining)}')
                    else
                      Text('Date: ${_formatDateTime(c.timeEnd)}'),
                  ]
                  /// ONGOING
                  else if (isOngoing) ...[
                    const Text(
                      'Live now',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                  /// COMPLETED
                  else if (isCompleted) ...[
                    Text(
                      'Completed on: ${_formatDateTime(c.timeEnd)}',
                    ),
                  ]
                  /// FALLBACK
                  else ...[
                    Text('Date: ${_formatDateTime(c.timeStart)}'),
                  ],

                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _onClassAction(c),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                ),
                child: Text(
                  _actionLabelForStatus(status),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Future<void> _onClassAction(WebinarClassItem c) async {
  //   final status = (c.classStatus ?? '').toString().toLowerCase();
  //   final joinLink = c.joinLink?.toString();
  //   final recorded = c.recordedVideo?.toString();
  //   final title = (c.title ?? '').toString();
  //   final source = (c.source ?? '').toString();
  //
  //   if (status == 'ongoing') {
  //     if (joinLink != null && joinLink.isNotEmpty) {
  //       if (source == 'gmeet') {
  //         await _openUrl(joinLink);
  //       } else if (source == 'youtube') {
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (_) => VideoClassScreen(
  //               title: title,
  //               videoUrl: joinLink,
  //               classId: c.id,
  //               type: 'course',
  //             ),
  //           ),
  //         );
  //       } else {
  //         _showSnack("Source link not available");
  //       }
  //     } else {
  //       _showSnack("Join link not available");
  //     }
  //   } else if (status == 'upcoming') {
  //     _showSnack("Class not started yet");
  //   } else if (status == 'completed') {
  //     if (recorded != null && recorded.isNotEmpty) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (_) => VideoClassScreen(
  //             title: title,
  //             videoUrl: recorded,
  //             classId: c.id,
  //             type: 'course',
  //           ),
  //         ),
  //       );
  //     } else {
  //       _showSnack("Recording not available");
  //     }
  //   } else {
  //     _showSnack("Action not available");
  //   }
  // }

  Widget _buildJoinButton(List<dynamic> classes) {
    // show first ongoing class join button (existing behavior preserved)
    final ongoing = classes.cast<Map<String, dynamic>?>().firstWhere(
      (c) => c?['status'] == 'ongoing',
      orElse: () => null,
    );

    if (ongoing == null) return const SizedBox.shrink();

    return SizedBox(height: 10);
    // return Positioned(
    //   bottom: 16,
    //   left: 16,
    //   right: 16,
    //   child: SafeArea(
    //     child: ElevatedButton.icon(
    //       icon: const Icon(Icons.videocam),
    //       label: const Text("Join Ongoing Class"),
    //       style: ElevatedButton.styleFrom(
    //         backgroundColor: Colors.green.shade600,
    //         padding: const EdgeInsets.symmetric(vertical: 14),
    //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    //       ),
    //       onPressed: () => _onClassAction(ongoing),
    //     ),
    //   ),
    // );
  }

  String _actionLabelForStatus(String status) {
    switch (status) {
      case 'ongoing':
        return 'Join';
      case 'completed':
        return 'Watch';
      case 'upcoming':
      default:
        return 'Not Available Now';
    }
  }

  String _formatDateTime(dynamic dt) {
    try {
      final d = DateTime.parse(dt.toString());
      return DateFormat.yMMMEd().add_jm().format(d);
    } catch (_) {
      return dt?.toString() ?? '-';
    }
  }

  //////////////////////////////////////////////////////////
  // MATERIALS TAB
  Widget _materialsTab(List<WebinarMaterialItem> materials) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: materials.length,
      itemBuilder: (context, i) {
        final m = materials[i];
        return Card(
          child: ListTile(
            leading: Icon(
              m.fileType == "pdf" ? Icons.picture_as_pdf : Icons.video_file,
            ),
            title: Text(m.title),
            subtitle: Text(m.fileType.toUpperCase()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // IconButton(
                //   icon: const Icon(Icons.file_open),
                //   onPressed: () => _openMaterial(m),
                // ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: () => _downloadMaterial(m),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  TextStyle get _titleStyle =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  Future<void> _openMaterial(WebinarMaterialItem item) async {
    if (item.fileType == "video") {
      // open video in browser
      await OpenFilex.open(item.fileUrl);
      return;
    }

    if (item.fileType == "pdf") {
      await OpenFilex.open(item.fileUrl);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Unsupported file type: ${item.fileType}")),
    );
  }

  Future<void> _downloadMaterial(WebinarMaterialItem item) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final savePath = "${dir.path}/${item.title}.${item.fileType}";

      await Dio().download(item.fileUrl, savePath);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Downloaded to: $savePath")));

      await OpenFilex.open(savePath);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Download Failed: $e")));
    }
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green.shade700),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showSnack('Error opening url: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _humanDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Future<void> _onClassAction(WebinarClassItem c) async {
    final status = (c.classStatus ?? '').toString().toLowerCase();
    final joinLink = c.joinLink?.toString();
    final recorded = c.recordedVideo?.toString();
    final title = (c.title ?? '').toString();
    final source = (c.source ?? '').toString();

    if (status == 'ongoing') {
      if (joinLink != null && joinLink.isNotEmpty) {
        if (source == 'gmeet') {
          await _openUrl(joinLink);
        } else if (source == 'youtube') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoClassScreen(
                title: title,
                videoUrl: joinLink,
                classId: c.id.toString(),
                type: 'course',
              ),
            ),
          );
        } else {
          _showSnack("Source link not available");
        }
      } else {
        _showSnack("Join link not available");
      }
    } else if (status == 'upcoming') {
      _showSnack("Class not started yet");
    } else if (status == 'completed') {
      if (recorded != null && recorded.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoClassScreen(
              title: title,
              videoUrl: recorded,
              classId: c.id.toString(),
              type: 'course',
            ),
          ),
        );
      } else {
        _showSnack("Recording not available");
      }
    } else {
      _showSnack("Action not available");
    }
  }

}
