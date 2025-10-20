import 'package:BookMyTeacher/presentation/students/request_details_bottomsheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neopop/widgets/buttons/neopop_tilted_button/neopop_tilted_button.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/enums/app_config.dart';
import '../../providers/service_providers.dart';
import '../../services/api_service.dart';
import '../../services/student_api_service.dart';
import '../widgets/top_banner_carousel.dart';
import '../students/search_result_page.dart';

import 'package:animate_do/animate_do.dart';

import 'animated_search_field.dart';

class DashboardHome extends ConsumerStatefulWidget {
  final Future<Map<String, dynamic>> studentDataFuture;

  const DashboardHome({
    super.key,
    required this.studentDataFuture,
    required String studentId,
  });

  @override
  ConsumerState<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends ConsumerState<DashboardHome> {
  late Future<Map<String, dynamic>> _studentDataFuture;

  final TextEditingController fromCtrl = TextEditingController();
  final TextEditingController noteCtrl = TextEditingController();
  List<String> selectedGrades = [];
  List<String> selectedBoards = [];
  List<String> selectedSubjects = [];

  Map<String, List<Map<String, dynamic>>> get searchData => {
    'teachers': [
      {'id': 1, 'name': 'John Doe', 'extra': 'Math'},
      {'id': 2, 'name': 'Jane Smith', 'extra': 'Science'},
    ],
    'subjects': [
      {'id': 1, 'name': 'Maths'},
      {'id': 2, 'name': 'Science'},
    ],
    'grades': [],
    'boards': [
      {'id': 1, 'name': 'CBSE'},
    ],
    'skills': [
      {'id': 1, 'name': 'Programming'},
    ],
  };
  // void _showRequestedClasses() async {
  //   final api = ref.read(apiServiceProvider);
  //   final data = await api.fetchRequestedClasses();
  //   if (!mounted) return;
  //
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     builder: (_) => RequestDetailsBottomSheet(requests: data),
  //   );
  // }

  @override
  void initState() {
    super.initState();
    _studentDataFuture = widget.studentDataFuture;
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  @override
  Widget build(BuildContext context) {
    final searchDataAsync = ref.watch(searchDataProvider);
    final gradesAsync = ref.watch(gradesProvider);
    final boardsAsync = ref.watch(boardsProvider);
    final subjectsAsync = ref.watch(subjectsProvider);

    return FutureBuilder<Map<String, dynamic>>(
      future: _studentDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: Text('No data found')));
        }

        final student = snapshot.data!;
        final avatar = student['avatar'] ?? 'https://via.placeholder.com/150';
        final name = student['user']['name'] ?? 'Student';

        return Scaffold(
          backgroundColor: const Color(0xFFF9F9F9),
          body: SafeArea(
            child: Stack(
              children: [
                Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(AppConfig.bodyBg),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Column(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ---------- Header ----------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(avatar),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_none_rounded,
                                  size: 28,
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ---------- Top Banners ----------
                          const TopBannerCarousel(),

                          const SizedBox(height: 16),

                          // ---------- Search Bar ----------
                          //  AnimatedSearchDashboard(searchData: searchData),

                          // ,(
                          // onTap: (context) => _openFilterBottomSheet(context, {
                          //   'teachers': [],
                          //   'subjects': [],
                          //   'grades': [],
                          //   'boards': [],
                          // })
                          // ),
                          // searchDataAsync.when(
                          //   data: (data) {
                          //     return Row(
                          //       children: [
                          //         Expanded(
                          //           child: TextField(
                          //             decoration: InputDecoration(
                          //               hintText:
                          //                   'Search teachers, subjects, grades...',
                          //               border: OutlineInputBorder(
                          //                 borderRadius: BorderRadius.circular(
                          //                   10,
                          //                 ),
                          //                 borderSide: BorderSide.none,
                          //               ),
                          //               filled: true,
                          //               fillColor: Colors.white,
                          //               prefixIcon: const Icon(Icons.search),
                          //             ),
                          //             readOnly: true,
                          //             onTap: () =>
                          //                 _openFilterBottomSheet(context, data),
                          //           ),
                          //         ),
                          //         // const SizedBox(width: 10),
                          //         GestureDetector(
                          //           onTap: () =>
                          //               _openFilterBottomSheet(context, data),
                          //           child: Container(
                          //             padding: const EdgeInsets.all(10),
                          //             // decoration: BoxDecoration(
                          //             //   color: Colors.green,
                          //             //   borderRadius: BorderRadius.circular(10),
                          //             // ),
                          //             child:
                          //             const Image(image: AssetImage('assets/images/icons/filter.png'),
                          //               width: 30,height: 30,
                          //             ),
                          //           ),
                          //         ),
                          //       ],
                          //     );
                          //   },
                          //   loading: () => const Center(
                          //     child: CircularProgressIndicator(),
                          //   ),
                          //   error: (e, _) => Center(child: Text('Error: $e')),
                          // ),

                          const SizedBox(height: 20),
                          Expanded(
                              child: Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: Text(''),
                              )
                          ),

                          // ---------- Request Class ----------
                          // FadeInUp(
                          //   duration: const Duration(milliseconds: 600),
                          //   child:
                          Center(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade200,
                                    Colors.green.shade100,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withOpacity(0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              // margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // FadeInDown(
                                  //  duration: Duration(milliseconds: 400),
                                  //  child:
                                  Text(
                                    "Request a Class/Course",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  // ),
                                  const SizedBox(height: 20),
                                  // ---------- Row 1: You are from + Grades ----------
                                  Row(
                                    children: [
                                      Expanded(
                                        // child: FadeInLeft(
                                        //   duration: const Duration(milliseconds: 500),
                                        child: _buildField(
                                          controller: fromCtrl,
                                          label: "You are from?",
                                          // icon: Icons.location_city,
                                        ),
                                        // ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        // child: FadeInRight(
                                        //   duration: const Duration(milliseconds: 500),
                                        child: _buildFakeDropdown(
                                          label: "Grades",
                                          values: [
                                            "Grade 1",
                                            "Grade 2",
                                            "Grade 3",
                                          ],
                                          selected: selectedGrades,
                                          onSelect: (v) => setState(
                                                () => selectedGrades = v,
                                          ),
                                        ),
                                        // ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // ---------- Row 2: Boards + Subjects ----------
                                  Row(
                                    children: [
                                      Expanded(
                                        // child: FadeInLeft(
                                        //   duration: const Duration(milliseconds: 600),
                                        child: _buildFakeDropdown(
                                          label: "Board / Syllabus",
                                          values: [
                                            "CBSE",
                                            "ICSE",
                                            "State Board",
                                          ],
                                          selected: selectedBoards,
                                          onSelect: (v) => setState(
                                                () => selectedBoards = v,
                                          ),
                                        ),
                                        // ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        // child: FadeInRight(
                                        //   duration: const Duration(milliseconds: 600),
                                        child: _buildFakeDropdown(
                                          label: "Subjects",
                                          values: [
                                            "Maths",
                                            "Science",
                                            "English",
                                          ],
                                          selected: selectedSubjects,
                                          onSelect: (v) => setState(
                                                () => selectedSubjects = v,
                                          ),
                                        ),
                                      ),
                                      // ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // ---------- Full-width Note Field ----------
                                  // FadeInLeft(
                                  //   duration: const Duration(milliseconds: 700),
                                  //   child:
                                  _buildField(
                                    controller: noteCtrl,
                                    label: "Do you want to tell me something?",
                                    // icon: Icons.chat_bubble_outline,
                                    maxLines: 3,
                                    // ),
                                  ),

                                  const SizedBox(height: 28),

                                  // ---------- Neopop Button ----------
                                  Center(
                                    child: NeoPopTiltedButton(
                                      isFloating: true,
                                      onTapUp: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Request submitted successfully!",
                                            ),
                                          ),
                                        );
                                      },
                                      decoration:
                                      const NeoPopTiltedButtonDecoration(
                                        color: Color(0xFF64D336),
                                        plunkColor: Color(0xFFE8F9E8),
                                        shadowColor: Color(0xFF2A3B2A),
                                        showShimmer: true,
                                      ),
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 70.0,
                                          vertical: 15,
                                        ),
                                        child: Text(
                                          'Submit Request',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // ---------- Request History Button ----------
                                  Center(
                                    child: FadeInRight(
                                      duration: const Duration(
                                        milliseconds: 700,
                                      ),
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            _showRequestsBottomSheet(context),
                                        icon: const Icon(Icons.history),
                                        label: const Text(
                                          "View Requested Classes",
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ),
                          const SizedBox(height: 20),

                          // ---------- Wallet ----------
                          _buildWalletSection(),

                          const SizedBox(height: 20),

                          // ---------- Invite Friends ----------
                          _buildInviteFriendsCard(),

                          const SizedBox(height: 20),

                          // ---------- Top Teachers ----------
                          _buildTopTeachersSection(),

                          const SizedBox(height: 20),

                          // ---------- Providing Subjects ----------
                          _buildProvidingSubjectsSection(),

                          const SizedBox(height: 20),

                          // ---------- Providing Courses ----------
                          _buildProvidingCoursesSection(),

                          const SizedBox(height: 40),
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
  }

  // ---------- Bottom Sheet ----------
  // void _openFilterBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (_) => const FilterBottomSheet(),
  //   );
  // }
  void _openFilterBottomSheet(BuildContext context, Map<String, dynamic> data) {
    final selectedFilters = ref.read(selectedFiltersProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Filter Options',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Divider(),
                _buildFilterList(
                  'Subjects',
                  data['subjects'],
                  selectedFilters,
                  'subjects',
                ),
                _buildFilterList(
                  'Grades',
                  data['grades'],
                  selectedFilters,
                  'grades',
                ),
                _buildFilterList(
                  'Boards',
                  data['boards'],
                  selectedFilters,
                  'boards',
                ),
                _buildFilterList(
                  'Teachers',
                  data['teachers'],
                  selectedFilters,
                  'teachers',
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final api = ref.read(apiServiceProvider);
                    final filters = {
                      'teachers': selectedFilters['teachers']!,
                      'subjects': selectedFilters['subjects']!,
                      'grades': selectedFilters['grades']!,
                      'boards': selectedFilters['boards']!,
                    };
                    final result = await api.searchResult(filters);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SearchResultPage(result: result),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Helper UI Sections ----------
  Widget _buildFilterList(
      String title,
      List<dynamic> items,
      Map<String, List<int>> selectedFilters,
      String key,
      ) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isSelected = selectedFilters[key]!.contains(item['id']);
        return CheckboxListTile(
          value: isSelected,
          title: Text(item['name']),
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selectedFilters[key]!.add(item['id']);
              } else {
                selectedFilters[key]!.remove(item['id']);
              }
            });
          },
        );
      }),
    );
  }

  Widget _buildOptionCard(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.green),
        const SizedBox(width: 5),
        Text(label),
      ],
    ),
  );

  Widget _buildWalletSection() => Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Wallet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _walletCard(
              'GreenCoins',
              '100',
              Icons.monetization_on,
              Colors.green,
            ),
            _walletCard('Rupees', '500', Icons.currency_rupee, Colors.amber),
          ],
        ),
      ],
    ),
  );

  Widget _walletCard(String title, String value, IconData icon, Color color) =>
      Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: _boxDecoration(),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(title, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ],
        ),
      );

  Widget _buildInviteFriendsCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Row(
      children: [
        const Icon(Icons.card_giftcard, color: Colors.green, size: 30),
        const SizedBox(width: 12),
        const Expanded(child: Text('Invite friends & earn rewards!')),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Refer'),
        ),
      ],
    ),
  );

  Widget _buildTopTeachersSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Top Teachers',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 130,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 6,
          itemBuilder: (context, index) => Container(
            width: 110,
            margin: const EdgeInsets.only(right: 10),
            decoration: _boxDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.green),
                const SizedBox(height: 5),
                Text(
                  'Teacher ${index + 1}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildProvidingSubjectsSection() =>
      _buildChipSection('Providing Subjects');
  Widget _buildProvidingCoursesSection() =>
      _buildChipSection('Providing Courses');

  Widget _buildChipSection(String title) => Container(
    padding: const EdgeInsets.all(16),
    decoration: _boxDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            6,
                (index) => Chip(
              label: Text('$title ${index + 1}'),
              backgroundColor: Colors.green.withOpacity(0.1),
            ),
          ),
        ),
      ],
    ),
  );

  BoxDecoration _boxDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 5),
    ],
  );

  // ---------- Reusable Input Field ----------
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    // required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        // prefixIcon: Icon(icon, color: Colors.green.shade700),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 12),
        filled: true,
        fillColor: Colors.green.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.green.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.green.shade400, width: 1.5),
        ),
      ),
    );
  }

  // ---------- Multi-select Dropdown (Modal Bottom Sheet) ----------
  Widget _buildFakeDropdown({
    required String label,
    required List<String> values,
    required List<String> selected,
    required Function(List<String>) onSelect,
  }) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) {
            List<String> temp = List.from(selected);
            return StatefulBuilder(
              builder: (context, setSheet) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: ListView(
                          children: values.map((v) {
                            final isSelected = temp.contains(v);
                            return CheckboxListTile(
                              activeColor: Colors.green,
                              value: isSelected,
                              title: Text(v),
                              onChanged: (val) {
                                setSheet(() {
                                  if (val == true) {
                                    temp.add(v);
                                  } else {
                                    temp.remove(v);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          onSelect(temp);
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.green.shade50,
          suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.green),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.green.shade200),
          ),
        ),
        child: Text(
          selected.isEmpty ? "Select..." : selected.join(", "),
          style: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }

  // ---------- Request List Bottom Sheet ----------
  void _showRequestsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => FadeInUp(
        duration: const Duration(milliseconds: 400),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text("Requested to: Maths - CBSE"),
                subtitle: Text("Date: 19 Oct 2025 • Status: Pending"),
                trailing: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () {},
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
