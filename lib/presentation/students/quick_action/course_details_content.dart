import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
// import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../model/course_details_model.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../services/teacher_api_service.dart';
import '../../record_section/video_class_screen.dart';
import '../../students/recorded_video_with_doubt.dart';
import '../../teachers/quick_action/course_details_content.dart';

class StudentCourseDetailsContent extends StatefulWidget {
  final CourseDetails course;

  const StudentCourseDetailsContent({super.key, required this.course});

  @override
  State<StudentCourseDetailsContent> createState() => _StudentCourseDetailsContentState();
}

class _StudentCourseDetailsContentState extends State<StudentCourseDetailsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<ClassItem> _ongoing;
  late List<ClassItem> _completed;
  late List<MaterialItem> _materials;

  final ValueNotifier<Map<String, Duration>> _countdownNotifier = ValueNotifier(
    {},
  );

  Timer? _ticker;

  Duration countdownThreshold = Duration(hours: 4);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ongoing = List.from(widget.course.classes.ongoing_upcoming);
    _completed = List.from(widget.course.classes.completed);
    _materials = List.from(widget.course.materials);
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
              _AboutTab(info: info),
              // _classesTab(classes),
              // _materialsTab(materials),
              _ClassesTab(
                ongoing: _ongoing,
                completed: _completed,
              ),
              _MaterialsTab(
                materials: _materials,
                onDownload: _downloadMaterial,

              ),
            ],
          ),
        ),
      ],
    );
  }

  // ABOUT TAB
  // Widget _aboutTab(CourseInfo c) {
  //   final title = c.title ?? 'Untitled Class';
  //   final desc = c.description ?? '';
  //   final level = c.level ?? '';
  //   final duration = c.duration ?? '';
  //
  //   return ListView(
  //     padding: const EdgeInsets.all(16),
  //     children: [
  //       const SizedBox(height: 16),
  //
  //       // Quick highlights (if available)
  //       const SizedBox(height: 18),
  //       Text(
  //         'About this course',
  //         style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
  //       ),
  //       const SizedBox(height: 8),
  //       Html(
  //         data: desc,
  //         style: {
  //           "body": Style(
  //             fontSize: FontSize(14),
  //             lineHeight: LineHeight(1.4),
  //             color: Colors.black,
  //           ),
  //         },
  //       ),
  //       const SizedBox(height: 20),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           _statChip(Icons.timer, duration ?? '—'),
  //           // _statChip(Icons.school, info['certificate'] == true ? 'Certificate' : 'No cert'),
  //           // _statChip(
  //           //   Icons.folder,
  //           //   (info.materials_count ?? materialsCount(info)).toString(),
  //           // ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  // CLASSES TAB
  Widget _classesTab(ClassGroups cls) {
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
                _buildClassList(cls.ongoing_upcoming, isUpcoming: true),
                _buildClassList(cls.completed, isUpcoming: false),
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
  Widget _buildClassList(List<ClassItem> classes, {bool isUpcoming = false}) {
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

            return GestureDetector(
              onTap: () {
                _onClassAction(c);
              },
              child: ListTile(
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
                      Text('Completed on: ${_formatDateTime(c.timeEnd)}'),
                    ]
                    /// FALLBACK
                    else ...[
                      Text('Date: ${_formatDateTime(c.timeStart)}'),
                    ],
                    SizedBox(height: 6),
                    // ── Join / Start button (always shown) ──────────────────────

                  ],
                ),
                trailing: Text(
                  _actionLabelForStatus(status),
                  style: const TextStyle(color: Colors.green, fontSize: 14),
                ),
              ),
            );
          },
        );
      },
    );
    return SizedBox();
  }

  void _editClass(ClassItem c) {
    // open your edit bottom sheet
    _showEditClassBottomSheet(classItem: c);
  }

  void _confirmDelete(ClassItem c) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete "${c.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteClass(c);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteClass(ClassItem c) async {
    try {
      final response = await TeacherApiService().deleteCourseClass(
        c.id.toString(),
      );
      if (response['status'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Class deleted')));
        // _refreshDetails(); // reload list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Delete failed')),
        );
      }
    } catch (e) {
      debugPrint('Delete error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Something went wrong')));
    }
  }

  Future<void> _onClassAction(ClassItem c) async {
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
                classId: c.id,
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
              classId: c.id,
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
        return 'Not Started';
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
  Widget _materialsTab(List<MaterialItem> materials) {
    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: materials.length,
      itemBuilder: (context, i) {
        final m = materials[i];
        return _MaterialCard(
          material: m,
          onDownload: () => _downloadMaterial(m),
        );
      },
    );
  }

  TextStyle get _titleStyle =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold);

  Future<void> _openMaterial(MaterialItem item) async {
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

  Future<void> _downloadMaterial(MaterialItem item) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      // final savePath = "${dir.path}/${item.title}.${item.fileType}";
      final safeName = item.title
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '_');
      final ext = switch (item.fileType) {
        'voice' => 'mp3',
        'image' => 'jpg', // ✅ always save image as .jpg
        'pdf' => 'pdf',
        _ => item.fileType,
      };

      final savePath = "${dir.path}/$safeName.$ext";

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

  void _showEditClassBottomSheet({required ClassItem classItem}) {
    // ── Pre-fill existing values ──────────────────────────────────────────────
    final titleCtrl = TextEditingController(text: classItem.title ?? '');

    final startTime = DateTime.tryParse(classItem.timeStart ?? '');
    final endTime = DateTime.tryParse(classItem.timeEnd ?? '');

    DateTime? selectedDate = startTime;
    TimeOfDay? selectedStart = startTime != null
        ? TimeOfDay.fromDateTime(startTime)
        : null;
    TimeOfDay? selectedEnd = endTime != null
        ? TimeOfDay.fromDateTime(endTime)
        : null;

    String? formMessage;
    Color messageColor = Colors.red;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            // ── Inline alert ───────────────────────────────────────────────
            Widget buildAlert() {
              if (formMessage == null) return const SizedBox.shrink();
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: messageColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: messageColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      messageColor == Colors.green
                          ? Icons.check_circle
                          : Icons.error,
                      color: messageColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formMessage!,
                        style: TextStyle(color: messageColor),
                      ),
                    ),
                  ],
                ),
              );
            }

            // ── Show message helper ────────────────────────────────────────
            void showMessage(String msg, {required bool isError}) {
              setStateModal(() {
                formMessage = msg;
                messageColor = isError ? Colors.red : Colors.green;
              });
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) setStateModal(() => formMessage = null);
              });
            }

            // ── Submit ─────────────────────────────────────────────────────
            Future<void> submit() async {
              if (titleCtrl.text.trim().isEmpty) {
                showMessage('Enter class title', isError: true);
                return;
              }
              if (selectedDate == null) {
                showMessage('Select class date', isError: true);
                return;
              }
              if (selectedStart == null || selectedEnd == null) {
                showMessage('Select start & end time', isError: true);
                return;
              }

              final startMinutes =
                  selectedStart!.hour * 60 + selectedStart!.minute;
              final endMinutes = selectedEnd!.hour * 60 + selectedEnd!.minute;
              if (endMinutes <= startMinutes) {
                showMessage('End time must be after start time', isError: true);
                return;
              }

              final startDateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedStart!.hour,
                selectedStart!.minute,
              );
              final endDateTime = DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
                selectedEnd!.hour,
                selectedEnd!.minute,
              );

              final payload = {
                'class_id': classItem.id,
                'title': titleCtrl.text.trim(),
                'start_time': startDateTime.toIso8601String(),
                'end_time': endDateTime.toIso8601String(),
              };

              try {
                final response = await TeacherApiService().updateCourseClass(
                  payload,
                );

                if (response['status'] == true) {
                  showMessage(
                    response['message'] ?? 'Class updated',
                    isError: false,
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    if (!mounted) return;
                    Navigator.pop(context);
                  });
                } else {
                  showMessage(
                    response['message'] ?? 'Update failed',
                    isError: true,
                  );
                }
              } catch (e) {
                debugPrint('Edit class error: $e');
                showMessage('Something went wrong', isError: true);
              }
            }

            // ── UI ─────────────────────────────────────────────────────────
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Edit Class",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: const Color(0xFFF0F0F0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Alert
                    buildAlert(),
                    const SizedBox(height: 8),

                    // ── Title ──────────────────────────────────────────────
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        labelText: "Class Title",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ── Date ───────────────────────────────────────────────
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Class Date',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedDate == null
                                ? "--/--/----"
                                : "${selectedDate!.day.toString().padLeft(2, '0')}-"
                                      "${selectedDate!.month.toString().padLeft(2, '0')}-"
                                      "${selectedDate!.year}",
                            style: TextStyle(
                              color: selectedDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null)
                          setStateModal(() => selectedDate = picked);
                      },
                    ),

                    const Divider(height: 1),

                    // ── Start Time ─────────────────────────────────────────
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Start Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedStart == null
                                ? "--:-- AM/PM"
                                : selectedStart!.format(context),
                            style: TextStyle(
                              color: selectedStart == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedStart ?? TimeOfDay.now(),
                        );
                        if (picked != null)
                          setStateModal(() => selectedStart = picked);
                      },
                    ),

                    const Divider(height: 1),

                    // ── End Time ───────────────────────────────────────────
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'End Time',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedEnd == null
                                ? "--:-- AM/PM"
                                : selectedEnd!.format(context),
                            style: TextStyle(
                              color: selectedEnd == null
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedEnd ?? TimeOfDay.now(),
                        );
                        if (picked != null)
                          setStateModal(() => selectedEnd = picked);
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Submit ─────────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Update Class",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Stateful card to handle voice playback independently ─────────────────────

