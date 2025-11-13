
import 'package:flutter/material.dart';

import '../../core/constants/endpoints.dart';
// -------------------- Subject Carousel 3x3 --------------------
class InviteFriendsCard extends StatelessWidget {
  const InviteFriendsCard({super.key});


  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Image(
            image: const NetworkImage(
              "${Endpoints.domain}/assets/mobile-app/icons/gift-box.png",
            ),
            width: 70,
            height: 70,
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Invite friends & earn rewards!')),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            ),
            child: Row(
              children: [
                const Text(
                  'Refer Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.share, color: Colors.white, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}