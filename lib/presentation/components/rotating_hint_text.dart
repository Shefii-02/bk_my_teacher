import 'package:flutter/material.dart';

class RotatingHintText extends StatefulWidget {
  final List<String> hints;
  const RotatingHintText({super.key, required this.hints});

  @override
  State<RotatingHintText> createState() => _RotatingHintTextState();
}

class _RotatingHintTextState extends State<RotatingHintText> {
  int index = 0;

  @override
  void initState() {
    super.initState();
    _startRotation();
  }

  void _startRotation() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        index = (index + 1) % widget.hints.length;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20, // 🔥 IMPORTANT: Fix height to avoid jump
      width: double.infinity,
      child: ClipRect(
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final isIncoming = child.key == ValueKey(widget.hints[index]);

              if (isIncoming) {
                // 🔥 New text comes from bottom
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              } else {
                // 🔥 Old text goes up
                // return SlideTransition(
                //   position: Tween<Offset>(
                //     begin: Offset.zero,
                //     end: const Offset(0, -1),
                //   ).animate(animation),
                //   child: child,
                // );
                return SizedBox();
              }
            },
            child: Text(
              widget.hints[index],
              key: ValueKey(widget.hints[index]),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