// class _MaterialCard extends StatefulWidget {
//   final MaterialItem material;
//   final VoidCallback onDownload;
//
//   const _MaterialCard({required this.material, required this.onDownload});
//
//   @override
//   State<_MaterialCard> createState() => _MaterialCardState();
// }
//
// class _MaterialCardState extends State<_MaterialCard> {
//   final AudioPlayer _player = AudioPlayer();
//
//   bool _isPlaying = false;
//   bool _isLoading = false;
//   Duration _duration = Duration.zero;
//   Duration _position = Duration.zero;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Track duration
//     _player.onDurationChanged.listen((d) {
//       if (mounted) setState(() => _duration = d);
//     });
//
//     // Track position
//     _player.onPositionChanged.listen((p) {
//       if (mounted) setState(() => _position = p);
//     });
//
//     // Reset on complete
//     _player.onPlayerComplete.listen((_) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = false;
//           _position = Duration.zero;
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _player.dispose();
//     super.dispose();
//   }
//
//   Future<void> _togglePlay() async {
//     if (_isPlaying) {
//       await _player.pause();
//       setState(() => _isPlaying = false);
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       await _player.play(
//         UrlSource(widget.material.fileUrl),
//       ); // ✅ stream from URL
//       setState(() {
//         _isPlaying = true;
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() => _isLoading = false);
//       debugPrint('Playback error: $e');
//     }
//   }
//
//   String _fmt(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return '$m:$s';
//   }
//
//   // ── Icon per type ───────────────────────────────────────────────────────────
//   IconData get _icon {
//     switch (widget.material.fileType) {
//       case 'pdf':
//         return Icons.picture_as_pdf_rounded;
//       case 'image':
//         return Icons.image_rounded;
//       case 'voice':
//         return Icons.mic_rounded;
//       default:
//         return Icons.insert_drive_file_rounded;
//     }
//   }
//
//   Color get _iconColor {
//     switch (widget.material.fileType) {
//       case 'pdf':
//         return const Color(0xFFE53935);
//       case 'image':
//         return const Color(0xFF1E88E5);
//       case 'voice':
//         return const Color(0xFF43A047);
//       default:
//         return Colors.grey;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isVoice = widget.material.fileType == 'voice';
//
//     return Card(
//       margin: const EdgeInsets.only(bottom: 10),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 1.5,
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Top row ───────────────────────────────────────────────────
//             Row(
//               children: [
//                 // Type icon
//                 Container(
//                   width: 44,
//                   height: 44,
//                   decoration: BoxDecoration(
//                     color: _iconColor.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Icon(_icon, color: _iconColor, size: 22),
//                 ),
//                 const SizedBox(width: 12),
//
//                 // Title + type
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.material.title,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.w600,
//                           fontSize: 15,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         widget.material.fileType.toUpperCase(),
//                         style: TextStyle(
//                           fontSize: 11,
//                           color: _iconColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // Download button (all types)
//                 IconButton(
//                   icon: const Icon(Icons.download_rounded),
//                   onPressed: widget.onDownload,
//                   color: Colors.grey[600],
//                 ),
//               ],
//             ),
//
//             // ── Voice player ──────────────────────────────────────────────
//             if (isVoice) ...[
//               const SizedBox(height: 12),
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 8,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFF0FFF4),
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: const Color(0xFF43A047).withOpacity(0.3),
//                   ),
//                 ),
//                 child: Row(
//                   children: [
//                     // Play / pause / loading
//                     GestureDetector(
//                       onTap: _togglePlay,
//                       child: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: const BoxDecoration(
//                           color: Color(0xFF43A047),
//                           shape: BoxShape.circle,
//                         ),
//                         child: _isLoading
//                             ? const Padding(
//                                 padding: EdgeInsets.all(10),
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             : Icon(
//                                 _isPlaying
//                                     ? Icons.pause_rounded
//                                     : Icons.play_arrow_rounded,
//                                 color: Colors.white,
//                                 size: 24,
//                               ),
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//
//                     // Progress slider
//                     Expanded(
//                       child: Column(
//                         children: [
//                           SliderTheme(
//                             data: SliderTheme.of(context).copyWith(
//                               trackHeight: 3,
//                               thumbShape: const RoundSliderThumbShape(
//                                 enabledThumbRadius: 6,
//                               ),
//                               overlayShape: const RoundSliderOverlayShape(
//                                 overlayRadius: 12,
//                               ),
//                               activeTrackColor: const Color(0xFF43A047),
//                               inactiveTrackColor: const Color(0xFFCCE5CC),
//                               thumbColor: const Color(0xFF43A047),
//                               overlayColor: const Color(0xFF43A047),
//                             ),
//                             child: Slider(
//                               min: 0,
//                               max: _duration.inSeconds.toDouble().clamp(
//                                 1,
//                                 double.infinity,
//                               ),
//                               value: _position.inSeconds.toDouble().clamp(
//                                 0,
//                                 _duration.inSeconds.toDouble(),
//                               ),
//                               onChanged: (v) async {
//                                 await _player.seek(
//                                   Duration(seconds: v.toInt()),
//                                 );
//                               },
//                             ),
//                           ),
//
//                           // Time labels
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 4),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   _fmt(_position),
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                                 Text(
//                                   _fmt(_duration),
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }



