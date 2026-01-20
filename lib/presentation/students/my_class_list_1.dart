import 'package:flutter/material.dart';
import 'package:BookMyTeacher/services/api_service.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/image_paths.dart';
import '../../core/enums/app_config.dart';
import '../components/shimmer_image.dart';


class MyClassList1 extends StatefulWidget {
  const MyClassList1({super.key});

  @override
  State<MyClassList1> createState() => _MyClassList1State();
}

class _MyClassList1State extends State<MyClassList1>
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
            _tabController = TabController(length: 2, vsync: this);
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          _buildTabBar(),
          SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMyStore(), _buildScheduledClasses()],
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // Scheduled Classes Placeholder
  // -----------------------------------------------------
  Widget _buildScheduledClasses() {
    return const Center(
      child: Text(
        "Scheduled classes will be shown here...",
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    );
  }

  // -----------------------------------------------------
  // MY STORE ACCORDIONS
  // -----------------------------------------------------
  Widget _buildMyStore() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _accordion(
            title: "Ongoing Courses",
            icon: Icons.play_circle_fill,
            color: Colors.red,
            sections: _categories[0]['sections'][0]['items'],
            initiallyExpanded: true,
          ),

          _accordion(
            title: "Upcoming Courses",
            icon: Icons.access_time_filled,
            color: Colors.teal,
            // sections: []
            sections: _categories[0]['sections'][2]['items'] ?? [],
            initiallyExpanded: false,
          ),
          _accordion(
            title: "Completed Courses",
            icon: Icons.check_circle,
            color: Colors.green,
            sections: _categories[0]['sections'][1]['items'],
            initiallyExpanded: false,
          ),
          _accordion(
            title: "Pending Approval",
            icon: Icons.hourglass_bottom,
            color: Colors.orange,
            // sections: []
            sections: _categories[0]['sections'][3]['items'] ?? [],
            initiallyExpanded: false,
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------
  // CUSTOM PREMIUM ACCORDION WITH ANIMATION
  // -----------------------------------------------------
  Widget _accordion({
    required String title,
    required IconData icon,
    required Color color,
    required List<dynamic> sections,
    bool initiallyExpanded = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: _AnimatedAccordion(
        title: title,
        icon: icon,
        color: color,
        initiallyExpanded: initiallyExpanded, // 👈 pass down
        content: _buildSectionList(sections),
      ),
    );
  }

  // -----------------------------------------------------
  // ACCORDION CONTENT (SECTIONS)
  // -----------------------------------------------------
  // Widget _buildSectionList(List<dynamic> items) {
  //   if (items.isEmpty) {
  //     return Padding(
  //       padding: const EdgeInsets.all(20),
  //       child: Center(
  //         child: Text(
  //           "No courses found",
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: Colors.grey.shade600,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return SingleChildScrollView(
  //     child: Column(
  //       children: [
  //         GridView.builder(
  //           shrinkWrap: true,
  //           physics: const NeverScrollableScrollPhysics(),
  //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 1,
  //             mainAxisSpacing: 12,
  //             childAspectRatio: 3,
  //           ),
  //           itemCount: items.length,
  //           itemBuilder: (context, idx) {
  //             return Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 8),
  //               child: _buildClassCard(items[idx]),
  //             );
  //           },
  //         ),
  //         SizedBox(height: 30,)
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSectionList(List<dynamic> items) {
    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            "No courses found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(top: 8, bottom: 30),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildClassCard(items[idx]),
        );
      },
    );
  }

  // -----------------------------------------------------
  // CLASS CARD
  // -----------------------------------------------------
  Widget _buildClassCard(dynamic item) {
    return GestureDetector(
      onTap: () {
        context.push('/class-detail', extra: item["id"].toString());
      },
      child: Container(
        // padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ShimmerImage(
                imageUrl: item['image'],
                width: 50,
                height: 50,
                borderRadius: 9,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['type'] ?? '',
                      style: const TextStyle(fontSize: 13, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -----------------------------------------------------
  // HEADER
  // -----------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 55, left: 16, right: 16),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        image: DecorationImage(
          image: AssetImage(ImagePaths.appBg),
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
                "My Class List",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Icon(icon, color: Colors.green.shade700),
      ),
    );
  }

  // -----------------------------------------------------
  // TAB BAR
  // -----------------------------------------------------
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
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        indicatorColor: Colors.green,
        indicatorWeight: 3,
        labelColor: Colors.green.shade700,
        unselectedLabelColor: Colors.grey,
        tabs: const [
          Tab(text: "My Store"),
          Tab(text: "Scheduled Classes"),
        ],
      ),
    );
  }
}

class _AnimatedAccordion extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget content;
  final bool initiallyExpanded;

  const _AnimatedAccordion({
    required this.title,
    required this.icon,
    required this.color,
    required this.content,
    required this.initiallyExpanded,
  });

  @override
  _AnimatedAccordionState createState() => _AnimatedAccordionState();
}

class _AnimatedAccordionState extends State<_AnimatedAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
      value: _isExpanded ? 1.0 : 0.0, // 👈 key line
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      _isExpanded ? _controller.forward() : _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    double accordionHeight =
        MediaQuery.sizeOf(context).height * 0.50; // 1/2 screen

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // 🔥 Sticky Title Section
              InkWell(
                onTap: _toggleExpand,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, color: widget.color),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),

              // 🔥 Sticky header line shadow (optional)
              if (_isExpanded)
                Container(height: 1, color: Colors.grey.shade300),

              // 🔥 Scrollable Body (Sticky header effect)
              ClipRect(
                child: Align(
                  heightFactor: _animation.value,
                  child: SizedBox(
                    height: accordionHeight, // fixed 1/2 screen height
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      child: widget.content,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
