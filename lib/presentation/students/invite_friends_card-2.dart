import 'package:BookMyTeacher/services/launch_status_service.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_share/flutter_share.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/constants/endpoints.dart';
import '../../services/api_service.dart';
import '../widgets/show_success_alert.dart';

class InviteFriendsCard extends StatelessWidget {
  const InviteFriendsCard({super.key});

  Future<String> _referralCode(BuildContext context) {
    // In production, fetch from API or user session
    final refCode = LaunchStatusService.getReferralCode();
    return refCode;
  }

  @override
  Widget build(BuildContext context) {
    final code = _referralCode(context);
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Row(
          children: [
            Image.network(
              "${Endpoints.domain}/assets/mobile-app/icons/gift-box.png",
              width: 70,
              height: 70,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Invite Friends & Earn Rewards!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Share your referral code and earn Green Coins when friends join.",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async => _openInviteSheet(context, await code),
              icon: const Icon(Icons.share, color: Colors.white, size: 20),
              label: const Text(
                'Refer Now',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openInviteSheet(BuildContext context, String code) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InviteBottomSheet(referralCode: code),
    );
  }
}

class InviteBottomSheet extends StatefulWidget {
  final String referralCode;
  const InviteBottomSheet({super.key, required this.referralCode});

  @override
  State<InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<InviteBottomSheet> {
  bool sending = false;
  List<Contact> contacts = [];
  bool contactsLoaded = false;
  final formatter = NumberFormat('#,###');

  String get _shortUrl =>
      "${Endpoints.domain}/invite?ref=${widget.referralCode}";

  Future<void> _shareGeneral() async {
    final title = "Join me on BookMyTeacher";
    final message =
        "$title — Use my referral code ${widget.referralCode} to sign up and earn rewards!\n\nJoin here: $_shortUrl";
    SharePlus.instance.share(
      ShareParams(text: message),
    );
  }

  Future<void> _copyCode() async {
    try {
      await FlutterClipboard.copy(widget.referralCode);
      showSuccessAlert(
        context,
        title: "Copied",
        subtitle: 'Referral Code copied successfully!',
        timer: 3,
        color: Colors.green,
        showButton: false, // 👈 hide/show button easily
      );
    } on ClipboardException catch (e) {
      showSuccessAlert(
        context,
        title: "failed",
        subtitle: 'Copy failed: ${e.message}',
        timer: 3,
        color: Colors.red,
        showButton: false, // 👈 hide/show button easily
      );
    }
    // await FlutterShare.copyToClipboard();
  }

  Future<void> _shareToWhatsApp() async {
    final title = "Join me on BookMyTeacher";
    final message =
        "$title — Use my referral code ${widget.referralCode} to sign up and earn rewards!\n\nJoin here: $_shortUrl";

    final text = Uri.encodeComponent(message);
    final whatsapp = Uri.parse("whatsapp://send?text=$text");
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp);
      await ApiService().recordReferralShare(widget.referralCode, method: 'whatsapp');
    } else {
      // fallback: open standard share sheet
      await _shareGeneral();
    }
  }
  Future<void> _openSmsComposer() async {
    final uri = Uri.parse(
      "sms:?body=${Uri.encodeComponent("Join BookMyTeacher App using my referral code ${widget.referralCode}\n$_shortUrl")}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await ApiService().recordReferralShare(
        widget.referralCode,
        method: 'sms',
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open SMS app')));
    }
  }

  Future<void> _importContacts() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact permission denied')),
      );
      return;
    }
    try {
      final data = await FlutterContacts.getContacts(withProperties: true);

      setState(() {
        contacts = data;
        contactsLoaded = true;
      });

    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load contacts: $e')));
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
        children: const [
          Text(
            "💰 Earn Green Coins",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "• 100 coins when your friend joins\n• 50 extra coins when they join first class\n• Track your invites in Rewards → Invited List",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Future<void> _sendInvite(Contact c) async {
    final status = await Permission.contacts.request();
    if (status.isGranted) {
      // TODO: Fetch contacts & send through backend API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Contacts permission granted"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied"),
        ),
      );
    }
    if (c.phones.isEmpty) return;
    final phone = c.phones.first.number;
    final uri = Uri.parse(
      "sms:$phone?body=${Uri.encodeComponent("Join SkillStack using my referral code ${widget.referralCode}\n$_shortUrl")}",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      await ApiService().recordReferralShare(
        widget.referralCode,
        method: 'contact_sms',
      );
    }
  }

  Widget _contactList() {
    if (!contactsLoaded) {
      return ElevatedButton.icon(
        onPressed: _importContacts,
        icon: const Icon(Icons.contacts,color: Colors.white,),
        label: const Text('Import Contacts',style: TextStyle(color: Colors.white),),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
      );
    }
    if (contacts.isEmpty) {
      return const Text("No contacts found");
    }
    return SizedBox(
      height: 300,
      child: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (_, i) {
          final c = contacts[i];
          final phone = c.phones.isNotEmpty ? c.phones.first.number : '';
          return ListTile(
            leading: const Icon(Icons.person, color: Colors.teal),
            title: Text(c.displayName),
            subtitle: Text(phone),
            trailing: IconButton(
              onPressed: () => _sendInvite(c),
              icon: const Icon(Icons.send, color: Colors.green),
            ),
          );
        },
      ),
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
        child: ListView(
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
                    "Invite Friends & Earn Green Coins",
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your Code: ${widget.referralCode}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Tap below to share your link.",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
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
                    icon: const Icon(Icons.sms,color: Colors.white,),
                    label: const Text("Send Whatsapp",style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            // const Text(
            //   "Invite via Contacts",
            //   style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            // ),
            // const SizedBox(height: 10),
            // _contactList(),
            // const Divider(height: 30),
            const Text(
              "Referral Rewards",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: Colors.green),
              title: const Text("You earned"),
              trailing: Text(
                "${formatter.format(1200)} Green Coins",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blueAccent),
              title: const Text("Friends joined"),
              trailing: Text(
                "${formatter.format(18)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("How it works"),
              subtitle: const Text(
                "For each friend who joins using your link/code, you earn Green Coins. Coins can be converted to rewards or wallet credits.",
              ),
            ),
            const SizedBox(height: 20),
            _buildRewardInfo()
          ],
        ),
      ),
    );
  }
}