// ─────────────────────────────────────────────────────────────────────────────
// Palette constants
// ─────────────────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF4A47B0);
const _kPrimaryLight = Color(0xFFEEF0FF);
const _kGreen = Color(0xFF2E7D32);
const _kGreenLight = Color(0xFFE8F5E9);
const _kAmber = Color(0xFFB85C00);
const _kAmberLight = Color(0xFFFFF3E0);
const _kBlue = Color(0xFF1565C0);
const _kBlueLight = Color(0xFFE3F2FD);
const _kRed = Color(0xFFE53935);
const _kRedLight = Color(0xFFFFEBEE);
const _kTeal = Color(0xFF0F6E56);
const _kTealLight = Color(0xFFE1F5EE);
const _kBorder = Color(0xFFEEEEEE);
const _kSurface = Color(0xFFF8F8FC);
const _kText = Color(0xFF1A1A2E);
const _kTextMuted = Color(0xFF9E9E9E);

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT TAB
// ─────────────────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final CourseInfo info;
  const _AboutTab({required this.info});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (info.description?.isNotEmpty == true) ...[
          const SizedBox(height: 20),
          _SectionLabel('About this course'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Html(
              data: info.description!,
              style: {
                'body': Style(
                  fontSize: FontSize(14),
                  lineHeight: LineHeight(1.6),
                  color: Colors.black87,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              },
            ),
          ),
        ],
        const SizedBox(height: 20),
        _SectionLabel('Course dates'),
        const SizedBox(height: 10),
        _DateRow(
          icon: Icons.play_circle_outline_rounded,
          label: 'Started',
          value: _fmtDate(info.startedAt),
          color: _kGreen,
        ),
        const SizedBox(height: 8),
        _DateRow(
          icon: Icons.stop_circle_outlined,
          label: 'Ends',
          value: _fmtDate(info.endedAt),
          color: _kRed,
        ),
        const SizedBox(height: 20),
        _SectionLabel('Instructor(s)'),
        const SizedBox(height: 10),
        ...(info.instructors ?? []).map((inst) => _InstructorTile(inst)),
        const SizedBox(height: 20),
        _SectionLabel('Course information'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: [
            if (info.duration?.isNotEmpty == true)
              _InfoCard(
                  icon: Icons.timer_outlined,
                  label: 'Duration',
                  value: info.duration!),
            if (info.mode?.isNotEmpty == true)
              _InfoCard(
                  icon: Icons.live_tv_outlined,
                  label: 'Mode',
                  value: _cap(info.mode!)),
            if (info.level?.isNotEmpty == true)
              _InfoCard(
                  icon: Icons.grade_outlined,
                  label: 'Level',
                  value: _cap(info.level!)),
            if (info.courseType?.isNotEmpty == true)
              _InfoCard(
                  icon: Icons.auto_graph_outlined,
                  label: 'Type',
                  value: _cap(info.courseType!)),
          ],
        ),
        const SizedBox(height: 20),
        _SectionLabel('Special features'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _FeatureChip(
                label: 'Counselling',
                enabled: info.counsellingSection,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _FeatureChip(
                label: 'Career Guidance',
                enabled: info.careerGuidance,
              ),
            ),
          ],
        ),



        const SizedBox(height: 40),
      ],
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CLASSES TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ClassesTab extends StatefulWidget {
  final List<ClassItem> ongoing;
  final List<ClassItem> completed;

  const _ClassesTab({
    required this.ongoing,
    required this.completed,
  });

  @override
  State<_ClassesTab> createState() => _ClassesTabState();
}

