import 'package:BookMyTeacher/core/constants/endpoints.dart';
import 'package:BookMyTeacher/core/constants/image_paths.dart';
import 'package:BookMyTeacher/core/enums/app_config.dart';
import 'package:BookMyTeacher/presentation/components/webinar_cards.dart';
import 'package:BookMyTeacher/presentation/components/webinar_detail_bottom_sheet.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../components/course_card.dart';
import '../components/course_detail_bottom_sheet.dart';
import '../components/webinar_card.dart';
import '../components/workshop_card.dart';
import 'package:intl/intl.dart';

import '../components/workshop_detail_bottom_sheet.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _categories = [];
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchCourses();

  }

  Future<void> _fetchCourses() async {
    try {
      final result = await ApiService().fetchProvideCourses();
      setState(() {
        _categories = result['data'];
        _tabController = TabController(length: _categories.length, vsync: this);
        _loading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _loading = false);
    }
  }

  void _showCourseDetail(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CourseDetailBottomSheet(
        course: course,
        redirectTo: '/student-course-store',
      ),
    );
  }

  void _showWebinarDetail(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WebinarDetailBottomSheet(
        course: course,
        redirectTo: '/student-course-store',
      ),
    );
  }

  void _showWorkshopDetail(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkshopDetailBottomSheet(
        course: course,
        redirectTo: '/student-course-store',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Image.asset(
            ImagePaths.appBg,
            fit: BoxFit.contain,
            // height: double.infinity,
            // width: double.infinity,
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  image: const DecorationImage(
                    image: CachedNetworkImageProvider(AppConfig.bodyBg),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Row(
                  children: [
                    _circleButton(
                      Icons.keyboard_arrow_left,
                      () => context.push('/student-dashboard'),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Learning Hub",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // TabBar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Center(
                  // <-- Centers the whole tab row
                  child: IntrinsicWidth(
                    stepWidth: 50,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: FullWidthIndicator(
                        color: Colors.green,
                        thickness: 3,
                      ),
                      indicatorColor: Colors.green.shade600,
                      labelColor: Colors.green.shade600,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: _categories
                          .map((c) => Tab(text: c['category'].toString()))
                          .toList(),
                    ),
                  ),
                ),
              ),

              // TabBarView
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: TabBarView(
                    controller: _tabController,
                    children: _categories.map((category) {
                      final courses = category['items'] as List<dynamic>;

                      if (courses.isEmpty) {
                        return _emptyState(
                          title: 'No ${category['category']} Found',
                          subtitle:
                              'We are not Provide in any ${category['category'].toString().toLowerCase()} yet.',
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final item = courses[index];

                          switch (category['category']) {
                            case 'Course':
                              return CourseCard(
                                course: item,
                                onTap: () => _showCourseDetail(item),
                              );

                            case 'Webinar':
                              return WebinarCards(
                                webinar: item,
                                onTap: () => _showWebinarDetail(item),
                              );

                            case 'Workshop':
                              return WorkshopCard(
                                workshop: item,
                                onTap: () => _showWorkshopDetail(item),
                              );

                            default:
                              return const SizedBox.shrink();
                          }
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _emptyState({required String title, required String subtitle}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class FullWidthIndicator extends Decoration {
  final Color color;
  final double thickness;

  const FullWidthIndicator({required this.color, this.thickness = 3});

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _FullWidthIndicatorPainter(color, thickness);
  }
}

class _FullWidthIndicatorPainter extends BoxPainter {
  final Color color;
  final double thickness;

  _FullWidthIndicatorPainter(this.color, this.thickness);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration config) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = thickness;

    final double width = config.size!.width;
    final double y = config.size!.height - thickness / 2;

    // Draw full-width line
    canvas.drawLine(
      Offset(offset.dx, offset.dy + y),
      Offset(offset.dx + width, offset.dy + y),
      paint,
    );
  }
}
