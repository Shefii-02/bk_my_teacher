import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/user_provider.dart';

class TeachingDetailsInfo extends ConsumerWidget {
  const TeachingDetailsInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _headerGradient(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _buildHeader(context),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: userAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text("Error: $err")),
                      data: (user) {
                        if (user == null) {
                          return const Center(child: Text("No data found"));
                        }

                        final data = user.toJson();
                        final professional = data["professional"];
                        final grades = data["grades"] ?? [];
                        final subjects = data["subjects"] ?? [];
                        final workingDays = data["working_days"] ?? [];
                        final workingHours = data["working_hours"] ?? [];

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionCard(
                                title: "Mode of Interest",
                                icon: Icons.school_rounded,
                                children: [
                                  _value(professional?["teaching_mode"]),
                                ],
                              ),

                              _sectionCard(
                                title: "Experience",
                                icon: Icons.timeline_rounded,
                                children: [
                                  _value(
                                    "Offline: ${professional?["offline_exp"] ?? 0} Years",
                                  ),
                                  _value(
                                    "Online: ${professional?["online_exp"] ?? 0} Years",
                                  ),
                                  _value(
                                    "Home Tuition: ${professional?["home_exp"] ?? 0} Years",
                                  ),
                                ],
                              ),

                              _sectionCard(
                                title: "Profession",
                                icon: Icons.work_outline_rounded,
                                children: [_value(professional?["profession"])],
                              ),

                              _sectionCard(
                                title: "Ready to Work",
                                icon: Icons.check_circle_outline,
                                children: [
                                  _value(professional?["ready_to_work"]),
                                ],
                              ),

                              _chipSectionCard(
                                title: "Teaching Grades",
                                icon: Icons.grade_outlined,
                                items: grades
                                    .map<String>((g) => g["grade"].toString())
                                    .toList(),
                              ),

                              _chipSectionCard(
                                title: "Teaching Subjects",
                                icon: Icons.menu_book_rounded,
                                items: subjects
                                    .map<String>((s) => s["subject"].toString())
                                    .toList(),
                              ),

                              _chipSectionCard(
                                title: "Working Days",
                                icon: Icons.calendar_month,
                                items: workingDays
                                    .map<String>((d) => d["day"].toString())
                                    .toList(),
                              ),

                              _chipSectionCard(
                                title: "Working Hours",
                                icon: Icons.schedule_rounded,
                                items: workingHours
                                    .map<String>((t) => t["time_slot"].toString())
                                    .toList(),
                              ),

                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _chipSectionCard({
    required String title,
    required IconData icon,
    required List<String> items,
  }) {
    return _sectionCard(
      title: title,
      icon: icon,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _headerGradient() => Container(
    height: 300,
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [Color(0xFF114887), Color(0xFF6DE899)],
        begin: Alignment.topLeft,
        end: Alignment.centerRight,
      ),
    ),
  );

  Widget _buildHeader(BuildContext context) => Column(
    children: [
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circularButton(
            Icons.arrow_back,
            () => GoRouter.of(context).go('/teacher-dashboard'),
          ),
        ],
      ),
      const SizedBox(height: 30),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Teaching Info",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    ],
  );

  Widget _circularButton(IconData icon, VoidCallback onPressed) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white60),
    child: IconButton(
      icon: Icon(icon, color: Colors.black87),
      iconSize: 20,
      onPressed: onPressed,
    ),
  );

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  );

  Widget _value(String? text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text ?? "--",
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }
}
