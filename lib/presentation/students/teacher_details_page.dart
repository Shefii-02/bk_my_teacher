import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/endpoints.dart';
import '../../services/api_service.dart';
import '../../services/launch_status_service.dart';
import '../widgets/show_failed_alert.dart';
import '../widgets/show_success_alert.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────
const _kPrimary    = Color(0xFF1D9E75);
const _kPrimaryDk  = Color(0xFF085041);
const _kPrimaryLt  = Color(0xFFE1F5EE);
const _kPrimaryMid = Color(0xFF9FE1CB);
const _kPurple     = Color(0xFF534AB7);
const _kPurpleLt   = Color(0xFFEEEDFE);
const _kCoral      = Color(0xFF993C1D);
const _kCoralLt    = Color(0xFFFAECE7);
const _kAmber      = Color(0xFF633806);
const _kAmberLt    = Color(0xFFFAEEDA);
const _kBorder     = Color(0xFFEEEEEE);
const _kSurface    = Color(0xFFF8F8FC);
const _kText       = Color(0xFF1A1A2E);
const _kMuted      = Color(0xFF9E9E9E);
const _kRed        = Color(0xFFE53935);
const _kStar       = Color(0xFFF59E0B);

// ─────────────────────────────────────────────────────────────────────────────
// Teacher Details Page
// ─────────────────────────────────────────────────────────────────────────────

class TeacherDetailsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> teacher;
  const TeacherDetailsPage({super.key, required this.teacher});

  @override
  ConsumerState<TeacherDetailsPage> createState() => _TeacherDetailsPageState();
}

