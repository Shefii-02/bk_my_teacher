import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../services/api_service.dart';

class JoinCommunitySheet extends StatefulWidget {
  const JoinCommunitySheet({super.key});

  @override
  State<JoinCommunitySheet> createState() => _JoinCommunitySheetState();
}

class _JoinCommunitySheetState extends State<JoinCommunitySheet> {
  List<dynamic> _communities = [];

  @override
  void initState() {
    super.initState();
    _loadCommunities();
  }

  Future<void> _loadCommunities() async {
    final data = await ApiService().fetchCommunityLinks(); // same API
    setState(() {
      _communities = data;
    });
  }

  void _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.inAppWebView);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _communities.isEmpty
          ? const Center(child: CircularProgressIndicator()) // loading
          : Wrap(
        runSpacing: 15,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Join Our Community",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Stay connected and grow with others! Join our online communities below.",
          ),
          const SizedBox(height: 10),

          // Dynamically generated list tiles
          ..._communities.map((item) {
            return ListTile(
              leading: Image.network(
                item['icon'],
                width: 30,
                height: 30,
              ),
              title: Text(item['name'] ?? "Community"),
              onTap: () => _openLink(item['link']),
            );
          }).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