class _ClassesTabState extends State<_ClassesTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  int get _total => widget.ongoing.length + widget.completed.length;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              _StatBox(value: _total, label: 'Total', color: _kText),
              const SizedBox(width: 8),
              _StatBox(
                value: widget.completed.length,
                label: 'Completed',
                color: _kGreen,
              ),
              const SizedBox(width: 8),
              _StatBox(
                value: widget.ongoing.length,
                label: 'Pending',
                color: _kAmber,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _kBorder),
            ),
            child: TabBar(
              controller: _tab,
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBorder),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: _kPrimary,
              unselectedLabelColor: _kTextMuted,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Ongoing & Upcoming'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _ClassList(
                classes: widget.ongoing,
                isCompleted: false,
              ),
              _ClassList(
                classes: widget.completed,
                isCompleted: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ClassList extends StatelessWidget {
  final List<ClassItem> classes;
  final bool isCompleted;

  const _ClassList({
    required this.classes,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_outline_rounded
                  : Icons.schedule_rounded,
              size: 48,
              color: _kTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              isCompleted ? 'No completed classes' : 'No upcoming classes',
              style: const TextStyle(color: _kTextMuted),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      itemCount: classes.length,
      itemBuilder: (ctx, i) {
        final c = classes[i];
        return isCompleted
            ? _CompletedClassCard(
          cls: c,
        )
            : _OngoingClassCard(
          cls: c,
        );
      },
    );
  }
}

// ─── Ongoing/Upcoming class card ──────────────────────────────────────────────

class _OngoingClassCard extends StatelessWidget {
  final ClassItem cls;

  const _OngoingClassCard({
    required this.cls,
  });

  bool get _isLive {
    final now = DateTime.now();
    final start = DateTime.tryParse(cls.timeStart ?? '');
    final end = DateTime.tryParse(cls.timeEnd ?? '');
    return start != null &&
        end != null &&
        now.isAfter(start) &&
        now.isBefore(end);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _isLive ? _kRedLight : _kPrimaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isLive
                        ? Icons.sensors_rounded
                        : Icons.video_library_rounded,
                    size: 20,
                    color: _isLive ? _kRed : _kPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _MetaChip(
                            icon: Icons.calendar_today_outlined,
                            label: _fmtDate(cls.timeStart),
                          ),
                          _MetaChip(
                            icon: Icons.access_time_outlined,
                            label:
                            '${_fmtTime(cls.timeStart)} – ${_fmtTime(cls.timeEnd)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: cls.classStatus),
              ],
            ),
          ),

          Container(
            decoration: const BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    label: _isLive ? 'Join now' : 'Not started',
                    icon: _isLive
                        ? Icons.sensors_rounded
                        : Icons.schedule_rounded,
                    bgColor: _isLive ? _kPrimary : _kSurface,
                    textColor: _isLive ? Colors.white : _kTextMuted,
                    borderColor: _isLive ? _kPrimary : _kBorder,
                    onTap: () => _join(context),
                  ),
                ),
                const SizedBox(width: 6),


              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _join(BuildContext context) async {
    if (!_isLive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class not started yet')),
      );
      return;
    }
    final link = cls.joinLink;
    if (link == null || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join link not available')),
      );
      return;
    }
    final uri = Uri.tryParse(link);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// ─── Completed class card ─────────────────────────────────────────────────────

