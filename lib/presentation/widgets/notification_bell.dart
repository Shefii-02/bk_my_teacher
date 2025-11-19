import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';

class NotificationBell extends ConsumerWidget {
  final VoidCallback onTap;

  const NotificationBell({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(notificationProvider);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications,
            size: 30,
            color: Colors.grey[800],
          ),
          onPressed: onTap,
        ),

        asyncData.when(
          data: (data) {
            if (data.count == 0) return SizedBox();

            return Positioned(
              right: 2,
              top: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle),
                child: Text(
                  data.count.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            );
          },
          loading: () => SizedBox(),
          error: (_, __) => SizedBox(),
        ),
      ],
    );
  }
}
