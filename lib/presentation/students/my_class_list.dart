import 'package:flutter/material.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:go_router/go_router.dart';

import '../../core/enums/app_config.dart';
import '../components/shimmer_image.dart';
import '../webinars/webinar_listing.dart';

class MyClassList extends StatefulWidget {
  const MyClassList({super.key});

  @override
  State<MyClassList> createState() => _MyClassListState();
}

class _MyClassListState extends State<MyClassList>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  bool _loading = true;
  List<dynamic> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchMyClasses();
  }

  Future<void> _fetchMyClasses() async {
    try {
      final result = await ApiService().fetchMyClasses();
      final categories = result['data']['categories'] ?? [];

      if (mounted) {
        setState(() {
          _categories = categories;
          if (categories.isNotEmpty) {
            _tabController = TabController(
              length: categories.length,
              vsync: this,
            );
          }
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching classes: $e");
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_tabController == null || _categories.isEmpty) {
      return const Scaffold(body: Center(child: Text("No classes found.")));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildHeader(context),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  final sections = category['sections'] as List<dynamic>? ?? [];
                  return _buildSectionList(sections);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        image: DecorationImage(
          image: NetworkImage(AppConfig.bodyBg),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          _circleButton(Icons.keyboard_arrow_left, () {
            context.push('/student-dashboard');
          }),
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
    );
  }

  Widget _buildTabBar() {
    return Container(
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
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: Colors.green.shade600,
        labelColor: Colors.green.shade600,
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: _categories
            .map((c) => Tab(text: c['category'].toString()))
            .toList(),
      ),
    );
  }

  Widget _buildSectionList(List<dynamic> sections) {
    return ListView.builder(
      // padding: const EdgeInsets.all(16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final items = section['items'] as List<dynamic>? ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Text(
                section['status'] ?? 'Section',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            // const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 10,
                childAspectRatio: 3,
              ),
              itemCount: items.length,
              itemBuilder: (context, idx) {
                final item = items[idx];
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: _buildClassCard(item),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildClassCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        context.push('/class-detail', extra: item["id"].toString());
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ShimmerImage(
              imageUrl: item['image'] ?? '',
              width: 140,
              height: 80,
              borderRadius: 8,
            ),
            const SizedBox(width: 30),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['title'] ?? 'No Title',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['level'] ?? '',
                    style: const TextStyle(color: Colors.green, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Icon(icon, color: Colors.green.shade700),
      ),
    );
  }
}
