import 'dart:async';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';

class AnimatedSearchDashboard extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> searchData;
  const AnimatedSearchDashboard({super.key, required this.searchData});

  @override
  State<AnimatedSearchDashboard> createState() => _AnimatedSearchDashboardState();
}

class _AnimatedSearchDashboardState extends State<AnimatedSearchDashboard> {
  final TextEditingController _controller = TextEditingController();
  late Timer _timer;
  int _hintIndex = 0;

  final List<String> _categories = ['teachers', 'grades', 'boards', 'subjects', 'skills'];
  Map<String, List<Map<String, dynamic>>> _filtered = {};

  @override
  void initState() {
    super.initState();

    _filtered = {};
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _hintIndex = (_hintIndex + 1) % _categories.length;
      });
    });

    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final input = _controller.text.toLowerCase();
    Map<String, List<Map<String, dynamic>>> temp = {};
    widget.searchData.forEach((key, list) {
      final filteredList = list.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(input);
      }).toList();
      if (filteredList.isNotEmpty) temp[key] = filteredList;
    });
    setState(() {
      _filtered = temp;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ---------- Animated Search Field ----------
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12.withOpacity(0.05), blurRadius: 6)],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                      ),
                    ),
                    Positioned(
                      left: 0,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: _controller.text.isEmpty
                            ? Text(
                          'Search ${_categories[_hintIndex]}',
                          key: ValueKey(_hintIndex),
                          style: TextStyle(color: Colors.grey.shade400),
                        )
                            : const SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ---------- Filtered Result List ----------
        Expanded(
          child: _filtered.isEmpty && _controller.text.isEmpty
              ? Center(child: Text('Start typing to search'))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _filtered.entries.map((entry) {
                final category = entry.key;
                final items = entry.value;
                return items.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category[0].toUpperCase() + category.substring(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: items.map((item) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 400),
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(item['name'] ?? ''),
                              subtitle: Text(item['extra'] ?? ''),
                              onTap: () {
                                // Redirect to single page
                                context.push('/${category}/${item['id']}');
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