class _TeacherDetailsPageState extends ConsumerState<TeacherDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late Map<String, dynamic> _teacher;

  // Share card repaint boundary key
  final GlobalKey _shareKey = GlobalKey();

  // Booking form state
  String _bookType       = 'subject';
  List<String> _selItems = [];
  String _classType      = 'Individual';
  final _daysCtrl        = TextEditingController();
  final _notesCtrl       = TextEditingController();
  bool _submitting       = false;

  @override
  void initState() {
    super.initState();
    _tab     = TabController(length: 3, vsync: this);
    _teacher = widget.teacher;
  }

  @override
  void dispose() {
    _tab.dispose();
    _daysCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  List<String> _asList(dynamic v) {
    if (v == null) return [];
    if (v is List) return v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    if (v is String) return v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    return [];
  }

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  double get _rating => (_teacher['rating'] ?? 4.0).toDouble();
  int get _ratingRound => _rating.round().clamp(0, 5);

  // ── share ──────────────────────────────────────────────────────────────────

  Future<void> _share() async {
    try {
      // capture the share card widget
      final boundary = _shareKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();

      final dir  = await getTemporaryDirectory();
      final file = File('${dir.path}/teacher_share.png');
      await file.writeAsBytes(bytes);

      final refCode = await LaunchStatusService.getReferralCode();
      final url     = '${Endpoints.domain}/invite?ref=$refCode';
      final name    = _teacher['name'] ?? 'this teacher';

      final msg = '📚 Check out $name on BookMyTeacher!\n\n'
          '✅ 500+ Verified Teachers\n'
          '✅ Live & Recorded Classes\n'
          '✅ Free Demo Available\n'
          '✅ Career & Counselling Support\n\n'
          '🎁 Use my referral code *$refCode* and earn rewards!\n'
          '👉 $url';

      await Share.shareXFiles([XFile(file.path)], text: msg);
    } catch (e) {
      debugPrint('Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }

  // ── booking ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (_selItems.isEmpty) {
      showFailedAlert(context,
          title: 'Validation',
          subtitle: 'Please select at least one item',
          timer: 4,
          color: _kRed,
          showButton: false);
      return;
    }
    if (_daysCtrl.text.trim().isEmpty) {
      showFailedAlert(context,
          title: 'Validation',
          subtitle: 'Please enter number of days',
          timer: 4,
          color: _kRed,
          showButton: false);
      return;
    }

    setState(() => _submitting = true);
    try {
      final res = await ApiService().submitTeacherClassRequest({
        'teacher_id'    : _teacher['id'],
        'type'          : _bookType,
        'selected_items': _selItems,
        'class_type'    : _classType.toLowerCase(),
        'days_needed'   : _daysCtrl.text.trim(),
        'notes'         : _notesCtrl.text.trim(),
      });
      if (context.mounted) Navigator.of(context).pop();
      showSuccessAlert(context,
          title   : res?['status'] == true ? 'Success!' : 'Failed',
          subtitle: res?['message'] ?? 'Booking submitted',
          timer   : 4,
          color   : res?['status'] == true ? _kPrimary : _kRed,
          showButton: false);
      if (res?['status'] == true) {
        setState(() {
          _daysCtrl.clear();
          _notesCtrl.clear();
          _selItems.clear();
          _bookType  = 'subject';
          _classType = 'Individual';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showBookingSheet() {
    final subjects = _asList(_teacher['subjects']);
    final courses  = _asList(_teacher['courses']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _BookingSheet(
        subjects    : subjects,
        courses     : courses,
        bookType    : _bookType,
        selItems    : _selItems,
        classType   : _classType,
        daysCtrl    : _daysCtrl,
        notesCtrl   : _notesCtrl,
        submitting  : _submitting,
        onTypeChange: (v) => setState(() { _bookType = v; _selItems.clear(); }),
        onItemToggle: (item, add) => setState(() =>
        add ? _selItems.add(item) : _selItems.remove(item)),
        onClassType : (v) => setState(() => _classType = v),
        onSubmit    : _submit,
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _kSurface,

      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          _HeroSection(
            teacher : _teacher,
            initials: _initials(_teacher['name']),
            onBack  : () => Navigator.pop(context),
            onShare : _share,
            shareKey: _shareKey,
          ),
          _ProfileInfo(
            teacher     : _teacher,
            rating      : _rating,
            ratingRound : _ratingRound,
          ),
          _tabBar(),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _AboutTab(teacher: _teacher, asList: _asList),
                _CoursesTab(teacher: _teacher),
                _ReviewsTab(
                  teacher: _teacher,
                  rating : _rating,
                ),
              ],
            ),
          ),
          _BottomBar(
            onBook : _showBookingSheet,
            onShare: _share,
          ),
        ],
      ),
    );
  }

  Widget _tabBar() => Container(
    color: Theme.of(context).colorScheme.surface,
    child: TabBar(
      controller       : _tab,
      labelColor       : _kPrimary,
      unselectedLabelColor: _kMuted,
      labelStyle       : const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      indicatorColor   : _kPrimary,
      indicatorWeight  : 2.5,
      tabs             : const [
        Tab(text: 'About'),
        Tab(text: 'Courses'),
        Tab(text: 'Reviews'),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final String initials;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final GlobalKey shareKey;

  const _HeroSection({
    required this.teacher,
    required this.initials,
    required this.onBack,
    required this.onShare,
    required this.shareKey,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        // off-screen share card (captured for image share)
        RepaintBoundary(
          key: shareKey,
          child: _ShareCard(teacher: teacher, initials: initials),
        ),

        // Hero background
        Container(
          height: 220 + top,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_kPrimary, _kPrimaryDk],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // dot pattern
              Positioned.fill(
                child: CustomPaint(painter: _DotPatternPainter()),
              ),
              // teacher image or initials avatar
    Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 0),
                            child: Image.network(
                              teacher['imageUrl'] ??
                                  "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                              fit: BoxFit.cover,
                              height: 280,
                            ),
                          ),
                        ),
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: Center(
              //     child: teacher['imageUrl'] != null &&
              //         (teacher['imageUrl'] as String).isNotEmpty
              //         ? ClipOval(
              //       child: Image.network(
              //         teacher['imageUrl'],
              //         width: 90,
              //         height: 90,
              //         fit: BoxFit.cover,
              //         errorBuilder: (_, __, ___) =>
              //             _AvatarCircle(initials: initials, size: 90),
              //       ),
              //     )
              //         : _AvatarCircle(initials: initials, size: 90),
              //   ),
              // ),
            ],
          ),
        ),

        // Back button
        Positioned(
          top: top + 8,
          left: 12,
          child: _HeroBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        ),
        // Share button
        Positioned(
          top: top + 8,
          right: 12,
          child: _HeroBtn(icon: Icons.share_outlined, onTap: onShare),
        ),
      ],
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.07);
    for (double x = 0; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _AvatarCircle extends StatelessWidget {
  final String initials;
  final double size;
  const _AvatarCircle({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.2),
      border: Border.all(color: Colors.white, width: 3),
    ),
    alignment: Alignment.center,
    child: Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: size * 0.33,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

class _HeroBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeroBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Profile Info (name + stars + stats)
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileInfo extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final double rating;
  final int ratingRound;

  const _ProfileInfo({
    required this.teacher,
    required this.rating,
    required this.ratingRound,
  });

  @override
  Widget build(BuildContext context) {
    final reviews  = (teacher['reviews'] as List?)?.length ?? 0;
    final students = teacher['student_count'] ?? teacher['students'] ?? 0;
    final ranking  = teacher['ranking'] ?? '-';
    final courses  = (teacher['courses'] as List?)?.length ?? 0;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Column(
        children: [
          Text(
            teacher['name'] ?? 'Teacher',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            teacher['qualification']?.toString() ?? '',
            style: const TextStyle(fontSize: 12, color: _kMuted),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (i) => Icon(
                Icons.star_rounded,
                size: 18,
                color: i < ratingRound ? _kStar : _kBorder,
              )),
              const SizedBox(width: 6),
              Text(
                '${rating.toStringAsFixed(1)} · $reviews reviews',
                style: const TextStyle(fontSize: 12, color: _kMuted),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatBox(value: '$students', label: 'Students'),
              const SizedBox(width: 10),
              _StatBox(value: '#$ranking', label: 'Ranking'),
              const SizedBox(width: 10),
              _StatBox(value: '$courses', label: 'Courses'),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600, color: _kText)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 10, color: _kMuted)),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// ABOUT TAB
// ─────────────────────────────────────────────────────────────────────────────

class _AboutTab extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final List<String> Function(dynamic) asList;

  const _AboutTab({required this.teacher, required this.asList});

  @override
  Widget build(BuildContext context) {
    final subjects = asList(teacher['subjects']);
    final desc     = teacher['description']?.toString() ?? '';

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        if (desc.isNotEmpty) ...[
          _SecLabel('ABOUT TEACHER'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Html(
              data: desc,
              style: {
                'body': Style(
                  fontSize: FontSize(13),
                  lineHeight: LineHeight(1.6),
                  color: Colors.black87,
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              },
            ),
          ),
          const SizedBox(height: 18),
        ],

        if (subjects.isNotEmpty) ...[
          _SecLabel('SUBJECTS'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: subjects
                .map((s) => _SubjectChip(label: s))
                .toList(),
          ),
          const SizedBox(height: 18),
        ],

        _SecLabel('DETAILS'),
        const SizedBox(height: 8),
        _DetailTable(rows: [
          _DetailRow('Qualification', teacher['qualification']?.toString()),
          _DetailRow('Ranking',       '#${teacher['ranking'] ?? '-'}'),
          _DetailRow('Mode',          teacher['mode']?.toString()),
          _DetailRow('Location',      teacher['location']?.toString()),
          _DetailRow('Languages',     teacher['languages']?.toString()),
          _DetailRow('Experience',    teacher['experience']?.toString()),
          _DetailRow('Rating',
              '${(teacher['rating'] ?? 0.0).toStringAsFixed(1)} ⭐'),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _SecLabel extends StatelessWidget {
  final String text;
  const _SecLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: _kMuted,
      letterSpacing: 0.6,
    ),
  );
}

class _SubjectChip extends StatelessWidget {
  final String label;
  const _SubjectChip({required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: _kPrimaryLt,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kPrimaryMid),
    ),
    child: Text(
      label,
      style: const TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: _kPrimaryDk),
    ),
  );
}

class _DetailRow {
  final String label;
  final String? value;
  const _DetailRow(this.label, this.value);
}

class _DetailTable extends StatelessWidget {
  final List<_DetailRow> rows;
  const _DetailTable({required this.rows});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _kBorder),
    ),
    child: Column(
      children: rows
          .where((r) => r.value != null && r.value!.isNotEmpty)
          .toList()
          .asMap()
          .entries
          .map((entry) {
        final isLast = entry.key ==
            rows
                .where((r) => r.value != null && r.value!.isNotEmpty)
                .length - 1;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(
                bottom: BorderSide(color: _kBorder, width: 0.5)),
          ),
          child: Row(
            children: [
              Text(entry.value.label,
                  style: const TextStyle(fontSize: 13, color: _kMuted)),
              const Spacer(),
              Text(entry.value.value ?? '',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _kText)),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// COURSES TAB
// ─────────────────────────────────────────────────────────────────────────────

class _CoursesTab extends StatelessWidget {
  final Map<String, dynamic> teacher;
  const _CoursesTab({required this.teacher});

  @override
  Widget build(BuildContext context) {
    final courses = (teacher['courses_list'] as List<dynamic>?) ?? [];

    if (courses.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school_outlined, size: 48, color: _kMuted),
            SizedBox(height: 12),
            Text('No courses available',
                style: TextStyle(color: _kMuted)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: courses.length,
      itemBuilder: (ctx, i) => _CourseCard(course: courses[i]),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const _CourseCard({required this.course});

  Color get _gradientStart {
    final type = (course['type_class'] ?? '').toString().toLowerCase();
    if (type == 'recorded') return _kPurple;
    if (type == 'crash') return _kCoral;
    return _kPrimary;
  }

  Color get _gradientEnd {
    final type = (course['type_class'] ?? '').toString().toLowerCase();
    if (type == 'recorded') return const Color(0xFF3C3489);
    if (type == 'crash') return const Color(0xFF712B13);
    return _kPrimaryDk;
  }

  Color get _levelBg {
    final l = (course['level'] ?? '').toString().toLowerCase();
    if (l == 'intermediate') return _kAmberLt;
    if (l == 'advanced') return _kCoralLt;
    return _kPrimaryLt;
  }

  Color get _levelFg {
    final l = (course['level'] ?? '').toString().toLowerCase();
    if (l == 'intermediate') return _kAmber;
    if (l == 'advanced') return _kCoral;
    return _kPrimaryDk;
  }

  @override
  Widget build(BuildContext context) {
    final type     = (course['type_class'] ?? 'live').toString().toUpperCase();
    final level    = _cap(course['level']?.toString() ?? '');
    final duration = course['duration']?.toString() ?? '';
    final students = course['student_count'] ?? course['students'] ?? 0;
    final title    = course['title'] ?? 'Untitled';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // thumbnail
          Container(
            height: 90,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_gradientStart, _gradientEnd],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    type == 'RECORDED'
                        ? Icons.play_circle_outline_rounded
                        : Icons.sensors_rounded,
                    size: 36,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // body
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _kText),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (duration.isNotEmpty)
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: duration,
                      ),
                    _MetaChip(
                      icon: Icons.people_outline_rounded,
                      label: '$students students',
                    ),
                    if (level.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _levelBg,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          level,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _levelFg),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _kBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _kMuted),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: _kMuted)),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// REVIEWS TAB
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewsTab extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final double rating;

  const _ReviewsTab({required this.teacher, required this.rating});

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = (teacher['reviews'] as List<dynamic>?) ?? [];

    // compute bar distribution
    final Map<int, int> dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      final s = ((r['rating'] ?? 0) as num).round().clamp(1, 5);
      dist[s] = (dist[s] ?? 0) + 1;
    }
    final total = reviews.length;

    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        // Rating summary card
        if (reviews.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                // big number
                Column(
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: _kText,
                          height: 1),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(Icons.star_rounded,
                            size: 14,
                            color: i < rating.round() ? _kStar : _kBorder),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('$total reviews',
                        style:
                        const TextStyle(fontSize: 10, color: _kMuted)),
                  ],
                ),
                const SizedBox(width: 20),
                // bars
                Expanded(
                  child: Column(
                    children: [5, 4, 3, 2, 1].map((star) {
                      final count = dist[star] ?? 0;
                      final pct = total > 0 ? count / total : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 5),
                        child: Row(
                          children: [
                            Text('$star',
                                style: const TextStyle(
                                    fontSize: 10, color: _kMuted)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: pct,
                                  minHeight: 5,
                                  backgroundColor: _kBorder,
                                  valueColor:
                                  const AlwaysStoppedAnimation(_kStar),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            SizedBox(
                              width: 20,
                              child: Text('$count',
                                  style: const TextStyle(
                                      fontSize: 10, color: _kMuted),
                                  textAlign: TextAlign.right),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Review cards
        if (reviews.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No reviews yet',
                  style: TextStyle(color: _kMuted)),
            ),
          )
        else
          ...reviews.map((r) {
            final name   = r['name']?.toString() ?? 'Student';
            final stars  = ((r['rating'] ?? 0) as num).round().clamp(0, 5);
            final comment = r['comment']?.toString() ?? '';
            final date   = r['date']?.toString() ?? r['created_at']?.toString() ?? '';
            final avatar = r['avatar']?.toString() ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // avatar
                      avatar.isNotEmpty
                          ? ClipOval(
                        child: Image.network(
                          avatar,
                          width: 38,
                          height: 38,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _ReviewAvatar(initials: _initials(name)),
                        ),
                      )
                          : _ReviewAvatar(initials: _initials(name)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _kText)),
                            if (date.isNotEmpty)
                              Text(date,
                                  style: const TextStyle(
                                      fontSize: 10, color: _kMuted)),
                          ],
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(Icons.star_rounded,
                              size: 13,
                              color: i < stars ? _kStar : _kBorder),
                        ),
                      ),
                    ],
                  ),
                  if (comment.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(comment,
                        style: const TextStyle(
                            fontSize: 12,
                            color: _kMuted,
                            height: 1.5)),
                  ],
                ],
              ),
            );
          }).toList(),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ReviewAvatar extends StatelessWidget {
  final String initials;
  const _ReviewAvatar({required this.initials});

  static const _colors = [
    [Color(0xFFE1F5EE), Color(0xFF085041)],
    [Color(0xFFEEEDFE), Color(0xFF3C3489)],
    [Color(0xFFFAEEDA), Color(0xFF633806)],
    [Color(0xFFFAECE7), Color(0xFF993C1D)],
  ];

  @override
  Widget build(BuildContext context) {
    final idx = initials.isNotEmpty ? initials.codeUnitAt(0) % _colors.length : 0;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _colors[idx][0],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(initials,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: _colors[idx][1])),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final VoidCallback onBook;
  final VoidCallback onShare;
  const _BottomBar({required this.onBook, required this.onShare});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    decoration:  BoxDecoration(
      color:
       Theme.of(context).colorScheme.surfaceBright,
      border: Border(top: BorderSide(color: _kBorder, width: 0.5)),
    ),
    child: Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onBook,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: _kPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Book demo / class',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onShare,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: _kBorder),
              borderRadius: BorderRadius.circular(14),
              color: _kSurface,
            ),
            child: const Icon(Icons.share_outlined, color: _kText, size: 20),
          ),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Share Card Widget (rendered off-screen, captured as image)