class _CompletedClassCard extends StatelessWidget {
  final ClassItem cls;
  const _CompletedClassCard({
    required this.cls,
  });

  int get _pct => cls.totalStudents > 0
      ? (cls.presentCount / cls.totalStudents * 100).round()
      : 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _kGreenLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: _kGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cls.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _MetaChip(
                            icon: Icons.calendar_today_outlined,
                            label: _fmtDate(cls.timeStart),
                          ),
                          _MetaChip(
                            icon: Icons.access_time_outlined,
                            label:
                            '${_fmtTime(cls.timeStart)} – ${_fmtTime(cls.timeEnd)}',
                          ),
                          if (cls.actualDuration != null)
                            _MetaChip(
                              icon: Icons.timer_outlined,
                              label: cls.actualDuration!,
                              color: _kTeal,
                              bgColor: _kTealLight,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: cls.classStatus),
              ],
            ),
          ),



          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                Expanded(
                  child: _ActionBtn(
                    label: 'Watch',
                    icon: Icons.play_circle_outline_rounded,
                    bgColor: Colors.redAccent,
                    textColor: Colors.white,
                    borderColor: _kBorder,
                    onTap: () {
                      final url = cls.recordedVideo;
                      if (url != null && url.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoClassScreen(
                              title: cls.title,
                              videoUrl: url,
                              classId: cls.id,
                              type: 'course',
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Recording not available'),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




}

// ─────────────────────────────────────────────────────────────────────────────
// MATERIALS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _MaterialsTab extends StatelessWidget {
  final List<MaterialItem> materials;
  final void Function(MaterialItem) onDownload;

  const _MaterialsTab({
    required this.materials,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 48, color: _kTextMuted),
            SizedBox(height: 12),
            Text('No materials available',
                style: TextStyle(color: _kTextMuted)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: materials.length,
      itemBuilder: (ctx, i) => _MaterialCard(
        material: materials[i],
        onDownload: () => onDownload(materials[i])
      ),
    );
  }
}

class _MaterialCard extends StatefulWidget {
  final MaterialItem material;
  final VoidCallback onDownload;

  const _MaterialCard({
    required this.material,
    required this.onDownload,
  });

  @override
  State<_MaterialCard> createState() => _MaterialCardState();
}

class _MaterialCardState extends State<_MaterialCard> {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  bool _loading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted)
        setState(() {
          _playing = false;
          _position = Duration.zero;
        });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_playing) {
      await _player.pause();
      setState(() => _playing = false);
      return;
    }
    setState(() => _loading = true);
    try {
      await _player.play(UrlSource(widget.material.fileUrl));
      setState(() {
        _playing = true;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Color get _color {
    switch (widget.material.fileType) {
      case 'pdf':
        return _kRed;
      case 'image':
        return const Color(0xFF1E88E5);
      case 'voice':
        return const Color(0xFF43A047);
      default:
        return _kTextMuted;
    }
  }

  Color get _bgColor {
    switch (widget.material.fileType) {
      case 'pdf':
        return _kRedLight;
      case 'image':
        return _kBlueLight;
      case 'voice':
        return _kGreenLight;
      default:
        return _kSurface;
    }
  }

  IconData get _icon {
    switch (widget.material.fileType) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'image':
        return Icons.image_rounded;
      case 'voice':
        return Icons.mic_rounded;
      default:
        return Icons.insert_drive_file_rounded;
    }
  }


  @override
  Widget build(BuildContext context) {
    final isVoice = widget.material.fileType == 'voice';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_icon, color: _color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.material.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.material.fileType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: _color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              _IconRoundBtn(
                icon: Icons.download_rounded,
                color: _kTextMuted,
                onTap: widget.onDownload,
              ),

            ],
          ),

          if (isVoice) ...[
            const SizedBox(height: 12),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FFF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF43A047).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggle,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF43A047),
                        shape: BoxShape.circle,
                      ),
                      child: _loading
                          ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Icon(
                        _playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12),
                            activeTrackColor: const Color(0xFF43A047),
                            inactiveTrackColor: const Color(0xFFCCE5CC),
                            thumbColor: const Color(0xFF43A047),
                            overlayColor:
                            const Color(0xFF43A047).withOpacity(0.2),
                          ),
                          child: Slider(
                            min: 0,
                            max: _duration.inSeconds
                                .toDouble()
                                .clamp(1, double.infinity),
                            value: _position.inSeconds
                                .toDouble()
                                .clamp(0, _duration.inSeconds.toDouble()),
                            onChanged: (v) =>
                                _player.seek(Duration(seconds: v.toInt())),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_fmt(_position),
                                  style: const TextStyle(
                                      fontSize: 10, color: _kTextMuted)),
                              Text(_fmt(_duration),
                                  style: const TextStyle(
                                      fontSize: 10, color: _kTextMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: _kTextMuted,
      letterSpacing: 0.6,
    ),
  );
}

