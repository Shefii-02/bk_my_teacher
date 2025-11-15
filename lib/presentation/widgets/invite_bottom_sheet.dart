import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/constants/endpoints.dart';
import '../../services/api_service.dart';
import '../widgets/show_success_alert.dart';


class InviteBottomSheet extends StatefulWidget {
  const InviteBottomSheet({super.key});

  @override
  State<InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<InviteBottomSheet> {
  bool loading = true;
  Map<String, dynamic> stats = {};
  final formatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    try {
      final response = await ApiService().referralStats();
      print(response);

      setState(() {
        stats = response ?? {};
        loading = false;
      });

    } catch (e) {
      debugPrint("Error fetching stats: $e");
      setState(() => loading = false);
    }
  }

  Widget _buildRewardInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children:  [
          Text(
            stats['badge_title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            stats['badge_description'],
            // "• 100 coins when your friend joins\n• 50 extra coins when they join first class\n• Track your invites in Rewards → Invited List",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String get _shortUrl => "${Endpoints.domain}/invite?ref=${stats['referral_code']}";

  Future<void> _copyCode() async {
    await FlutterClipboard.copy(stats['referral_code']);
    showSuccessAlert(
      context,
      title: "Copied!",
      subtitle: "Referral Code copied successfully",
      color: Colors.green,
      timer: 2,
      showButton: false,
    );
  }

  Future<void> _shareGeneral() async {
    final message =
        "Join me on BookMyTeacher! Use my referral code ${stats['referral_code']} to sign up and earn rewards.\n\n$_shortUrl";
    await Share.share(message);
  }

  Future<void> _shareToWhatsApp() async {
    final message =
        "Join BookMyTeacher using my referral code ${stats['referral_code']} and earn rewards!\n$_shortUrl";
    final url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      await _shareGeneral();
    }
  }

  Future<void> _showInvitedFriends() async {
    final friends = stats['friends_list'] ?? [];
    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No invited friends yet")),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Invited Friends (${friends.length})",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (_, i) {
                    final f = friends[i];
                    final status = f['status'] ?? 'pending';
                    Color color;
                    if (status == 'completed') color = Colors.blue;
                    else if (status == 'joined') color = Colors.green;
                    else color = Colors.grey;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.2),
                          child: Icon(Icons.person, color: color),
                        ),
                        title: Text(f['name'] ?? 'Unknown'),
                        subtitle: Text("Joined: ${f['joined_at']}"),
                        trailing: Text(
                          "+${f['earned_coins']}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          controller: scrollController,
          children: [
            Center(
              child: Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Invite Friends & Earn Coins",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.lightGreen, Colors.greenAccent],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Image.network(
                    "${Endpoints.domain}/assets/mobile-app/icons/gift-box.png",
                    height: 70,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Your Code: ${stats['referral_code']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareGeneral,
                    icon: const Icon(Icons.share),
                    label: const Text("Share Link"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareToWhatsApp,
                    icon: const Icon(Icons.chat, color: Colors.white),
                    label: const Text("Send WhatsApp", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.green),
              title: const Text("You earned"),
              trailing: Text(
                "${formatter.format(stats['earned_coins'] ?? 0)} Green Coins",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blueAccent),
              title: const Text("Friends joined"),
              trailing: Text(
                formatter.format(stats['friends_joined'] ?? 0),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            TextButton.icon(
              onPressed: _showInvitedFriends,
              icon: const Icon(Icons.list_alt, color: Colors.teal),
              label: const Text("View Invited Friends"),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title:  Text(stats["how_it_works"]),
              subtitle: Text(
                stats['how_it_works_description'] ?? "",
              ),
            ),
            const SizedBox(height: 8),
            _buildRewardInfo()
          ],
        ),
      ),
    );
  }
}
