import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchResultPage extends StatelessWidget {
  final Map<String, dynamic> result;

  const SearchResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(context, 'Teachers', result['teachers'] ?? [], (item) {
              context.go('/teacher/${item['id']}');
            }),
            _buildSection(context, 'Subjects', result['subjects'] ?? [], (item) {
              context.go('/subject/${item['id']}');
            }),
            _buildSection(context, 'Grades', result['grades'] ?? [], (item) {
              context.go('/grade/${item['id']}');
            }),
            _buildSection(context, 'Boards', result['boards'] ?? [], (item) {
              context.go('/board/${item['id']}');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<dynamic> items, Function(Map<String, dynamic>) onTap) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              leading: item['image'] != null
                  ? CircleAvatar(backgroundImage: NetworkImage(item['image']))
                  : null,
              title: Text(item['name'] ?? ''),
              subtitle: item['qualification'] != null ? Text(item['qualification']) : null,
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => onTap(item),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