// ─────────────────────────────────────────────────────────────────────────────

class _ShareCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final String initials;

  const _ShareCard({required this.teacher, required this.initials});

  @override
  Widget build(BuildContext context) {
    // positioned off-screen so it renders but isn't visible
    return Positioned(
      left: -9999,
      top: -9999,
      child: Material(
        child: SizedBox(
          width: 360,
          child: _ShareCardContent(teacher: teacher, initials: initials),
        ),
      ),
    );
  }
}

class _ShareCardContent extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final String initials;
  const _ShareCardContent(
      {required this.teacher, required this.initials});

  @override
  Widget build(BuildContext context) {
    final name   = teacher['name'] ?? 'Teacher';
    final qual   = teacher['qualification']?.toString() ?? '';
    final rating = (teacher['rating'] ?? 0.0).toDouble();
    final stars  = rating.round().clamp(0, 5);
    final reviews = (teacher['reviews'] as List?)?.length ?? 0;
    final subjects = _subjectStr();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header — teacher profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_kPrimary, _kPrimaryDk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                if (qual.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(qual,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.8), fontSize: 12)),
                ],
                if (subjects.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(subjects,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.7), fontSize: 11)),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      5,
                          (i) => Icon(Icons.star_rounded,
                          size: 16,
                          color: i < stars
                              ? _kStar
                              : Colors.white.withOpacity(0.3)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${rating.toStringAsFixed(1)} · $reviews reviews',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // App features
          // Padding(
          //   padding: const EdgeInsets.all(16),
          //   child: Column(
          //     children: [
          //       const Text(
          //         'WHY BOOKMYTEACHER?',
          //         style: TextStyle(
          //             fontSize: 10,
          //             fontWeight: FontWeight.w700,
          //             color: _kMuted,
          //             letterSpacing: 0.6),
          //       ),
          //       const SizedBox(height: 12),
          //       Row(
          //         children: const [
          //           Expanded(child: _FeatureStat(value: '500+', label: 'Verified Teachers')),
          //           SizedBox(width: 8),
          //           Expanded(child: _FeatureStat(value: '10k+', label: 'Happy Students')),
          //         ],
          //       ),
          //       const SizedBox(height: 8),
          //       Row(
          //         children: const [
          //           Expanded(child: _FeatureStat(value: 'Live', label: '& Recorded Classes')),
          //           SizedBox(width: 8),
          //           Expanded(child: _FeatureStat(value: 'Free', label: 'Demo Available')),
          //         ],
          //       ),
          //       const SizedBox(height: 14),
          //
          //       // Referral code block — loaded async, so we pass a placeholder here
          //       // The actual code is embedded at share time via the text message
          //       FutureBuilder<String>(
          //         future: LaunchStatusService.getReferralCode(),
          //         builder: (ctx, snap) {
          //           final code = snap.data ?? '--------';
          //           return Container(
          //             width: double.infinity,
          //             padding: const EdgeInsets.all(14),
          //             decoration: BoxDecoration(
          //               color: _kPrimaryLt,
          //               borderRadius: BorderRadius.circular(14),
          //               border: Border.all(color: _kPrimaryMid),
          //             ),
          //             child: Column(
          //               children: [
          //                 const Text(
          //                   'Use referral code to get rewards',
          //                   style: TextStyle(fontSize: 11, color: _kPrimaryDk),
          //                 ),
          //                 const SizedBox(height: 6),
          //                 Text(
          //                   code,
          //                   style: const TextStyle(
          //                       fontSize: 22,
          //                       fontWeight: FontWeight.bold,
          //                       color: _kPrimaryDk,
          //                       letterSpacing: 3),
          //                 ),
          //                 const SizedBox(height: 4),
          //                 Text(
          //                   '${Endpoints.domain}/invite?ref=$code',
          //                   style: const TextStyle(
          //                       fontSize: 10, color: _kPrimary),
          //                 ),
          //               ],
          //             ),
          //           );
          //         },
          //       ),
          //       const SizedBox(height: 14),
          //
          //       // Download CTA
          //       Container(
          //         width: double.infinity,
          //         padding: const EdgeInsets.symmetric(vertical: 13),
          //         decoration: BoxDecoration(
          //           color: _kPrimary,
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         alignment: Alignment.center,
          //         child: const Text(
          //           'Download BookMyTeacher App',
          //           style: TextStyle(
          //               color: Colors.white,
          //               fontWeight: FontWeight.w600,
          //               fontSize: 13),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  String _subjectStr() {
    final v = teacher['subjects'];
    if (v == null) return '';
    if (v is List) return v.take(3).join(', ');
    if (v is String) {
      return v.split(',').take(3).map((s) => s.trim()).join(', ');
    }
    return '';
  }
}

