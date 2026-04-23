import 'package:flutter/material.dart';

class ProfileOptionTile extends StatefulWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final String? badge;
  final VoidCallback onTap;

  const ProfileOptionTile({
    super.key,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  State<ProfileOptionTile> createState() => _ProfileOptionTileState();
}

class _ProfileOptionTileState extends State<ProfileOptionTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFFEDE9F8) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 18),
            ),
            const SizedBox(width: 14),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1226),
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9089A8),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Optional badge
            if (widget.badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C5CFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.badge!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ],

            // Arrow
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFC4BCD8),
            ),
          ],
        ),
      ),
    );
  }
}