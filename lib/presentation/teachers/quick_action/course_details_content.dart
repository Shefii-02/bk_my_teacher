import 'dart:async';
import 'package:BookMyTeacher/presentation/teachers/quick_action/update_duration_sheet.dart';
import 'package:BookMyTeacher/services/launch_status_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../model/course_details_model.dart';
import '../../../services/teacher_api_service.dart';
import '../../record_section/video_class_screen.dart';
import '../../students/recorded_video_with_doubt.dart';
import 'attendance_sheet.dart';



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
// Main Page (loads data itself)
// ─────────────────────────────────────────────────────────────────────────────

class CourseDetailsPage extends StatefulWidget {
  final int courseId;
  const CourseDetailsPage({super.key, required this.courseId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  late Future<CourseDetailsResponse> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = TeacherApiService().getCourseDetails(widget.courseId);
  }

  void _refresh() => setState(() => _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kSurface,
      body: FutureBuilder<CourseDetailsResponse>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data?.status != true) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: _kRed),
                  const SizedBox(height: 12),
                  Text(
                    snap.data?.message ?? 'Failed to load course',
                    style: const TextStyle(color: _kTextMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return CourseDetailsContent(
            course: snap.data!.data,
            onRefresh: _refresh,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Course Details Content (tabs shell)
// ─────────────────────────────────────────────────────────────────────────────

class CourseDetailsContent extends StatefulWidget {
  final CourseDetails course;
  final VoidCallback? onRefresh; // FIX: nullable

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
  late TabController _tab;

  late List<ClassItem> _ongoing;
  late List<ClassItem> _completed;
  late List<MaterialItem> _materials;


  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _ongoing = List.from(widget.course.classes.ongoing_upcoming);
    _completed = List.from(widget.course.classes.completed);
    _materials = List.from(widget.course.materials);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.course.course;

    return Column(
      children: [
        _CourseBanner(info: info),
        _CourseMetaBar(info: info),
        _tabBar(),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _AboutTab(info: info),
              _ClassesTab(
                ongoing: _ongoing,
                completed: _completed,
                onDeleteClass: _deleteClass,
                onEditClass: _editClass,
                onRefresh: widget.onRefresh, // FIX: VoidCallback? passed to VoidCallback?
              ),
              _MaterialsTab(
                materials: _materials,
                onDownload: _downloadMaterial,
                onDeleted: (m) => setState(
                      () => _materials.removeWhere((x) => x.id == m.id),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tab,
        labelColor: _kPrimary,
        unselectedLabelColor: _kTextMuted,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        indicatorColor: _kPrimary,
        indicatorWeight: 2.5,
        tabs: const [
          Tab(text: 'About'),
          Tab(text: 'Classes'),
          Tab(text: 'Materials'),
        ],
      ),
    );
  }

  void _editClass(ClassItem c) {
    _showEditClassSheet(c);
  }

  Future<void> _deleteClass(ClassItem c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ConfirmDialog(
        title: 'Delete class',
        message: 'Delete "${c.title}"?',
        confirmLabel: 'Delete',
        confirmColor: _kRed,
      ),
    );
    if (confirm != true) return;

    try {
      final res = await TeacherApiService().deleteCourseClass(c.id.toString());
      if (res['status'] == true) {
        setState(() {
          _ongoing.removeWhere((x) => x.id == c.id);
          _completed.removeWhere((x) => x.id == c.id);
        });
        _snack('Class deleted');
      } else {
        _snack(res['message'] ?? 'Delete failed');
      }
    } catch (e) {
      _snack('Something went wrong');
    }
  }

  Future<void> _downloadMaterial(MaterialItem item) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final name = item.title
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(' ', '_');
      final ext =
          {'voice': 'mp3', 'image': 'jpg', 'pdf': 'pdf'}[item.fileType] ??
              item.fileType;
      final path = '${dir.path}/$name.$ext';
      await Dio().download(item.fileUrl, path);
      _snack('Downloaded: $name.$ext');
      await OpenFilex.open(path);
    } catch (e) {
      _snack('Download failed: $e');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showEditClassSheet(ClassItem cls) {
    final titleCtrl = TextEditingController(text: cls.title);
    final startDt = DateTime.tryParse(cls.timeStart ?? '');
    final endDt = DateTime.tryParse(cls.timeEnd ?? '');

    DateTime? selDate = startDt;
    TimeOfDay? selStart =
    startDt != null ? TimeOfDay.fromDateTime(startDt) : null;
    TimeOfDay? selEnd = endDt != null ? TimeOfDay.fromDateTime(endDt) : null;

    String? msg;
    bool isError = false;
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          Future<void> submit() async {
            if (titleCtrl.text.trim().isEmpty) {
              setM(() {
                msg = 'Enter class title';
                isError = true;
              });
              return;
            }
            if (selDate == null || selStart == null || selEnd == null) {
              setM(() {
                msg = 'Fill all date/time fields';
                isError = true;
              });
              return;
            }
            final startMins = selStart!.hour * 60 + selStart!.minute;
            final endMins = selEnd!.hour * 60 + selEnd!.minute;
            if (endMins <= startMins) {
              setM(() {
                msg = 'End time must be after start time';
                isError = true;
              });
              return;
            }
            final startFull = DateTime(
              selDate!.year,
              selDate!.month,
              selDate!.day,
              selStart!.hour,
              selStart!.minute,
            );
            final endFull = DateTime(
              selDate!.year,
              selDate!.month,
              selDate!.day,
              selEnd!.hour,
              selEnd!.minute,
            );
            setM(() => loading = true);
            try {
              final res = await TeacherApiService().updateCourseClass({
                'class_id': cls.id,
                'title': titleCtrl.text.trim(),
                'start_time': startFull.toIso8601String(),
                'end_time': endFull.toIso8601String(),
              });
              if (res['status'] == true) {
                setM(() {
                  msg = res['message'] ?? 'Class updated';
                  isError = false;
                  loading = false;
                });
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) {
                  Navigator.pop(ctx);
                  widget.onRefresh?.call(); // FIX: null-safe call
                }
              } else {
                setM(() {
                  msg = res['message'] ?? 'Update failed';
                  isError = true;
                  loading = false;
                });
              }
            } catch (_) {
              setM(() {
                msg = 'Something went wrong';
                isError = true;
                loading = false;
              });
            }
          }

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              left: 20,
              right: 20,
              top: 12,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Edit class',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _IconRoundBtn(
                        icon: Icons.close_rounded,
                        onTap: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (msg != null) _AlertBanner(message: msg!, isError: isError),

                  const SizedBox(height: 8),

                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Class title',
                      filled: true,
                      fillColor: _kPrimaryLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: _kPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _PickerTile(
                    icon: Icons.calendar_today_rounded,
                    label: 'Class date',
                    value: selDate == null
                        ? '--/--/----'
                        : DateFormat('dd MMM yyyy').format(selDate!),
                    onTap: () async {
                      final p = await showDatePicker(
                        context: ctx,
                        initialDate: selDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (p != null) setM(() => selDate = p);
                    },
                  ),
                  const SizedBox(height: 10),

                  _PickerTile(
                    icon: Icons.access_time_rounded,
                    label: 'Start time',
                    value: selStart?.format(ctx) ?? '--:-- AM/PM',
                    onTap: () async {
                      final p = await showTimePicker(
                        context: ctx,
                        initialTime: selStart ?? TimeOfDay.now(),
                      );
                      if (p != null) setM(() => selStart = p);
                    },
                  ),
                  const SizedBox(height: 10),

                  _PickerTile(
                    icon: Icons.access_time_filled_rounded,
                    label: 'End time',
                    value: selEnd?.format(ctx) ?? '--:-- AM/PM',
                    onTap: () async {
                      final p = await showTimePicker(
                        context: ctx,
                        initialTime: selEnd ?? TimeOfDay.now(),
                      );
                      if (p != null) setM(() => selEnd = p);
                    },
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: loading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Update class',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Banner
// ─────────────────────────────────────────────────────────────────────────────

class _CourseBanner extends StatelessWidget {
  final CourseInfo info;
  const _CourseBanner({required this.info});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: info.thumbnailUrl.isNotEmpty
              ? Image.network(
            info.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackBanner(),
          )
              : _fallbackBanner(),
        ),
        Container(
          height: 200,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xCC1A1A2E)],
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: _IconRoundBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            bg: Colors.black26,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          bottom: 14,
          left: 16,
          right: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (info.typeClass != null)
                _pill(
                  info.typeClass!,
                  bg: Colors.white24,
                  textColor: Colors.white,
                ),
              const SizedBox(height: 6),
              Text(
                info.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallbackBanner() => Container(
    color: _kPrimary,
    child: const Center(
      child: Icon(Icons.school_rounded, size: 60, color: Colors.white30),
    ),
  );

  Widget _pill(String text, {required Color bg, required Color textColor}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Meta bar
// ─────────────────────────────────────────────────────────────────────────────

class _CourseMetaBar extends StatelessWidget {
  final CourseInfo info;
  const _CourseMetaBar({required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (info.duration?.isNotEmpty == true)
              _MetaChip(icon: Icons.timer_outlined, label: info.duration!),
            if (info.mode?.isNotEmpty == true)
              _MetaChip(
                icon: Icons.live_tv_outlined,
                label: _cap(info.mode!),
              ),
            if (info.level?.isNotEmpty == true)
              _MetaChip(icon: Icons.grade_outlined, label: _cap(info.level!)),
            if (info.courseType?.isNotEmpty == true)
              _MetaChip(
                icon: Icons.auto_graph_outlined,
                label: _cap(info.courseType!),
              ),
          ],
        ),
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

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
  final Future<void> Function(ClassItem) onDeleteClass;
  final void Function(ClassItem) onEditClass;
  final VoidCallback? onRefresh; // FIX: nullable

  const _ClassesTab({
    required this.ongoing,
    required this.completed,
    required this.onDeleteClass,
    required this.onEditClass,
    this.onRefresh, // FIX: optional/nullable
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
                onDelete: widget.onDeleteClass,
                onEdit: widget.onEditClass,
                onRefresh: widget.onRefresh, // FIX: VoidCallback? → VoidCallback?
              ),
              _ClassList(
                classes: widget.completed,
                isCompleted: true,
                onDelete: widget.onDeleteClass,
                onEdit: widget.onEditClass,
                onRefresh: widget.onRefresh, // FIX: VoidCallback? → VoidCallback?
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
  final Future<void> Function(ClassItem) onDelete;
  final void Function(ClassItem) onEdit;
  final VoidCallback? onRefresh; // FIX: nullable

  const _ClassList({
    required this.classes,
    required this.isCompleted,
    required this.onDelete,
    required this.onEdit,
    this.onRefresh, // FIX: optional/nullable
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
          onAttendanceSaved: onRefresh, // FIX: VoidCallback? → VoidCallback?
          onDurationUpdated: onRefresh, // FIX: VoidCallback? → VoidCallback?
        )
            : _OngoingClassCard(
          cls: c,
          onEdit: () => onEdit(c),
          onDelete: () => onDelete(c),
        );
      },
    );
  }
}

// ─── Ongoing/Upcoming class card ──────────────────────────────────────────────

class _OngoingClassCard extends StatelessWidget {
  final ClassItem cls;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OngoingClassCard({
    required this.cls,
    required this.onEdit,
    required this.onDelete,
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
                _ActionBtn(
                  label: 'Edit',
                  icon: Icons.edit_rounded,
                  bgColor: Colors.white,
                  textColor: _kPrimary,
                  borderColor: _kPrimary,
                  onTap: onEdit,
                  compact: true,
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  bgColor: Colors.white,
                  textColor: _kRed,
                  borderColor: _kRed,
                  onTap: onDelete,
                  compact: true,
                ),
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
  final VoidCallback? onAttendanceSaved; // FIX: nullable
  final VoidCallback? onDurationUpdated; // FIX: nullable

  const _CompletedClassCard({
    required this.cls,
    this.onAttendanceSaved, // FIX: optional/nullable
    this.onDurationUpdated, // FIX: optional/nullable
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: _kSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Attendance',
                      style: TextStyle(fontSize: 11, color: _kTextMuted),
                    ),
                    Text(
                      cls.attendanceTaken
                          ? '${cls.presentCount}/${cls.totalStudents} present'
                          : 'Not taken yet',
                      style: TextStyle(
                        fontSize: 11,
                        color: cls.attendanceTaken ? _kText : _kAmber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: cls.attendanceTaken ? _pct / 100 : 0,
                    backgroundColor: _kBorder,
                    color: _pct >= 75
                        ? _kGreen
                        : _pct >= 50
                        ? Colors.orange
                        : _kRed,
                    minHeight: 6,
                  ),
                ),
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
                    label: cls.attendanceTaken
                        ? 'Edit attendance'
                        : 'Mark attendance',
                    icon: Icons.how_to_reg_outlined,
                    bgColor: cls.attendanceTaken ? Colors.white : _kPrimary,
                    textColor: cls.attendanceTaken ? _kPrimary : Colors.white,
                    borderColor: _kPrimary,
                    onTap: () => _openAttendance(context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ActionBtn(
                    label: 'Duration',
                    icon: Icons.timer_outlined,
                    bgColor: _kTealLight,
                    textColor: _kTeal,
                    borderColor: _kTeal,
                    onTap: () => _openDuration(context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _ActionBtn(
                    label: 'Watch',
                    icon: Icons.play_circle_outline_rounded,
                    bgColor: Colors.white,
                    textColor: _kTextMuted,
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

  void _openAttendance(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AttendanceSheet(
        classId: cls.id,
        classTitle: cls.title,
        classDate: cls.timeStart,
        onSaved: onAttendanceSaved, // FIX: VoidCallback? → VoidCallback?
      ),
    );
  }

  void _openDuration(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpdateDurationSheet(
        cls: cls,
        onUpdated: onDurationUpdated, // FIX: VoidCallback? → VoidCallback?
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
  final void Function(MaterialItem) onDeleted;

  const _MaterialsTab({
    required this.materials,
    required this.onDownload,
    required this.onDeleted,
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
        onDownload: () => onDownload(materials[i]),
        onDeleted: () => onDeleted(materials[i]),
      ),
    );
  }
}

class _MaterialCard extends StatefulWidget {
  final MaterialItem material;
  final VoidCallback onDownload;
  final VoidCallback onDeleted;

  const _MaterialCard({
    required this.material,
    required this.onDownload,
    required this.onDeleted,
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

  void _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Delete material',
        message: 'Delete "${widget.material.title}"?',
        confirmLabel: 'Delete',
        confirmColor: _kRed,
      ),
    );
    if (confirm != true) return;

    try {
      final res = await TeacherApiService()
          .deleteCourseMaterial(widget.material.id.toString());
      if (res['status'] == true) {
        widget.onDeleted();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Delete failed')),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong')),
        );
      }
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
              const SizedBox(width: 6),
              _IconRoundBtn(
                icon: Icons.delete_outline_rounded,
                color: _kRed,
                onTap: _confirmDelete,
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


class CourseDetailsResponse {
  final bool status;
  final String message;
  final CourseDetails data;

  CourseDetailsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CourseDetailsResponse.fromJson(Map<String, dynamic> json) =>
      CourseDetailsResponse(
        status: json['status'] ?? false,
        message: json['message'] ?? '',
        data: CourseDetails.fromJson(json['data'] ?? {}),
      );
}


class InstructorItem {
  final int id;
  final String name;
  final String? avatar;
  final String? specialization;

  InstructorItem({
    required this.id,
    required this.name,
    this.avatar,
    this.specialization,
  });

  factory InstructorItem.fromJson(Map<String, dynamic> json) => InstructorItem(
    id: json['id'] ?? 0,
    name: json['name'] ?? 'Unknown',
    avatar: json['avatar'],
    specialization: json['specialization'],
  );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}