class _FeatureStat extends StatelessWidget {
  final String value;
  final String label;
  const _FeatureStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(
      color: _kSurface,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: _kPrimary)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 10, color: _kMuted),
            textAlign: TextAlign.center),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  final List<String> subjects;
  final List<String> courses;
  final String bookType;
  final List<String> selItems;
  final String classType;
  final TextEditingController daysCtrl;
  final TextEditingController notesCtrl;
  final bool submitting;
  final void Function(String) onTypeChange;
  final void Function(String, bool) onItemToggle;
  final void Function(String) onClassType;
  final VoidCallback onSubmit;

  const _BookingSheet({
    required this.subjects,
    required this.courses,
    required this.bookType,
    required this.selItems,
    required this.classType,
    required this.daysCtrl,
    required this.notesCtrl,
    required this.submitting,
    required this.onTypeChange,
    required this.onItemToggle,
    required this.onClassType,
    required this.onSubmit,
  });

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  late String _type;
  late String _classType;
  late List<String> _selItems;

  @override
  void initState() {
    super.initState();
    _type      = widget.bookType;
    _classType = widget.classType;
    _selItems  = List.from(widget.selItems);
  }

  List<String> get _currentList =>
      _type == 'subject' ? widget.subjects : widget.courses;

  void _setType(String t) {
    setState(() { _type = t; _selItems.clear(); });
    widget.onTypeChange(t);
  }

  void _toggleItem(String item, bool add) {
    setState(() {
      if (add) { if (!_selItems.contains(item)) _selItems.add(item); }
      else { _selItems.remove(item); }
    });
    widget.onItemToggle(item, add);
  }

  void _setClassType(String t) {
    setState(() => _classType = t);
    widget.onClassType(t);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceBright,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 20,
        right: 20,
        top: 12,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // drag handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(

                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // title
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimaryLt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:  Icon(Icons.calendar_month_outlined,
                      color: Theme.of(context).colorScheme.surface, size: 18),
                ),
                const SizedBox(width: 12),
                 Text('Book a class',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kBorder),
                    ),
                    child:  Icon(Icons.close_rounded,color: Theme.of(context).colorScheme.surface, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // type toggle
            _SheetLabel('BOOKING TYPE'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _kSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBorder),
              ),
              child: Row(
                children: ['subject', 'course'].map((t) {
                  final active = _type == t;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _setType(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: active ? Theme.of(context).colorScheme.surface: Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: active
                              ? Border.all(color: _kBorder)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          t == 'subject' ? 'Subject' : 'Course',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: active ? _kPrimary : _kMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // item chips
            _SheetLabel(
              _type == 'subject' ? 'SELECT SUBJECT(S)' : 'SELECT COURSE(S)',
            ),
            const SizedBox(height: 8),
            if (_currentList.isEmpty)
              const Text('No items available',
                  style: TextStyle(color: _kMuted, fontSize: 13))
            else
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: _currentList.map((item) {
                  final sel = _selItems.contains(item);
                  return GestureDetector(
                    onTap: () => _toggleItem(item, !sel),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? _kPrimaryLt : _kSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? _kPrimaryMid : _kBorder,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (sel) ...[
                            const Icon(Icons.check_rounded,
                                size: 12, color: _kPrimaryDk),
                            const SizedBox(width: 4),
                          ],
                          Text(item,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: sel ? _kPrimaryDk : _kMuted,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),

            // class type
            _SheetLabel('CLASS TYPE'),
            const SizedBox(height: 8),
            Row(
              children: ['Individual', 'Common', 'Crash'].map((t) {
                final active = _classType == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _setClassType(t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: active ? _kPrimaryLt : _kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? _kPrimaryMid : _kBorder,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        t,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: active ? _kPrimaryDk : _kMuted,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // days
            _SheetLabel('NUMBER OF DAYS'),
            const SizedBox(height: 8),
            TextField(
              controller: widget.daysCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g. 30',
                filled: true,
                fillColor: _kSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPrimary),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),

            // notes
            _SheetLabel('NOTES (OPTIONAL)'),
            const SizedBox(height: 8),
            TextField(
              controller: widget.notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Any specific requirements...',
                filled: true,
                fillColor: _kSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _kPrimary),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // submit
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: widget.submitting ? null : widget.onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: widget.submitting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Submit booking',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: _kMuted,
        letterSpacing: 0.6),
  );
}




// ─────────────────────────────────────────────────────────────────────────────
// LARAVEL RESPONSE FORMAT EXPECTED
// ─────────────────────────────────────────────────────────────────────────────
//
// GET /api/teacher/{id}
//
// {
//   "status": true,
//   "message": "Teacher fetched",
//   "data": {
//     "id": 1,
//     "name": "Dr. Ramesh Kumar",
//     "imageUrl": "https://...",
//     "description": "<p>About the teacher...</p>",
//     "qualification": "M.Sc, B.Ed",
//     "location": "Tirur, Kerala",
//     "mode": "Online & Offline",
//     "languages": "Malayalam, English",
//     "experience": "12 years",
//     "rating": 4.2,
//     "ranking": 3,
//     "student_count": 340,
//     "subjects": ["Calculus", "Algebra", "Statistics"],
//                  -- OR -- "subjects": "Calculus, Algebra, Statistics"
//     "courses": ["Advanced Maths", "Calculus Crash"],
//                  -- OR -- "courses": "Advanced Maths, Calculus Crash"
//     "courses_list": [
//       {
//         "id": 1,
//         "title": "Advanced Mathematics & Problem Solving",
//         "thumbnail_url": "https://...",
//         "type_class": "live",
//         "level": "beginner",
//         "duration": "6 months",
//         "student_count": 42,
//         "mode": "online"
//       }
//     ],
//     "reviews": [
//       {
//         "id": 1,
//         "name": "Arjun Nair",
//         "avatar": "https://...",
//         "rating": 5,
//         "comment": "Brilliant teacher...",
//         "date": "March 2025"
//       }
//     ]
//   }
// }