class _InstructorTile extends StatelessWidget {
  final InstructorItem inst;
  const _InstructorTile(this.inst);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: _kPrimaryLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            inst.initials,
            style: const TextStyle(
              color: _kPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              inst.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
            ),
            if (inst.specialization?.isNotEmpty == true)
              Text(
                inst.specialization!,
                style:
                const TextStyle(fontSize: 12, color: _kTextMuted),
              ),
          ],
        ),
      ],
    ),
  );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCard(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: _kPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label,
                  style:
                  const TextStyle(fontSize: 10, color: _kTextMuted)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final bool enabled;
  const _FeatureChip({required this.label, required this.enabled});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    decoration: BoxDecoration(
      color: enabled ? _kGreenLight : _kAmberLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: enabled
            ? _kGreen.withOpacity(0.3)
            : _kAmber.withOpacity(0.3),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 16,
          color: enabled ? _kGreen : _kAmber,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: enabled ? _kGreen : _kAmber,
            ),
          ),
        ),
      ],
    ),
  );
}

class _DateRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DateRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(fontSize: 12, color: _kTextMuted)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  const _MetaChip({
    required this.icon,
    required this.label,
    this.color = _kTextMuted,
    this.bgColor = _kSurface,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: color)),
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    final isCompleted = s == 'completed';
    final isLive = s == 'ongoing';
    final bg = isCompleted ? _kGreenLight : isLive ? _kRedLight : _kBlueLight;
    final fg = isCompleted ? _kGreen : isLive ? _kRed : _kBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        isLive ? 'Live' : _cap(status),
        style:
        TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _StatBox extends StatelessWidget {
  final int value;
  final String label;
  final Color color;
  const _StatBox(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: _kTextMuted)),
        ],
      ),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor, textColor, borderColor;
  final VoidCallback onTap;
  final bool compact;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(
        vertical: 9,
        horizontal: compact ? 10 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          if (!compact)
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
        ],
      ),
    ),
  );
}

