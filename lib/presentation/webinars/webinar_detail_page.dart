import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../model/webinar.dart';
import '../../services/webinar_service.dart';
import '../components/badge_label.dart';
import '../components/shimmer_image.dart';
import 'audience_live_page.dart';

class WebinarDetailPage extends ConsumerStatefulWidget {
  final Webinar webinar;
  const WebinarDetailPage({super.key, required this.webinar});

  @override
  ConsumerState<WebinarDetailPage> createState() => _WebinarDetailPageState();
}

class _WebinarDetailPageState extends ConsumerState<WebinarDetailPage> {
  Timer? _timer;
  Duration? countdown;

  // Local state
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

  // Initialize countdown timer for webinar start
  void _initCountdown() {
    if (widget.webinar.startAt != null &&
        widget.webinar.startAt!.isAfter(DateTime.now())) {
      countdown = widget.webinar.startAt!.difference(DateTime.now());
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            countdown = widget.webinar.startAt!.difference(DateTime.now());
            _updateStatus();
            if (countdown!.inSeconds <= 0) {
              countdown = null;
            }
          });
        }
      });
    }
  }

  // Periodically update webinar status (join / end)
  void _startStatusTimer() {
    Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _updateStatus();
        });
      }
    });
  }

  // Update local status flags
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
    final now = DateTime.now();
    final startAt = webinar.startAt;
    final endAt = webinar.endAt;
    final regEnd = webinar.registerEndAt;
    final canRegister = regEnd == null || now.isBefore(regEnd);

    final DateFormat formatter = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Scrollable content
            Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero image
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      child: ShimmerImage(
                        imageUrl: webinar.mainImageUrl ?? webinar.thumbnailUrl,
                        width: double.infinity,
                        height: 450,
                        borderRadius: 0,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title + Status
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              webinar.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          BadgeLabel(status: webinar.status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Description
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        webinar.description ?? '',
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Start / End Chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Wrap(
                        spacing: 10,
                        children: [
                          if (startAt != null)
                            Chip(
                              label: Text(
                                "Start: ${formatter.format(startAt.toLocal())}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              backgroundColor: Colors.deepPurple.shade50,
                            ),
                          if (endAt != null)
                            Chip(
                              label: Text(
                                "End: ${formatter.format(endAt.toLocal())}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              backgroundColor: Colors.deepPurple.shade50,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Back Button
            Positioned(
              top: 18,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ref.invalidate(webinarListProvider);
                  },
                ),
              ),
            ),

            // Countdown Timer (Top Right)
            if (countdown != null)
              Positioned(
                top: 18,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Starts in: ${countdown!.inHours.toString().padLeft(2, '0')}:${(countdown!.inMinutes % 60).toString().padLeft(2, '0')}:${(countdown!.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),

            // Bottom Buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Register button
                      if (!_isRegistered && canRegister && !_isEnded)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final response = await ref.read(
                                webinarRegisterProvider(webinar.id).future,
                              );
                              if (response['status'] == true) {
                                // 🔄 refresh webinar list
                                ref.invalidate(webinarListProvider);
                                setState(() {
                                  _isRegistered = true;
                                });
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    response['message'] ?? 'Registered',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Register",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                      // Registration closed
                      if (!_isRegistered && !canRegister && !_isEnded)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Row(
                                    children: [
                                      Text("Registration has ended!"),
                                      Icon(Icons.not_interested_rounded),
                                    ],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade400,
                            ),
                            child: const Text(
                              "Registration Closed",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                      // Already registered
                      if (_isRegistered && !_canJoin && !_isEnded)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check, color: Colors.white),
                            label: const Text(
                              "Registered",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                            ),
                          ),
                        ),

                      // Join Class
                      if (_isRegistered && _canJoin)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              // 1️⃣ Call join API
                              final response = await ref.read(
                                webinarJoinProvider(webinar.id).future,
                              );
                              print(response['data']);
                              if (response['status'] == true) {
                                final streamData = response['data']['stream'];
                                final userID =
                                    'user-${DateTime.now().millisecondsSinceEpoch}'; // unique user id
                                final userName = 'You'; // Or get from auth

                                // 2️⃣ Navigate to AudienceLivePage
                                final credentials = streamData['credentials'] as Map<String, dynamic>;
                                final appID = int.tryParse(credentials['app_id'].toString()) ?? 0;
                                final appSign = credentials['app_sign'].toString();

                                context.push(
                                  '/audience',
                                  extra: {
                                    'appID': streamData['credentials']['app_id'],
                                    'appSign': streamData['credentials']['app_sign'].toString(),
                                    'userID': userID,
                                    'userName': userName,
                                    'liveID': response['data']['live_id'].toString(),
                                    'isHost': false,
                                    'title': response['data']['title'],
                                    'hostName': streamData['provider'] ?? '',
                                  },
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      response['message'] ?? 'Unable to join.',
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text(
                              "Join Class",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),

                      // Webinar ended
                      if (_isEnded)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Class has ended. Watch recording.",
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade700,
                            ),
                            child: const Text(
                              "Class Ended",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
