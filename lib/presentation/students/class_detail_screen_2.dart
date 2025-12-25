import 'dart:async';
import 'package:BookMyTeacher/presentation/students/recorded_video_with_doubt.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../components/shimmer_image.dart';

class ClassDetailScreen extends StatefulWidget {
  final String classId;
  const ClassDetailScreen({super.key, required this.classId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _countdownTimer;
  Map<String, Duration> _countdowns = {};

  Map<String, dynamic>? _data;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData(); // fetch once
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final resp = await ApiService().fetchClassDetail(widget.classId);
      setState(() {
        _data = resp;
        _isLoading = false;
      });

      final classes = (resp['classes'] as List?) ?? [];
      _startCountdowns(classes);
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

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // 🔥 Always open in browser
      );

      // if (await canLaunchUrl(uri)) {
      //   await launchUrl(uri, mode: LaunchMode.externalApplication);
      // } else {
      //   _showSnack("Can't open link");
      // }
    } catch (e) {
      _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _startCountdowns(List<dynamic> classes) {
    _countdownTimer?.cancel();
    _countdowns.clear();

    for (var c in classes) {
      try {
        final id = c['id'].toString();
        final dateTime = c['date_time'];
        if (dateTime != null && dateTime.toString().isNotEmpty) {
          final dt = DateTime.parse(dateTime);
          if (dt.isAfter(DateTime.now())) {
            _countdowns[id] = dt.difference(DateTime.now());
          }
        }
      } catch (_) {}
    }

    if (_countdowns.isNotEmpty) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        bool changed = false;
        final keys = _countdowns.keys.toList();
        for (var k in keys) {
          final remaining = _countdowns[k]!;
          if (remaining.inSeconds <= 1) {
            _countdowns.remove(k);
            changed = true;
          } else {
            _countdowns[k] = remaining - const Duration(seconds: 1);
            changed = true;
          }
        }
        if (changed && mounted) setState(() {});
      });
    }
  }

  String _readableDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$h:$m:$s";
  }

  Future<void> _onClassAction(Map<String, dynamic> c) async {
    final title  = (c['title'] ?? '').toString();
    final dateTime = c['date_time']?.toString;
    final status = (c['status'] ?? '').toString().toLowerCase();
    final joinLink = c['join_link']?.toString();
    final recorded = c['recorded_video']?.toString();

    if (status == 'ongoing') {
      if (joinLink != null && joinLink.isNotEmpty) {
        await _openUrl(joinLink);
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
            builder: (_) => RecordedVideoWithDoubt(
              title: title,
              videoUrl: recorded,
            ),
          ),
        );

      } else {
        _showSnack("Recording not available");
      }
    }
  }

  Widget _buildJoinButton(List<dynamic> classes) {
    final ongoing = classes.cast<Map<String, dynamic>?>().firstWhere(
      (c) => c?['status'] == 'ongoing',
      orElse: () => null,
    );

    if (ongoing == null) return const SizedBox.shrink();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: SafeArea(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.videocam),
          label: const Text("Join Ongoing Class"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async => _onClassAction(ongoing),
        ),
      ),
    );
  }

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
    final materials = (_data!['materials'] as List?) ?? [];
    final classes = (_data!['classes'] as List?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _onRefresh,
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 220,
                  backgroundColor: Colors.green.shade600,
                  flexibleSpace: FlexibleSpaceBar(
                    background: ShimmerImage(
                      imageUrl: info['image'] ?? '',
                      width: double.infinity,
                      height: 220,
                      borderRadius: 0,
                    ),
                  ),
                ),
              ],
              body: Column(
                children: [
                  // Header Info
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info['title'] ?? 'Untitled Class',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          info['description'] ?? '',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  // Tabs
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.green,
                    labelColor: Colors.green,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: "Classes"),
                      Tab(text: "Materials"),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildClassesTab(classes),
                        _buildMaterialsTab(materials),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildJoinButton(classes),
        ],
      ),
    );
  }

  Widget _buildMaterialsTab(List materials) {
    if (materials.isEmpty) {
      return const Center(child: Text("No materials available"));
    }

    return ListView.builder(
      itemCount: materials.length,
      itemBuilder: (context, i) {
        final m = materials[i];
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf),
          title: Text(m['title'] ?? 'Untitled'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () async {
                  if (m['file_url'] != null) {
                    await _openUrl(m['file_url']);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () async {
                  if (m['file_url'] != null) {
                    await _openUrl(m['file_url']);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassesTab(List classes) {
    if (classes.isEmpty) {
      return const Center(child: Text("No classes available"));
    }

    return ListView.builder(
      itemCount: classes.length,
      itemBuilder: (context, i) {
        final c = classes[i];
        final countdown = _countdowns[c['id'].toString()];
        final status = (c['status'] ?? '').toString().toLowerCase();

        return ListTile(
          leading: const Icon(Icons.video_library),
          title: Text(c['title'] ?? 'Unnamed Class'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Status: ${c['status']}"),
              if (status == 'upcoming' && countdown != null)
                Text("Starts in: ${_readableDuration(countdown)}"),
              if (status != 'upcoming') Text("Date: ${c['date_time'] ?? '-'}"),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () async => _onClassAction(c),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
            ),
            child: const Text("Open"),
          ),
        );
      },
    );
  }
}
