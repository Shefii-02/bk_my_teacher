import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../core/constants/endpoints.dart';
import '../../services/api_service.dart';
import '../../services/launch_status_service.dart';
import '../widgets/invite_bottom_sheet.dart';
import '../widgets/show_success_alert.dart';

class InviteFriendsCard extends StatelessWidget {
  const InviteFriendsCard({super.key});



  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: Text(
                    "Invite Friends & Earn Rewards!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openInviteSheet(context),
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  void _openInviteSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InviteBottomSheet(),
    );
  }
}
