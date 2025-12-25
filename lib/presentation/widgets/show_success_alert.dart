import 'dart:async';
import 'package:flutter/material.dart';
import 'package:BookMyTeacher/presentation/widgets/connect_with_team.dart';

class ShowSuccessAlert extends StatefulWidget {
  final String title;
  final String subtitle;
  final int timer;
  final Color color;
  final bool showButton;

  const ShowSuccessAlert({
    super.key,
    required this.title,
    required this.subtitle,
    required this.timer,
    required this.color,
    this.showButton = true,
  });

  @override
  State<ShowSuccessAlert> createState() => _ShowSuccessAlertState();
}

class _ShowSuccessAlertState extends State<ShowSuccessAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();

    // Auto close after given seconds
    Timer(Duration(seconds: widget.timer), () {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ✖️ Close Icon (Top Right)
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black54, size: 24),
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),

          const SizedBox(height: 8),

          // ✅ Animated Tick Icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 38),
            ),
          ),
          const SizedBox(height: 18),

          // 🎉 Title
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: widget.color,
            ),
          ),
          const SizedBox(height: 8),

          // 📄 Subtitle
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // 🔘 Optional Button
          if (widget.showButton)
            SizedBox(width: double.infinity, child: ConnectWithTeam()),
        ],
      ),
    );
  }
}

/// 🔹 Helper Function to Show the Alert
 showSuccessAlert(
    BuildContext context, {
      required String title,
      required String subtitle,
      required int timer,
      required Color color,
      bool showButton = true,
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.black.withOpacity(0.3),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: ShowSuccessAlert(
        title: title,
        subtitle: subtitle,
        timer: timer,
        color: color,
        showButton: showButton,
      ),
    ),
  );
}
