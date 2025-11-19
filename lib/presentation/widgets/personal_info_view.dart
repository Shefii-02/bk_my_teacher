import 'package:BookMyTeacher/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PersonalInfoView extends ConsumerWidget {
  const PersonalInfoView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    if (userAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = userAsync.value;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user data found")),
      );
    }

    final data = user.toJson();

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
                  child: _infoContainer(data),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _infoContainer(Map<String, dynamic> data) {
    return Container(
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _avatar(data['avatar_url']),
            const SizedBox(height: 20),
            _item("Full Name", data['name']),
            _item("Email", data['email']),
            _item("Address", data['address']),
            _item("City", data['city']),
            _item("Postal Code", data['postal_code'].toString()),
            _item("District", data['district']),
            _item("State", data['state']),
            _item("Country", data['country']),
            const SizedBox(height: 30),
            // _editButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? url) {
    return CircleAvatar(
      radius: 55,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: (url != null && url.isNotEmpty)
          ? NetworkImage(url)
          : null,
      child: (url == null || url.isEmpty)
          ? Icon(Icons.person, size: 60, color: Colors.grey.shade500)
          : null,
    );
  }

  Widget _item(String title, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value ?? "-",
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _editButton() => SizedBox(
  //   width: double.infinity,
  //   child: ElevatedButton(
  //     onPressed: () => GoRouter.of(context).push('/profile/edit/personal-info'),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.green,
  //       padding: const EdgeInsets.symmetric(vertical: 15),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //     ),
  //     child: const Text(
  //       "Edit Info",
  //       style: TextStyle(fontSize: 16, color: Colors.white),
  //     ),
  //   ),
  // );

  Widget _buildHeader(BuildContext context) => Column(
    children: [
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circularButton(Icons.arrow_back,
                  () => GoRouter.of(context).go('/teacher-dashboard')),
        ],
      ),
      const SizedBox(height: 30),
      const Align(
        alignment: Alignment.centerLeft,
        child: Text(
          "Personal Info",
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
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white60,
    ),
    child: IconButton(
      icon: Icon(icon, color: Colors.black87),
      iconSize: 20,
      onPressed: onPressed,
    ),
  );
}
