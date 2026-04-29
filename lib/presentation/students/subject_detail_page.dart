// ─── subject_detail_page.dart ─────────────────────────────────────────────────
// Redesigned Subject Detail Page
// Sections: Hero | About | Teacher Grid | Reviews | Booking Sheet

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/endpoints.dart';
import '../../services/api_service.dart';
import '../../services/launch_status_service.dart';
import '../students/teacher_details_page.dart';
import '../widgets/show_failed_alert.dart';
import '../widgets/show_success_alert.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────
const _kPrimary = Color(0xFF1D9E75);
const _kPrimaryDk = Color(0xFF085041);
const _kPrimaryLt = Color(0xFFE1F5EE);
const _kPrimaryMd = Color(0xFF9FE1CB);
const _kBorder = Color(0xFFEEEEEE);
const _kSurface = Color(0xFFF8F8FC);
const _kText = Color(0xFF1A1A2E);
const _kMuted = Color(0xFF9E9E9E);
const _kStar = Color(0xFFF59E0B);
const _kRed = Color(0xFFE53935);

// gradient palettes per teacher card index
const _kCardGradients = [
  [Color(0xFF1D9E75), Color(0xFF085041)],
  [Color(0xFF534AB7), Color(0xFF3C3489)],
  [Color(0xFF993C1D), Color(0xFF712B13)],
  [Color(0xFF633806), Color(0xFF4A2904)],
  [Color(0xFF1565C0), Color(0xFF0D3D73)],
  [Color(0xFF6A1B9A), Color(0xFF4A1470)],
];

// ─────────────────────────────────────────────────────────────────────────────
// Subject Detail Page
// ─────────────────────────────────────────────────────────────────────────────

class SubjectDetailPage extends StatefulWidget {
  final Map<String, dynamic> subject;
  const SubjectDetailPage({super.key, required this.subject});

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage> {
  final GlobalKey _shareKey = GlobalKey();

  // ── helpers ────────────────────────────────────────────────────────────────

  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name[0].toUpperCase();
  }

  // ── share ──────────────────────────────────────────────────────────────────

  Future<void> _share() async {
    try {
      final boundary =
          _shareKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      String? imagePath;

      if (boundary != null) {
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final bytes = byteData.buffer.asUint8List();
          final dir = await getTemporaryDirectory();
          final file = File('${dir.path}/subject_share.png');
          await file.writeAsBytes(bytes);
          imagePath = file.path;
        }
      }

      final refCode = await LaunchStatusService.getReferralCode();
      final url = '${Endpoints.domain}/invite?ref=$refCode';
      final name = widget.subject['name'] ?? 'this subject';

      final msg =
          '📚 Explore $name on BookMyTeacher!\n\n'
          '✅ 500+ Verified Teachers\n'
          '✅ Live & Recorded Classes\n'
          '✅ Free Demo Available\n'
          '✅ Career & Counselling Support\n\n'
          '🎁 Use my referral code *$refCode* and earn rewards!\n'
          '👉 $url';

      if (imagePath != null) {
        await Share.shareXFiles([XFile(imagePath)], text: msg);
      } else {
        await Share.share(msg);
      }
    } catch (e) {
      debugPrint('Share error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }

  // ── booking sheet ──────────────────────────────────────────────────────────

  void _openBookingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingSheet(subject: widget.subject),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final teachers = (subject['available_teachers'] as List<dynamic>?) ?? [];
    final reviews = (subject['reviews'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: _kSurface,
      body: Column(
        children: [
          // Hero
          _HeroSection(
            subject: subject,
            shareKey: _shareKey,
            onBack: () => Navigator.pop(context),
            onShare: _share,
          ),

          // Scrollable body
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [_bodyContent(subject, teachers, reviews)],
            ),
          ),

          // Bottom bar
          _BottomBar(onBook: _openBookingSheet, onShare: _share),
        ],
      ),
    );
  }

