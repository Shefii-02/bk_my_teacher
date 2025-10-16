import 'package:flutter/material.dart';

class BadgeLabel extends StatelessWidget {
  final double borderRadius;
  final String status;

  const BadgeLabel({
    super.key,
    required this.status,
    this.borderRadius = 8,
  });

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green.shade100;
      case 'scheduled':
        return Colors.greenAccent.shade100;
      case 'completed':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'live':
        return Colors.green.shade800;
      case 'scheduled':
        return Colors.blue.shade800;
      case 'completed':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Text(
        status.capitalize(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _getTextColor(),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
