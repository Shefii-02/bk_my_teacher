import 'dart:async';
import 'package:BookMyTeacher/presentation/components/badge_label.dart';
import 'package:BookMyTeacher/services/webinar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../model/webinar.dart';
import '../webinars/audience_live_page.dart';
import 'shimmer_image.dart';

class WebinarCard extends ConsumerStatefulWidget {
  final Webinar webinar;
  final VoidCallback? onTap;

  const WebinarCard({super.key, required this.webinar, this.onTap});

  @override
  ConsumerState<WebinarCard> createState() => _WebinarCardState();
}

class _WebinarCardState extends ConsumerState<WebinarCard> {
  Timer? _timer;
  Duration? countdown;

  // Local states
  late bool _isRegistered;
  late bool _canJoin;
  late bool _isEnded;

  @override
  void initState() {
    super.initState();
    _isRegistered = widget.webinar.isRegistered;
    _updateStatus();
    _startStatusTimer();
    _initCountdown();
  }

  void _initCountdown() {
    if (widget.webinar.startAt != null &&
        widget.webinar.startAt!.isAfter(DateTime.now())) {
      countdown = widget.webinar.startAt!.difference(DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            countdown = widget.webinar.startAt!.difference(DateTime.now());
            _updateStatus();
            if (countdown!.inSeconds <= 0) countdown = null;
          });
        }
      });
    }
  }

  void _startStatusTimer() {
    Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _updateStatus();
        });
      }
    });
  }

  void _updateStatus() {
    final now = DateTime.now();
    final startAt = widget.webinar.startAt;
    final endAt = widget.webinar.endAt;

    _canJoin =
        _isRegistered &&
        startAt != null &&
        endAt != null &&
        now.isAfter(startAt) &&
        now.isBefore(endAt);

    _isEnded = endAt != null && now.isAfter(endAt);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webinar = widget.webinar;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                ShimmerImage(
                  imageUrl: webinar.thumbnailUrl,
                  width: 140,
                  height: 80,
                  borderRadius: 8,
                ),
                const SizedBox(height: 10),

                // Countdown
                if (countdown != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${countdown!.inHours.toString().padLeft(2, '0')}:${(countdown!.inMinutes % 60).toString().padLeft(2, '0')}:${(countdown!.inSeconds % 60).toString().padLeft(2, '0')}",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                if (countdown != null) const SizedBox(height: 6),
              ],
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    webinar.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (webinar.description.isNotEmpty) const SizedBox(height: 4),
                  if (webinar.description.isNotEmpty)
                    Text(
                      webinar.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  const SizedBox(height: 4),
                  if (!_isEnded) BadgeLabel(status: webinar.status),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        // Dynamic action button
                        ElevatedButton(
                          onPressed: _canJoin
                              ? () async {
                                  // 1️⃣ Call join API
                                  final response = await ref.read(
                                    webinarJoinProvider(webinar.id).future,
                                  );

                                  if (response['status'] == true) {
                                    final streamData =
                                        response['data']['stream'];
                                    final userID =
                                        'user-${DateTime.now().millisecondsSinceEpoch}'; // unique user id
                                    final userName = 'You'; // Or get from auth

                                    // 2️⃣ Navigate to AudienceLivePage
                                    final credentials =
                                        streamData['credentials']
                                            as Map<String, dynamic>;
                                    final appID =
                                        int.tryParse(
                                          credentials['app_id'].toString(),
                                        ) ??
                                        0;
                                    final appSign = credentials['app_sign']
                                        .toString();

                                    context.push(
                                      '/audience',
                                      extra: {
                                        'appID':
                                            streamData['credentials']['app_id'],
                                        'appSign':
                                            streamData['credentials']['app_sign']
                                                .toString(),
                                        'userID': userID,
                                        'userName': userName,
                                        'liveID': response['data']['live_id']
                                            .toString(),
                                        'isHost': false,
                                        'title': response['data']['title'],
                                        'hostName':
                                            streamData['provider'] ?? '',
                                      },
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          response['message'] ??
                                              'Unable to join.',
                                        ),
                                      ),
                                    );
                                  }
                                  // final response = await ref
                                  //     .read(webinarJoinProvider(webinar.id).future);
                                  // ScaffoldMessenger.of(context).showSnackBar(
                                  //   SnackBar(
                                  //     content: Text(response['status'] == true
                                  //         ? "Joining the class..."
                                  //         : "Waiting for host..."),
                                  //   ),
                                  // );
                                }
                              : _isEnded
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Section Ended!"),
                                    ),
                                  );
                                }
                              : _isRegistered
                              ? () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Already Registered!"),
                                    ),
                                  );
                                }
                              : () async {
                                  final response = await ref.read(
                                    webinarRegisterProvider(webinar.id).future,
                                  );

                                  if (response['status'] == true) {
                                    setState(() {
                                      _isRegistered = true;
                                    });
                                    ref.invalidate(webinarListProvider);
                                  }

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response['message'] ??
                                            'Registered Successfully!',
                                      ),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _canJoin
                                ? Colors.green
                                : _isEnded
                                ? Colors.deepOrangeAccent
                                : _isRegistered
                                ? Colors.deepPurpleAccent
                                : Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            minimumSize: const Size(80, 30),
                          ),
                          child: Text(
                            _isEnded
                                ? "Class Ended"
                                : _canJoin
                                ? 'Join Class'
                                : _isRegistered
                                ? 'Registered'
                                : 'Register',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // More Details button
                        ElevatedButton(
                          onPressed: () {
                            context.push(
                              '/webinars/${webinar.id}',
                              extra: webinar,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            minimumSize: const Size(80, 30),
                          ),
                          child: const Text(
                            'More Details',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