  Widget _bodyContent(
    Map<String, dynamic> subject,
    List<dynamic> teachers,
    List<dynamic> reviews,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // About
          if (subject['description'] != null &&
              (subject['description'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SecLabel('ABOUT THIS SUBJECT'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Html(
                      data: subject['description'],
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
                ],
              ),
            ),

          // Teachers
          if (teachers.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
              child: Row(
                children: [
                  const Text(
                    'Available Teachers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kText,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _kPrimaryLt,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${teachers.length} available',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _kPrimaryDk,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: teachers.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (ctx, i) {
                  final t = teachers[i] as Map<String, dynamic>;
                  return _TeacherCard(
                    teacher: t,
                    index: i,
                    initials: _initials(t['name']),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TeacherDetailsPage(teacher: t),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No teachers available for this subject',
                  style: TextStyle(color: _kMuted),
                ),
              ),
            ),

          // Reviews
          if (reviews.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: Divider(height: 1, color: _kBorder),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student Reviews',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _kText,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...reviews.map(
                    (r) => _ReviewCard(
                      review: r as Map<String, dynamic>,
                      initials: _initials(r['name']),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Section
// ─────────────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final Map<String, dynamic> subject;
  final GlobalKey shareKey;
  final VoidCallback onBack;
  final VoidCallback onShare;

  const _HeroSection({
    required this.subject,
    required this.shareKey,
    required this.onBack,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final name = subject['name'] ?? 'Subject';
    final trending = subject['trending'];
    final teachers = (subject['available_teachers'] as List?)?.length ?? 0;
    final icon = subject['icon'] ?? '📚';

    return RepaintBoundary(
      key: shareKey,
      child: Container(
        height: 180 + top,
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
            Positioned.fill(child: CustomPaint(painter: _DotPainter())),

            // back button
            Positioned(
              top: top + 8,
              left: 12,
              child: _HeroBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack,
              ),
            ),

            // share button
            Positioned(
              top: top + 8,
              right: 12,
              child: _HeroBtn(icon: Icons.share_outlined, onTap: onShare),
            ),

            // center content
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // subject icon circle
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(icon, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (trending != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Trending #$trending',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '$teachers teacher${teachers != 1 ? 's' : ''} available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white.withOpacity(0.07);
    for (double x = 0; x < size.width; x += 22) {
      for (double y = 0; y < size.height; y += 22) {
        canvas.drawCircle(Offset(x, y), 1.5, p);
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
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
// Teacher Card
// ─────────────────────────────────────────────────────────────────────────────

class _TeacherCard extends StatelessWidget {
  final Map<String, dynamic> teacher;
  final int index;
  final String initials;
  final VoidCallback onTap;

  const _TeacherCard({
    required this.teacher,
    required this.index,
    required this.initials,
    required this.onTap,
  });

  List<String> _subjects() {
    final v = teacher['subjects'];
    if (v == null) return [];
    if (v is List) return v.map((e) => e.toString()).take(2).toList();
    if (v is String) {
      return v
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .take(2)
          .toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final colors = _kCardGradients[index % _kCardGradients.length];
    final rating = (teacher['rating'] ?? 0.0).toDouble();
    final stars = rating.round().clamp(0, 5);
    final ranking = teacher['ranking'];
    final name = teacher['name'] ?? 'Teacher';
    final qual = teacher['qualification']?.toString() ?? '';
    final subjects = _subjects();
    final imageUrl = teacher['imageUrl']?.toString() ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // gradient header
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  // ranking badge
                  if (ranking != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '#$ranking',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // avatar
                  Positioned(
                    left: 40,
                    top: 5,
                    child: Center(
                      child: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                imageUrl,
                                width: 100,
                                height: 150,
                                fit: BoxFit.fitHeight,
                              ),
                            )
                          : _Avatar(initials: initials),
                    ),
                  ),
                  // Center(
                  //   child: imageUrl.isNotEmpty
                  //       ? ClipOval(
                  //     child: Image.network(
                  //       imageUrl,
                  //       width: 48,
                  //       height: 48,
                  //       fit: BoxFit.cover,
                  //       errorBuilder: (_, __, ___) =>
                  //           _Avatar(initials: initials),
                  //     ),
                  //   )
                  //       : _Avatar(initials: initials),
                  // ),
                ],
              ),
            ),

            // body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.length > 14 ? '${name.substring(0, 13)}..' : name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kText,
                      ),
                    ),
                    if (qual.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        qual,
                        style: const TextStyle(fontSize: 10, color: _kMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: i < stars ? _kStar : _kBorder,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 10, color: _kMuted),
                        ),
                      ],
                    ),
                    // if (subjects.isNotEmpty) ...[
                    //   const SizedBox(height: 6),
                    //   Wrap(
                    //     spacing: 4,
                    //     runSpacing: 4,
                    //     children: subjects
                    //         .map(
                    //           (s) => Container(
                    //             padding: const EdgeInsets.symmetric(
                    //               horizontal: 6,
                    //               vertical: 2,
                    //             ),
                    //             decoration: BoxDecoration(
                    //               color: _kPrimaryLt,
                    //               borderRadius: BorderRadius.circular(20),
                    //             ),
                    //             child: Text(
                    //               s,
                    //               style: const TextStyle(
                    //                 fontSize: 9,
                    //                 color: _kPrimaryDk,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ),
                    //         )
                    //         .toList(),
                    //   ),
                    // ],
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

class _Avatar extends StatelessWidget {
  final String initials;
  const _Avatar({required this.initials});

  @override
  Widget build(BuildContext context) => Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
    ),
    alignment: Alignment.center,
    child: Text(
      initials,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Review Card
// ─────────────────────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final String initials;

  const _ReviewCard({required this.review, required this.initials});

  static const _avatarColors = [
    [Color(0xFFE1F5EE), Color(0xFF085041)],
    [Color(0xFFEEEDFE), Color(0xFF3C3489)],
    [Color(0xFFFAEEDA), Color(0xFF633806)],
    [Color(0xFFFAECE7), Color(0xFF993C1D)],
  ];

  @override
  Widget build(BuildContext context) {
    final name = review['name']?.toString() ?? 'Student';
    final rating = ((review['rating'] ?? 0) as num).round().clamp(0, 5);
    final comment = review['comment']?.toString() ?? '';
    final date =
        review['date']?.toString() ?? review['created_at']?.toString() ?? '';
    final avatar = review['avatar']?.toString() ?? '';
    final idx = initials.isNotEmpty
        ? initials.codeUnitAt(0) % _avatarColors.length
        : 0;

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
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _RevAvatar(
                          initials: initials,
                          bg: _avatarColors[idx][0],
                          fg: _avatarColors[idx][1],
                        ),
                      ),
                    )
                  : _RevAvatar(
                      initials: initials,
                      bg: _avatarColors[idx][0],
                      fg: _avatarColors[idx][1],
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kText,
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: const TextStyle(fontSize: 10, color: _kMuted),
                      ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: i < rating ? _kStar : _kBorder,
                  ),
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(fontSize: 12, color: _kMuted, height: 1.5),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _RevAvatar extends StatelessWidget {
  final String initials;
  final Color bg;
  final Color fg;
  const _RevAvatar({
    required this.initials,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Text(
      initials,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fg),
    ),
  );
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
    padding: EdgeInsets.fromLTRB(
      16,
      12,
      16,
      MediaQuery.of(context).padding.bottom + 12,
    ),
    decoration: const BoxDecoration(
      color: Colors.white,
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
                  Icon(
                    Icons.calendar_month_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Book demo / class',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
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
// Booking Sheet
// ─────────────────────────────────────────────────────────────────────────────

class _BookingSheet extends StatefulWidget {
  final Map<String, dynamic> subject;
  const _BookingSheet({required this.subject});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int? _selectedTeacherId;
  String _classType = 'Individual';
  final _daysCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _daysCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  List<dynamic> get _teachers =>
      (widget.subject['available_teachers'] as List<dynamic>?) ?? [];

  Future<void> _submit() async {
    if (_selectedTeacherId == null) {
      showFailedAlert(
        context,
        title: 'Validation',
        subtitle: 'Please select a teacher',
        timer: 4,
        color: _kRed,
        showButton: false,
      );
      return;
    }
    if (_daysCtrl.text.trim().isEmpty) {
      showFailedAlert(
        context,
        title: 'Validation',
        subtitle: 'Please enter number of days',
        timer: 4,
        color: _kRed,
        showButton: false,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService().requestSubjectClassBooking({
        'subject_id': widget.subject['id'],
        'teacher_id': _selectedTeacherId,
        'class_type': _classType.toLowerCase(),
        'days': _daysCtrl.text.trim(),
        'note': _notesCtrl.text.trim(),
      });

      if (context.mounted) Navigator.of(context).pop();

      showSuccessAlert(
        context,
        title: res?['status'] == true ? 'Success!' : 'Failed',
        subtitle: res?['message'] ?? 'Booking submitted',
        timer: 4,
        color: res?['status'] == true ? _kPrimary : _kRed,
        showButton: false,
      );

      if (res?['status'] == true) {
        setState(() {
          _daysCtrl.clear();
          _notesCtrl.clear();
          _selectedTeacherId = null;
          _classType = 'Individual';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = widget.subject['name'] ?? 'Subject';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
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
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _kPrimaryLt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_month_outlined,
                    color: _kPrimary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Book $subjectName class',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: _kText,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // teacher selection
            if (_teachers.isEmpty)
              const Text(
                'No teachers available for this subject',
                style: TextStyle(color: _kMuted),
              )
            else ...[
              const _SheetLabel('SELECT TEACHER'),
              const SizedBox(height: 8),
              ..._teachers.map((t) {
                final teacher = t as Map<String, dynamic>;
                final id = teacher['id'] as int?;
                final name = teacher['name'] ?? 'Teacher';
                final qual = teacher['qualification']?.toString() ?? '';
                final rating = (teacher['rating'] ?? 0.0).toDouble();
                final sel = _selectedTeacherId == id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedTeacherId = id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: sel ? _kPrimaryLt : _kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? _kPrimaryMd : _kBorder),
                    ),
                    child: Row(
                      children: [
                        // radio dot
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: sel ? _kPrimary : _kMuted,
                              width: 2,
                            ),
                            color: sel ? _kPrimary : Colors.transparent,
                          ),
                          child: sel
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 12,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        // info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _kText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$qual · ⭐ ${rating.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // arrow
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: _kMuted,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],

            const SizedBox(height: 14),

            // class type
            const _SheetLabel('CLASS TYPE'),
            const SizedBox(height: 8),
            Row(
              children: ['Individual', 'Common', 'Crash'].map((t) {
                final active = _classType == t;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _classType = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: active ? _kPrimaryLt : _kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active ? _kPrimaryMd : _kBorder,
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

            const SizedBox(height: 14),

            // days
            const _SheetLabel('NUMBER OF DAYS'),
            const SizedBox(height: 8),
            TextField(
              controller: _daysCtrl,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // notes
            const _SheetLabel('NOTES (OPTIONAL)'),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
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
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.send_rounded, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Submit booking',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────────────────────────────────────

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
      letterSpacing: 0.6,
    ),
  );
}
