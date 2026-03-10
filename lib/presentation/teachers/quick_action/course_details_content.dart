import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../model/course_details_model.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../services/teacher_api_service.dart';
import '../../students/recorded_video_with_doubt.dart';

class CourseDetailsContent extends StatefulWidget {
  final CourseDetails course;
  final VoidCallback? onRefresh; // ✅ callback for edit/delete class reload

  const CourseDetailsContent({
    super.key,
    required this.course,
    this.onRefresh,
  });

  @override
  State<CourseDetailsContent> createState() => _CourseDetailsContentState();
}

class _CourseDetailsContentState extends State<CourseDetailsContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<Map<String, Duration>> _countdownNotifier =
  ValueNotifier({});

  Timer? _ticker;
  Duration countdownThreshold = const Duration(hours: 4);

  // ✅ local class lists for instant remove
  late List<ClassItem> _ongoingUpcoming;
  late List<ClassItem> _completed;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _ongoingUpcoming = List.from(widget.course.classes.ongoing_upcoming);
    _completed       = List.from(widget.course.classes.completed);
  }

  @override
  Widget build(BuildContext context) {
    final info      = widget.course.course;
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
              _classesTab(),
              _materialsTab(materials),
            ],
          ),
        ),
      ],
    );
  }

  // ─── ABOUT TAB ──────────────────────────────────────────────────────────────

  Widget _aboutTab(CourseInfo c) {
    final desc     = c.description ?? '';
    final duration = c.duration    ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 16),
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
            _statChip(Icons.timer, duration.isEmpty ? '—' : duration),
          ],
        ),
      ],
    );
  }

  // ─── CLASSES TAB ────────────────────────────────────────────────────────────

  Widget _classesTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
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
                _buildClassList(_ongoingUpcoming, isCompleted: false),
                _buildClassList(_completed,       isCompleted: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(List<ClassItem> classes, {required bool isCompleted}) {
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
            final c          = classes[i];
            final status     = (c.classStatus ?? '').toLowerCase();
            final id         = c.id.toString();
            final remaining  = countdowns[id];
            final startTime  = DateTime.tryParse(c.timeStart ?? '');
            final endTime    = DateTime.tryParse(c.timeEnd   ?? '');
            final now        = DateTime.now();

            final itemIsUpcoming  = startTime != null && now.isBefore(startTime);
            final itemIsOngoing   = startTime != null && endTime != null &&
                now.isAfter(startTime) && now.isBefore(endTime);
            final itemIsCompleted = endTime != null && now.isAfter(endTime);

            return GestureDetector(
              onTap: () => _onClassAction(c),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                leading: const Icon(Icons.video_library,
                    size: 34, color: Colors.green),
                title: Text(
                  c.title ?? 'Unnamed Class',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (itemIsUpcoming && remaining != null) ...[
                      if (remaining <= countdownThreshold)
                        Text('Starts in: ${_humanDuration(remaining)}')
                      else
                        Text('Date: ${_formatDateTime(c.timeEnd)}'),
                    ] else if (itemIsOngoing) ...[
                      const Text(
                        'Live now',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ] else if (itemIsCompleted) ...[
                      Text('Completed on: ${_formatDateTime(c.timeEnd)}'),
                    ] else ...[
                      Text('Date: ${_formatDateTime(c.timeStart)}'),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _actionLabelForStatus(status),
                      style: const TextStyle(color: Colors.green, fontSize: 14),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ✅ 3-dot menu only for non-completed
                    if (!itemIsCompleted)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded,
                            color: Colors.grey),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        onSelected: (value) {
                          if (value == 'edit')   _editClass(c);
                          if (value == 'delete') _confirmDeleteClass(c);
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: const [
                                Icon(Icons.edit_rounded,
                                    color: Colors.blue, size: 18),
                                SizedBox(width: 10),
                                Text('Edit',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: const [
                                Icon(Icons.delete_outline_rounded,
                                    color: Colors.red, size: 18),
                                SizedBox(width: 10),
                                Text('Delete',
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Class Actions ───────────────────────────────────────────────────────────

  void _editClass(ClassItem c) {
    _showEditClassBottomSheet(classItem: c);
  }

  void _confirmDeleteClass(ClassItem c) {
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
          c.id.toString());
      if (response['status'] == true) {
        // ✅ instant remove from local list
        setState(() {
          _ongoingUpcoming.removeWhere((item) => item.id == c.id);
          _completed.removeWhere((item) => item.id == c.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class deleted')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? 'Delete failed')));
      }
    } catch (e) {
      debugPrint('Delete class error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong')));
    }
  }

  Future<void> _onClassAction(ClassItem c) async {
    final status   = (c.classStatus ?? '').toLowerCase();
    final joinLink = c.joinLink?.toString();
    final recorded = c.recordedVideo?.toString();
    final title    = (c.title ?? '').toString();
    final source   = (c.source ?? '').toString();

    if (status == 'ongoing') {
      if (joinLink != null && joinLink.isNotEmpty) {
        if (source == 'gmeet') {
          await _openUrl(joinLink);
        } else if (source == 'youtube') {
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => RecordedVideoWithDoubt(
                title: title, videoUrl: joinLink,
                classId: c.id, type: 'course'),
          ));
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
        Navigator.push(context, MaterialPageRoute(
          builder: (_) => RecordedVideoWithDoubt(
              title: title, videoUrl: recorded,
              classId: c.id, type: 'course'),
        ));
      } else {
        _showSnack("Recording not available");
      }
    } else {
      _showSnack("Action not available");
    }
  }

  String _actionLabelForStatus(String status) {
    switch (status) {
      case 'ongoing':   return 'Join';
      case 'completed': return 'Watch';
      default:          return 'Not Started';
    }
  }

  // ─── MATERIALS TAB ──────────────────────────────────────────────────────────

  Widget _materialsTab(List<MaterialItem> materials) {
    return _MaterialsList(
      materials: materials,
      onDownload: _downloadMaterial,
    );
  }

  Future<void> _downloadMaterial(MaterialItem item) async {
    try {
      final dir      = await getApplicationDocumentsDirectory();
      final safeName = item.title
          .replaceAll(RegExp(r'[^\w\s]+'), '')
          .replaceAll(' ', '_');
      final ext = switch (item.fileType) {
        'voice' => 'mp3',
        'image' => 'jpg',
        'pdf'   => 'pdf',
        _       => item.fileType,
      };
      final savePath = "${dir.path}/$safeName.$ext";

      await Dio().download(item.fileUrl, savePath);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloaded: $safeName.$ext")));
      await OpenFilex.open(savePath);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download Failed: $e")));
    }
  }

  // ─── Edit Class Bottom Sheet ─────────────────────────────────────────────────

  void _showEditClassBottomSheet({required ClassItem classItem}) {
    final titleCtrl = TextEditingController(text: classItem.title ?? '');
    final startTime = DateTime.tryParse(classItem.timeStart ?? '');
    final endTime   = DateTime.tryParse(classItem.timeEnd   ?? '');

    DateTime?  selectedDate  = startTime;
    TimeOfDay? selectedStart = startTime != null ? TimeOfDay.fromDateTime(startTime) : null;
    TimeOfDay? selectedEnd   = endTime   != null ? TimeOfDay.fromDateTime(endTime)   : null;

    String? formMessage;
    Color   messageColor = Colors.red;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {

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
                          ? Icons.check_circle : Icons.error,
                      color: messageColor, size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(formMessage!,
                          style: TextStyle(color: messageColor)),
                    ),
                  ],
                ),
              );
            }

            void showMessage(String msg, {required bool isError}) {
              setStateModal(() {
                formMessage  = msg;
                messageColor = isError ? Colors.red : Colors.green;
              });
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) setStateModal(() => formMessage = null);
              });
            }

            Future<void> submit() async {
              if (titleCtrl.text.trim().isEmpty) {
                showMessage('Enter class title', isError: true); return;
              }
              if (selectedDate == null) {
                showMessage('Select class date', isError: true); return;
              }
              if (selectedStart == null || selectedEnd == null) {
                showMessage('Select start & end time', isError: true); return;
              }
              final startMins = selectedStart!.hour * 60 + selectedStart!.minute;
              final endMins   = selectedEnd!.hour   * 60 + selectedEnd!.minute;
              if (endMins <= startMins) {
                showMessage('End time must be after start time', isError: true); return;
              }

              final startDT = DateTime(selectedDate!.year, selectedDate!.month,
                  selectedDate!.day, selectedStart!.hour, selectedStart!.minute);
              final endDT   = DateTime(selectedDate!.year, selectedDate!.month,
                  selectedDate!.day, selectedEnd!.hour,   selectedEnd!.minute);

              final payload = {
                'class_id'   : classItem.id,
                'title'      : titleCtrl.text.trim(),
                'start_time' : startDT.toIso8601String(),
                'end_time'   : endDT.toIso8601String(),
              };

              try {
                final response =
                await TeacherApiService().updateCourseClass(payload);
                if (response['status'] == true) {
                  showMessage(response['message'] ?? 'Class updated',
                      isError: false);
                  Future.delayed(const Duration(seconds: 1), () {
                    if (!mounted) return;
                    Navigator.pop(context);
                    widget.onRefresh?.call(); // ✅ reload after edit
                  });
                } else {
                  showMessage(response['message'] ?? 'Update failed',
                      isError: true);
                }
              } catch (e) {
                debugPrint('Edit class error: $e');
                showMessage('Something went wrong', isError: true);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16, right: 16, top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2)),
                    ),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Edit Class",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFF0F0F0)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    buildAlert(),
                    const SizedBox(height: 8),

                    // ✅ Title — highlighted editable field
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: "Class Title",
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.blue.shade50, // ✅ highlight
                      ),
                    ),
                    const SizedBox(height: 15),

                    // ✅ Date — highlighted
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, // ✅ highlight
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Class Date',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              selectedDate == null
                                  ? "--/--/----"
                                  : "${selectedDate!.day.toString().padLeft(2, '0')}-"
                                  "${selectedDate!.month.toString().padLeft(2, '0')}-"
                                  "${selectedDate!.year}",
                              style: TextStyle(
                                  color: selectedDate == null
                                      ? Colors.grey : Colors.black87),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.calendar_today,
                            color: Colors.blue),
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
                    ),
                    const SizedBox(height: 10),

                    // ✅ Start Time — highlighted
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, // ✅ highlight
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Start Time',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              selectedStart == null
                                  ? "--:-- AM/PM"
                                  : selectedStart!.format(context),
                              style: TextStyle(
                                  color: selectedStart == null
                                      ? Colors.grey : Colors.black87),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.access_time,
                            color: Colors.blue),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedStart ?? TimeOfDay.now(),
                          );
                          if (picked != null)
                            setStateModal(() => selectedStart = picked);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ End Time — highlighted
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50, // ✅ highlight
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: ListTile(
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('End Time',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              selectedEnd == null
                                  ? "--:-- AM/PM"
                                  : selectedEnd!.format(context),
                              style: TextStyle(
                                  color: selectedEnd == null
                                      ? Colors.grey : Colors.black87),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.access_time,
                            color: Colors.blue),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: selectedEnd ?? TimeOfDay.now(),
                          );
                          if (picked != null)
                            setStateModal(() => selectedEnd = picked);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Update Class",
                            style: TextStyle(fontSize: 16)),
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

  // ─── Helpers ─────────────────────────────────────────────────────────────────

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

  String _formatDateTime(dynamic dt) {
    try {
      final d = DateTime.parse(dt.toString());
      return DateFormat.yMMMEd().add_jm().format(d);
    } catch (_) {
      return dt?.toString() ?? '-';
    }
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
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  String _humanDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }
}

