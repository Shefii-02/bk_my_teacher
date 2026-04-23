import 'package:flutter/material.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _gear1Controller;
  late AnimationController _gear2Controller;
  late AnimationController _gear3Controller;
  late AnimationController _scanController;
  late AnimationController _progressController;

  late Animation<double> _floatAnim;
  late Animation<double> _scanAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..repeat(reverse: true);

    _gear1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _gear2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: false);

    _gear3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..forward();

    _floatAnim = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _scanAnim = Tween<double>(begin: -0.1, end: 1.1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );

    _progressAnim = Tween<double>(begin: 0, end: 0.74).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _gear1Controller.dispose();
    _gear2Controller.dispose();
    _gear3Controller.dispose();
    _scanController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF888888),
      body: Stack(
        children: [
          // ── Background orbs ───────────────────────────────────────
          Positioned(
            top: -100, left: -80,
            child: _GlowOrb(color: const Color(0xFF50CC8A), size: 320),
          ),
          Positioned(
            bottom: -80, right: -80,
            child: _GlowOrb(color: const Color(0xFF24CAAC), size: 280),
          ),

          // ── Grid ─────────────────────────────────────────────────
          Positioned.fill(child: const _BackgroundGrid()),

          // ── Scan line ────────────────────────────────────────────
          AnimatedBuilder(
            animation: _scanAnim,
            builder: (_, __) {
              final h = MediaQuery.of(context).size.height;
              return Positioned(
                top: _scanAnim.value * h - 40,
                left: 0, right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        const Color(0xFFA78BFA).withOpacity(0.04),
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Gear illustration
                    AnimatedBuilder(
                      animation: _floatAnim,
                      builder: (_, child) => Transform.translate(
                        offset: Offset(0, _floatAnim.value),
                        child: child,
                      ),
                      child: SizedBox(
                        width: 200,
                        height: 180,
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _gear1Controller,
                            _gear2Controller,
                            _gear3Controller,
                          ]),
                          builder: (_, __) => CustomPaint(
                            painter: _GearPainter(
                              gear1Angle: _gear1Controller.value * 2 * 3.14159,
                              gear2Angle: -_gear2Controller.value * 2 * 3.14159,
                              gear3Angle: _gear3Controller.value * 2 * 3.14159,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF5AC142), Color(0xFFC0F3D6)],
                      ).createShader(bounds),
                      child: const Text(
                        'Under Maintenance',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      "We're upgrading things for you.\nBack shortly — hang tight!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Progress bar
                    AnimatedBuilder(
                      animation: _progressAnim,
                      builder: (_, __) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  color: const Color(0xFFFDFCFF),
                                ),
                                FractionallySizedBox(
                                  widthFactor: _progressAnim.value,
                                  child: Container(
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF50CC8A),
                                          Color(0xFFC0F3D6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${(_progressAnim.value * 100).toInt()}% complete',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFAFAFA),
                                ),
                              ),
                              Text(
                                'Est. ~2 hrs',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Status chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF888888),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          _BlinkingDot(),
                          const SizedBox(width: 10),
                          Text(
                            'System update in progress',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Notify button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // push to notify api alert server ready
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC0F3D6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Notify Me When Ready',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            letterSpacing: 0.3,
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
// Gear Painter
// ─────────────────────────────────────────────────────────────────────────────
class _GearPainter extends CustomPainter {
  final double gear1Angle;
  final double gear2Angle;
  final double gear3Angle;

  _GearPainter({
    required this.gear1Angle,
    required this.gear2Angle,
    required this.gear3Angle,
  });

  void _drawGear(Canvas canvas, Offset center, double radius,
      double angle, Color color, int teeth, double toothSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.22;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    canvas.drawCircle(Offset.zero, radius, paint);

    final toothPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < teeth; i++) {
      final a = (i / teeth) * 2 * 3.14159;
      final tx = (radius + toothSize / 2) * 3.14159 / 180 * 0 +
          (radius) * (1 - 0);
      final rect = Rect.fromCenter(
        center: Offset(
          (radius + toothSize * 0.6) * _cos(a),
          (radius + toothSize * 0.6) * _sin(a),
        ),
        width: toothSize * 0.7,
        height: toothSize,
      );

      canvas.save();
      canvas.translate(
        (radius + toothSize * 0.5) * _cos(a),
        (radius + toothSize * 0.5) * _sin(a),
      );
      canvas.rotate(a);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset.zero,
              width: toothSize * 0.65,
              height: toothSize),
          const Radius.circular(2),
        ),
        toothPaint,
      );
      canvas.restore();
    }

    // inner circle
    final bgPaint = Paint()
      ..color = const Color(0xFF0F0A1E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius * 0.32, bgPaint);

    final innerPaint = Paint()
      ..color = color.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset.zero, radius * 0.32, innerPaint);

    canvas.restore();
  }

  double _cos(double a) => a == 0 ? 1 : (a == 3.14159 ? -1 :
  (a < 3.14159 ? (a < 1.5708 ? 1 - a * a / 2 : -(a - 3.14159) * (a - 3.14159) / 2 + 1)
      : -_cos(a - 3.14159)));

  double _sin(double a) => _cos(a - 1.5708);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Glow
    final glowPaint = Paint()
      ..color = const Color(0xFFFBFBFB).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 85, glowPaint);
    canvas.drawCircle(Offset(cx, cy), 72,
        Paint()..color = const Color(0xFFFFFFFF).withOpacity(0.07)..style = PaintingStyle.fill);

    // Large center gear
    _drawGear(canvas, Offset(cx, cy - 5), 40, gear1Angle,
        const Color(0xFF7CCD9E), 8, 12);

    // Top-right small gear
    _drawGear(canvas, Offset(cx + 54, cy - 53), 23, gear2Angle,
        const Color(0xFFC0F3D6), 8, 9);

    // Bottom-left tiny gear
    _drawGear(canvas, Offset(cx - 50, cy + 42), 17, gear3Angle,
        const Color(0xFF5AC142), 6, 7);
  }

  @override
  bool shouldRepaint(_GearPainter old) =>
      old.gear1Angle != gear1Angle ||
          old.gear2Angle != gear2Angle ||
          old.gear3Angle != gear3Angle;
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
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF50CC8A).withOpacity(_anim.value),
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final phase = (_ctrl.value - delay) % 1.0;
            final opacity = phase < 0.33 ? 1.0 : 0.2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFDFDFD).withOpacity(opacity),
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