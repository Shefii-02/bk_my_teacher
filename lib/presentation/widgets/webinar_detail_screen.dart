// class_detail_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:BookMyTeacher/presentation/students/recorded_video_with_doubt.dart';
import '../components/shimmer_image.dart';

class WebinarDetailScreen extends StatefulWidget {
  final String classId;
  const WebinarDetailScreen({super.key, required this.classId});

  @override
  State<WebinarDetailScreen> createState() => _WebinarDetailScreenState();
}

class _WebinarDetailScreenState extends State<WebinarDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Use a ValueNotifier for countdowns to avoid rebuilding whole widget every second
  final ValueNotifier<Map<String, Duration>> _countdownNotifier =
  ValueNotifier({});

  Timer? _ticker;

  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    // 3 tabs: About, Classes, Materials
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _countdownNotifier.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final resp = await ApiService().fetchWebinarDetail(widget.classId);
      setState(() {
        _data = resp;
        _isLoading = false;
      });

      final classes = (resp['classes'] as List?) ?? [];
      _setupCountdowns(classes);
    } catch (e) {
      debugPrint('fetchClassDetail error: $e');
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    }
  }

  Future<void> _onRefresh() async {
    await _loadData();
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

  /// Optimized countdown: populate initial remaining durations in a map and
  /// tick once per second updating the ValueNotifier. Only widgets that listen
  /// to the notifier rebuild.
  void _setupCountdowns(List<dynamic> classes) {
    _ticker?.cancel();
    final Map<String, Duration> map = {};

    final now = DateTime.now();
    for (var c in classes) {
      try {
        final id = c['id'].toString();
        final dtStr = c['date_time']?.toString();
        if (dtStr != null && dtStr.isNotEmpty) {
          final dt = DateTime.parse(dtStr);
          if (dt.isAfter(now)) {
            map[id] = dt.difference(now);
          }
        }
      } catch (_) {
        // ignore parse errors
      }
    }

    _countdownNotifier.value = map;

    if (map.isEmpty) {
      _ticker?.cancel();
      return;
    }

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      final current = Map<String, Duration>.from(_countdownNotifier.value);
      bool changed = false;

      final keys = current.keys.toList();
      for (final k in keys) {
        final rem = current[k]!;
        if (rem.inSeconds <= 1) {
          current.remove(k);
          changed = true;
        } else {
          current[k] = rem - const Duration(seconds: 1);
          changed = true;
        }
      }

      if (changed) {
        _countdownNotifier.value = current;
      }

      if (current.isEmpty) {
        // stop timer when no countdowns left
        _ticker?.cancel();
      }
    });
  }

  String _humanDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Future<void> _onClassAction(Map<String, dynamic> c) async {
    final status = (c['status'] ?? '').toString().toLowerCase();
    final joinLink = c['join_link']?.toString();
    final recorded = c['recorded_video']?.toString();
    final title = (c['title'] ?? '').toString();
    final source = (c['source'] ?? '').toString();
    if (status == 'ongoing') {
      if (joinLink != null && joinLink.isNotEmpty) {
        if(source == 'gmeet') {
          await _openUrl(joinLink);
        }
        else if(source == 'youtube'){
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RecordedVideoWithDoubt(title: title, videoUrl: joinLink, classId: c['id'], type: 'course',),
            ),
          );
        }
        else{
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
            builder: (_) => RecordedVideoWithDoubt(title: title, videoUrl: recorded, classId: c['id'], type: 'webinar'),
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

    return SizedBox(height: 10,);
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

  // ------------------- Build -------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_isError || _data == null) {
      return Scaffold(
        body: Center(
          child: TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            onPressed: _loadData,
          ),
        ),
      );
    }

    final info = _data!['class_detail'] as Map<String, dynamic>? ?? {};
    final classes = (_data!['classes'] as List?) ?? [];
    final materials = (_data!['materials'] as List?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                _buildSliverAppBar(info),
                _buildStickyTabBar(),
              ],
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(info),
                  _buildClassesTab(classes),
                  _buildMaterialsTab(materials),
                ],
              ),
            ),
          ),

          // Join button overlay
          _buildJoinButton(classes),
        ],
      ),
    );
  }

  // ------------------- Sliver AppBar & sticky tab -------------------
  // Widget _buildSliverAppBar(Map<String, dynamic> info) {
  //   return SliverAppBar(
  //     pinned: true,
  //     expandedHeight: 220,
  //     backgroundColor: Colors.green.shade600,
  //     elevation: 0,
  //     flexibleSpace: FlexibleSpaceBar(
  //       background: ShimmerImage(
  //         imageUrl: info['thumbnail'] ?? '',
  //         width: double.infinity,
  //         height: 220,
  //         borderRadius: 0,
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSliverAppBar(Map<String, dynamic> info) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 220,
      backgroundColor: Colors.green.shade600,
      elevation: 0,
      automaticallyImplyLeading: false, // disable default back button
      flexibleSpace: Stack(
        children: [

          FlexibleSpaceBar(
            background: ShimmerImage(
              imageUrl: info['thumbnail'] ?? '',
              width: double.infinity,
              height: 220,
              borderRadius: 0,
            ),
          ),
          // 🔙 Custom Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: _circleButton(
              Icons.keyboard_arrow_left,
                  () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }

  // sticky TabBar via SliverPersistentHeader
  Widget _buildStickyTabBar() {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "About"),
            Tab(text: "Classes"),
            Tab(text: "Materials"),
          ],
        ),
      ),
    );
  }

  // ------------------- ABOUT TAB (Minimal Premium UI) -------------------
  Widget _buildAboutTab(Map<String, dynamic> info) {
    final title = info['title'] ?? 'Untitled Class';
    final desc = info['description'] ?? '';
    final teacher = info['teacher']?['name'] ?? info['teacher_name'] ?? '—';
    final level = info['level'] ?? '';
    final duration = info['duration'] ?? '';
    final students = info['students_count'] ?? info['enrolled'] ?? null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade200,
              child: Text(teacher.isNotEmpty ? teacher[0].toUpperCase() : 'T'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teacher, style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (level != null && level.toString().isNotEmpty)
                    Text(level.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            if (students != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$students students', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (duration != null && duration.toString().isNotEmpty)
                    Text(duration.toString(), style: const TextStyle(color: Colors.grey)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Quick highlights (if available)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statChip(Icons.timer, duration ?? '—'),
            _statChip(Icons.school, info['certificate'] == true ? 'Certificate' : 'No cert'),
            _statChip(Icons.folder, (info['materials_count'] ?? materialsCount(info)).toString()),
          ],
        ),
        const SizedBox(height: 18),
        Text('About this course', style: TextStyle(fontSize: 16, color: Colors.grey.shade800)),
        const SizedBox(height: 8),
        Text(desc, style: const TextStyle(fontSize: 14, height: 1.4)),
        const SizedBox(height: 20),

        // Optional: What you'll learn (if present)
        if (info['highlights'] is List && (info['highlights'] as List).isNotEmpty) ...[
          const Text('What you’ll learn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...List<Widget>.from((info['highlights'] as List).map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Icon(Icons.check, size: 18, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text(h.toString())),
              ],
            ),
          ))),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  int materialsCount(Map<String, dynamic> info) {
    // fallback if server gave materials under top-level or as array
    final mats = (_data?['materials'] as List?) ?? [];
    return mats.length;
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

  // ------------------- CLASSES TAB (uses countdown notifier for efficiency) -------------------
  Widget _buildClassesTab(List classes) {
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
            final c = classes[i] as Map<String, dynamic>;
            final status = (c['status'] ?? '').toString().toLowerCase();
            final id = c['id'].toString();
            final localRemaining = countdowns[id];
            final dtStr = c['date_time'] ?? '-';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: const Icon(Icons.video_library, size: 34, color: Colors.green),
              title: Text(c['title'] ?? 'Unnamed Class', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (status == 'upcoming' && localRemaining != null)
                    Text('Starts in: ${_humanDuration(localRemaining)}'),
                  if (status != 'upcoming') Text('Date: ${_formatDateTime(c['date_time'])}'),
                  if ((c['duration'] ?? '').toString().isNotEmpty) Text('Duration: ${c['duration']}'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _onClassAction(c),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade600),
                child: Text(_actionLabelForStatus(status),style: const TextStyle(color: Colors.white,)),
              ),
            );
          },
        );
      },
    );
  }

  String _actionLabelForStatus(String status) {
    switch (status) {
      case 'ongoing':
        return 'Join';
      case 'completed':
        return 'Watch';
      case 'upcoming':
      default:
        return 'Open';
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

  // ------------------- MATERIALS TAB -------------------
  Widget _buildMaterialsTab(List materials) {
    if (materials.isEmpty) {
      return const Center(child: Text("No materials available"));
    }

    return ListView.separated(
      itemCount: materials.length,
      separatorBuilder: (_, __) => const Divider(height: 0.5),
      itemBuilder: (context, i) {
        final m = materials[i] as Map<String, dynamic>;
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text(m['title'] ?? 'Untitled'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () async {
                  if (m['file_url'] != null) await _openUrl(m['file_url']);
                },
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  if (m['file_url'] != null) await _openUrl(m['file_url']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        iconSize: 22,
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}

/// Helper: make a sticky TabBar sliver
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => false;
}
