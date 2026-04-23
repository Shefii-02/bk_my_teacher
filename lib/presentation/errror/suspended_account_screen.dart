import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONFIG — change these as needed
// ─────────────────────────────────────────────────────────────────────────────
const String kAdminWhatsApp = '917510115544'; // country code + number, no +
const String kSuspendedReason = 'Policy violation';
const String kSuspendedSince = 'April 18, 2026';

class SuspendedAccountScreen extends StatefulWidget {
  const SuspendedAccountScreen({super.key});

  @override
  State<SuspendedAccountScreen> createState() => _SuspendedAccountScreenState();
}

class _SuspendedAccountScreenState extends State<SuspendedAccountScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _scanController;
  late AnimationController _shieldPulseController;

  late Animation<double> _floatAnim;
  late Animation<double> _scanAnim;
  late Animation<double> _shieldPulseAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _shieldPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _scanAnim = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _shieldPulseAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _shieldPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _scanController.dispose();
    _shieldPulseController.dispose();
    super.dispose();
  }

  Future<void> _openWhatsApp() async {
    final message = Uri.encodeComponent(
      'Hello, my account has been suspended. I would like to appeal this decision.',
    );
    final url = Uri.parse('https://wa.me/$kAdminWhatsApp?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp. Please check if it is installed.'),
            backgroundColor: Color(0xFF7F1D1D),
          ),
        );
      }
    }
  }

  Future<void> _openAppeal() async {
    // Same WhatsApp with a different pre-filled message
    final message = Uri.encodeComponent(
      'Hi, I want to appeal my account suspension. Reason shown: $kSuspendedReason.',
    );
    final url = Uri.parse('https://wa.me/$kAdminWhatsApp?text=$message');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp.'),
            backgroundColor: Color(0xFF7F1D1D),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A1E),
      body: Stack(
        children: [
          // ── Background orbs ───────────────────────────────────────
          Positioned(
            top: -100, left: -80,
            child: _GlowOrb(color: const Color(0xFF7F1D1D), size: 320),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: _GlowOrb(color: const Color(0xFF450A0A), size: 280),
          ),

          // ── Grid ─────────────────────────────────────────────────
          const Positioned.fill(child: _BackgroundGrid()),

          // ── Scan line ────────────────────────────────────────────
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) {
              final h = MediaQuery.of(context).size.height;
              return Positioned(
                top: _scanAnim.value * h - 40,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFEF4444).withOpacity(0.04),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Main content ──────────────────────────────────────────
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Shield illustration
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      ),
                      child: AnimatedBuilder(
                        animation: _shieldPulseAnim,
                        builder: (_, __) => SizedBox(
                          width: 160,
                          height: 160,
                          child: CustomPaint(
                            painter: _ShieldPainter(
                              pulseOpacity: _shieldPulseAnim.value,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFF87171), Color(0xFFFB923C)],
                      ).createShader(bounds),
                      child: const Text(
                        'Account Suspended',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Your account has been temporarily restricted.\nPlease review the details below.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.65,
                        color: Colors.white.withOpacity(0.38),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Info box
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.07),
                        border: Border.all(
                          color: const Color(0xFFEF4444).withOpacity(0.2),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(label: 'Reason', value: kSuspendedReason),
                          _InfoRow(label: 'Status', value: 'Suspended'),
                          _InfoRow(
                            label: 'Since',
                            value: kSuspendedSince,
                            isLast: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1212),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _BlinkingDot(),
                          const SizedBox(width: 8),
                          Text(
                            'Account access is currently disabled',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Appeal button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _openAppeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Appeal This Decision',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Contact Support button → WhatsApp
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _openWhatsApp,
                        icon: const _WhatsAppIcon(),
                        label: const Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF86EFAC),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: const Color(0xFF25D366).withOpacity(0.35),
                            width: 0.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Dots loader
                    const _DotsLoader(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Row
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
          bottom: BorderSide(
            color: const Color(0xFFEF4444).withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.35),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFFEF4444),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shield Painter
// ─────────────────────────────────────────────────────────────────────────────
class _ShieldPainter extends CustomPainter {
  final double pulseOpacity;
  _ShieldPainter({required this.pulseOpacity});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow rings
    canvas.drawCircle(
      Offset(cx, cy),
      62,
      Paint()
        ..color = const Color(0xFFDC2626).withOpacity(0.08 * pulseOpacity)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      48,
      Paint()
        ..color = const Color(0xFFDC2626).withOpacity(0.1 * pulseOpacity)
        ..style = PaintingStyle.fill,
    );

    // Shield path
    final shield = Path();
    shield.moveTo(cx, cy - 44);
    shield.lineTo(cx - 28, cy - 34);
    shield.lineTo(cx - 28, cy - 4);
    shield.quadraticBezierTo(cx - 28, cy + 24, cx, cy + 38);
    shield.quadraticBezierTo(cx + 28, cy + 24, cx + 28, cy - 4);
    shield.lineTo(cx + 28, cy - 34);
    shield.close();

    canvas.drawPath(
      shield,
      Paint()
        ..color = const Color(0xFFDC2626).withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      shield,
      Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );

    // X mark
    final xPaint = Paint()
      ..color = const Color(0xFFF87171)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(cx - 11, cy - 11),
      Offset(cx + 11, cy + 11),
      xPaint,
    );
    canvas.drawLine(
      Offset(cx + 11, cy - 11),
      Offset(cx - 11, cy + 11),
      xPaint,
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.pulseOpacity != pulseOpacity;
}

// ─────────────────────────────────────────────────────────────────────────────
// WhatsApp Icon (drawn with Canvas — no asset needed)
// ─────────────────────────────────────────────────────────────────────────────
class _WhatsAppIcon extends StatelessWidget {
  const _WhatsAppIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _WhatsAppIconPainter()),
    );
  }
}

class _WhatsAppIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Circle bg
    canvas.drawCircle(
      c, r,
      Paint()..color = const Color(0xFF25D366),
    );

    // Simple phone/chat shape
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // Bubble outline
    final bubble = Path();
    bubble.addOval(Rect.fromCircle(center: c, radius: r * 0.62));
    canvas.drawPath(
      bubble,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );

    // Tail
    canvas.drawLine(
      Offset(c.dx - r * 0.25, c.dy + r * 0.55),
      Offset(c.dx - r * 0.55, c.dy + r * 0.78),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Blinking Dot
// ─────────────────────────────────────────────────────────────────────────────
class _BlinkingDot extends StatefulWidget {
  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.2, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFF87171).withOpacity(_anim.value),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dots Loader
// ─────────────────────────────────────────────────────────────────────────────
class _DotsLoader extends StatefulWidget {
  const _DotsLoader();

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  static const _colors = [
    Color(0xFFF87171),
    Color(0xFFFB923C),
    Color(0xFFFBBF24),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = (_ctrl.value - i / 3) % 1.0;
            final opacity = phase < 0.33 ? 1.0 : 0.2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _colors[i].withOpacity(opacity),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background Grid
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundGrid extends StatelessWidget {
  const _BackgroundGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GridPainter());
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Glow Orb
// ─────────────────────────────────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;
  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.5), Colors.transparent],
        ),
      ),
    );
  }
}