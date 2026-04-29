import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';

class NotificationBell extends ConsumerWidget {

  final VoidCallback onTap;

  const NotificationBell({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {

    final asyncData =
    ref.watch(notificationProvider);

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

          loading: () =>
              SizedBox(),

          error: (_, __) =>
              SizedBox(),

          data: (data) {

            final count = data.count;

            if (count <= 0) {
              return SizedBox();
            }

            return Positioned(
              right: 2,
              top: 2,
              child: Container(

                padding: EdgeInsets.all(4),

                constraints:
                BoxConstraints(
                  minWidth: 18,
                  minHeight: 18,
                ),

                decoration:
                BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),

                child: Text(
                  count > 99
                      ? '99+'
                      : count.toString(),

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}