class _IconRoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? bg;

  const _IconRoundBtn({
    required this.icon,
    required this.onTap,
    this.color,
    this.bg,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bg ?? _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Icon(icon, size: 18, color: color ?? _kText),
    ),
  );
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kPrimaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kPrimary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: _kPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: _kTextMuted,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: _kPrimary),
        ],
      ),
    ),
  );
}

class _AlertBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const _AlertBanner({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: isError ? _kRedLight : _kGreenLight,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
          color: isError
              ? _kRed.withOpacity(0.4)
              : _kGreen.withOpacity(0.4)),
    ),
    child: Row(
      children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          size: 16,
          color: isError ? _kRed : _kGreen,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: isError ? _kRed : _kGreen,
            ),
          ),
        ),
      ],
    ),
  );
}

class _ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;

  const _ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape:
    RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Text(title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 16)),
    content: Text(message, style: const TextStyle(fontSize: 14)),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, true),
        style: TextButton.styleFrom(foregroundColor: confirmColor),
        child: Text(confirmLabel,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helpers
// ─────────────────────────────────────────────────────────────────────────────

String _fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  try {
    return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

String _fmtTime(String? iso) {
  if (iso == null || iso.isEmpty) return '--:--';
  try {
    final dt = DateTime.parse(iso);
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  } catch (_) {
    return iso;
  }
}

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