// ─── Materials List (stateful for instant remove) ─────────────────────────────

class _MaterialsList extends StatefulWidget {
  final List<MaterialItem> materials;
  final void Function(MaterialItem) onDownload;

  const _MaterialsList({
    required this.materials,
    required this.onDownload,
  });

  @override
  State<_MaterialsList> createState() => _MaterialsListState();
}

class _MaterialsListState extends State<_MaterialsList> {
  late List<MaterialItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.materials); // ✅ local copy
  }

  void _removeItem(MaterialItem m) {
    setState(() {
      _items.removeWhere((item) => item.id == m.id); // ✅ instant remove
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return const Center(child: Text('No materials available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(15),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final m = _items[i];
        return _MaterialCard(
          material: m,
          onDownload: () => widget.onDownload(m),
          onDeleted: () => _removeItem(m), // ✅ remove on delete success
        );
      },
    );
  }
}

// ─── Material Card ────────────────────────────────────────────────────────────

class _MaterialCard extends StatefulWidget {
  final MaterialItem material;
  final VoidCallback onDownload;
  final VoidCallback? onDeleted; // ✅ callback to remove from list

  const _MaterialCard({
    required this.material,
    required this.onDownload,
    this.onDeleted,
  });

  @override
  State<_MaterialCard> createState() => _MaterialCardState();
}

class _MaterialCardState extends State<_MaterialCard> {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  bool _isLoading = false;
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
      if (mounted) setState(() {
        _isPlaying = false;
        _position  = Duration.zero;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _player.play(UrlSource(widget.material.fileUrl));
      setState(() { _isPlaying = true; _isLoading = false; });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Playback error: $e');
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  IconData get _icon {
    switch (widget.material.fileType) {
      case 'pdf':   return Icons.picture_as_pdf_rounded;
      case 'image': return Icons.image_rounded;
      case 'voice': return Icons.mic_rounded;
      default:      return Icons.insert_drive_file_rounded;
    }
  }

  Color get _iconColor {
    switch (widget.material.fileType) {
      case 'pdf':   return const Color(0xFFE53935);
      case 'image': return const Color(0xFF1E88E5);
      case 'voice': return const Color(0xFF43A047);
      default:      return Colors.grey;
    }
  }

  // ── Delete confirm dialog ───────────────────────────────────────────────────
  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Material'),
        content: Text(
            'Are you sure you want to delete "${widget.material.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteMaterial();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMaterial() async {
    try {
      final response = await TeacherApiService()
          .deleteCourseMaterial(widget.material.id.toString());
      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material deleted')));
        widget.onDeleted?.call(); // ✅ instant remove from list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(response['message'] ?? 'Delete failed')));
      }
    } catch (e) {
      debugPrint('Delete material error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVoice = widget.material.fileType == 'voice';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ─────────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: _iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.material.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(widget.material.fileType.toUpperCase(),
                          style: TextStyle(
                              fontSize: 11,
                              color: _iconColor,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                // Download
                IconButton(
                  icon: const Icon(Icons.download_rounded),
                  onPressed: widget.onDownload,
                  color: Colors.grey[600],
                ),
                // ✅ Delete — same pattern as class delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20),
                  color: Colors.red,
                  tooltip: 'Delete',
                  onPressed: _confirmDelete,
                ),
              ],
            ),

            // ── Voice player ─────────────────────────────────────────────
            if (isVoice) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF43A047).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 40, height: 40,
                        decoration: const BoxDecoration(
                            color: Color(0xFF43A047), shape: BoxShape.circle),
                        child: _isLoading
                            ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 10),
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
                              activeTrackColor:   const Color(0xFF43A047),
                              inactiveTrackColor: const Color(0xFFCCE5CC),
                              thumbColor:         const Color(0xFF43A047),
                              overlayColor:       const Color(0xFF43A047),
                            ),
                            child: Slider(
                              min: 0,
                              max: _duration.inSeconds.toDouble()
                                  .clamp(1, double.infinity),
                              value: _position.inSeconds.toDouble()
                                  .clamp(0, _duration.inSeconds.toDouble()),
                              onChanged: (v) async {
                                await _player
                                    .seek(Duration(seconds: v.toInt()));
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_fmt(_position),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                                Text(_fmt(_duration),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
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
      ),
    );
  }
}