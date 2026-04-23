import 'package:flutter/material.dart';

class NoNetworkScreen extends StatefulWidget {
  const NoNetworkScreen({super.key});

  @override
  State<NoNetworkScreen> createState() => _NoNetworkScreenState();
}

class _NoNetworkScreenState extends State<NoNetworkScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _waveAnimation;

  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _onRetry() async {
    setState(() => _isRetrying = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // ── Animated background grid ──────────────────────────────
          Positioned.fill(child: _BackgroundGrid(animation: _waveAnimation)),

          // ── Glow orbs ─────────────────────────────────────────────
          Positioned(
            top: -80,
            left: -80,
            child: _GlowOrb(color: const Color(0xFF1A3A6B), size: 300),
          ),
          Positioned(
            bottom: -60,
            right: -60,
            child: _GlowOrb(color: const Color(0xFF0D2844), size: 250),
          ),

          // ── Main content ──────────────────────────────────────────
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Floating SVG illustration
                    AnimatedBuilder(
                      animation: _floatAnimation,
                      builder: (_, __) => Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: ScaleTransition(
                          scale: _pulseAnimation,
                          child: const _NoWifiIllustration(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Title
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
                      ).createShader(bounds),
                      child: const Text(
                        'No Connection',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Looks like your device is offline.\nCheck your Wi-Fi or mobile data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.white.withOpacity(0.45),
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Signal strength indicators
                    const _SignalBars(),

                    const SizedBox(height: 48),

                    // Retry button
                    _RetryButton(
                      isRetrying: _isRetrying,
                      onTap: _onRetry,
                    ),

                    const SizedBox(height: 20),

                    // Settings link
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Open Network Settings',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withOpacity(0.2),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SVG Illustration
// ─────────────────────────────────────────────────────────────────────────────

class _NoWifiIllustration extends StatelessWidget {
  const _NoWifiIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 180,
      child: CustomPaint(painter: _WifiPainter()),
    );
  }
}

class _WifiPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 10;

    // ── Outer glow circle ─────────────────────────────────────────
    final glowPaint = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 80, glowPaint);

    final glowPaint2 = Paint()
      ..color = const Color(0xFF1565C0).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 95, glowPaint2);

    // ── Arc stroke style ──────────────────────────────────────────
    Paint arcPaint(double opacity, double width) => Paint()
      ..color = Color.fromRGBO(79, 195, 247, opacity.toDouble())
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round;

    // ── Outer arc (disabled) ──────────────────────────────────────
    final outerRect = Rect.fromCenter(
      center: Offset(cx, cy + 10),
      width: 130,
      height: 130,
    );
    canvas.drawArc(
      outerRect,
      3.14 + 0.45,
      3.14 - 0.9,
      false,
      arcPaint(0.15, 8),
    );

    // ── Middle arc (disabled) ─────────────────────────────────────
    final midRect = Rect.fromCenter(
      center: Offset(cx, cy + 10),
      width: 86,
      height: 86,
    );
    canvas.drawArc(
      midRect,
      3.14 + 0.5,
      3.14 - 1.0,
      false,
      arcPaint(0.18, 7),
    );

    // ── Inner arc (active, glowing) ───────────────────────────────
    final innerRect = Rect.fromCenter(
      center: Offset(cx, cy + 10),
      width: 44,
      height: 44,
    );
    canvas.drawArc(
      innerRect,
      3.14 + 0.6,
      3.14 - 1.2,
      false,
      arcPaint(0.6, 6),
    );

    // ── Dot ───────────────────────────────────────────────────────
    final dotPaint = Paint()
      ..color = const Color(0xFF4FC3F7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + 30), 6, dotPaint);

    // ── Dot glow ──────────────────────────────────────────────────
    final dotGlow = Paint()
      ..color = const Color(0xFF4FC3F7).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy + 30), 12, dotGlow);

    // ── Cross / X mark ────────────────────────────────────────────
    final crossPaint = Paint()
      ..color = const Color(0xFFEF5350)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    // X positioned top-right of illustration
    final xCx = cx + 52.0;
    final xCy = cy - 48.0;
    const r = 10.0;

    // Background circle for X
    canvas.drawCircle(
      Offset(xCx, xCy),
      18,
      Paint()..color = const Color(0xFF1A0A0A),
    );
    canvas.drawCircle(
      Offset(xCx, xCy),
      18,
      Paint()
        ..color = const Color(0xFFEF5350).withOpacity(0.15)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(xCx, xCy),
      18,
      Paint()
        ..color = const Color(0xFFEF5350).withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.drawLine(
      Offset(xCx - r, xCy - r),
      Offset(xCx + r, xCy + r),
      crossPaint,
    );
    canvas.drawLine(
      Offset(xCx + r, xCy - r),
      Offset(xCx - r, xCy + r),
      crossPaint,
    );

    // ── Device silhouette (phone outline) ────────────────────────
    final phonePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, cy + 60), width: 28, height: 48),
      const Radius.circular(6),
    );
    canvas.drawRRect(phoneRect, phonePaint);

    // Phone screen line
    canvas.drawLine(
      Offset(cx - 8, cy + 72),
      Offset(cx + 8, cy + 72),
      Paint()
        ..color = Colors.white.withOpacity(0.06)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Signal Bars
// ─────────────────────────────────────────────────────────────────────────────

class _SignalBars extends StatelessWidget {
  const _SignalBars();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _Bar(height: 12, active: false, delay: 0),
        const SizedBox(width: 5),
        _Bar(height: 20, active: false, delay: 100),
        const SizedBox(width: 5),
        _Bar(height: 28, active: false, delay: 200),
        const SizedBox(width: 5),
        _Bar(height: 36, active: false, delay: 300),
      ],
    );
  }
}

class _Bar extends StatefulWidget {
  final double height;
  final bool active;
  final int delay;

  const _Bar({
    required this.height,
    required this.active,
    required this.delay,
  });

  @override
  State<_Bar> createState() => _BarState();
}

class _BarState extends State<_Bar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });

    _anim = Tween<double>(begin: 0.3, end: 0.6).animate(
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
        width: 10,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: const Color(0xFF4FC3F7).withOpacity(_anim.value),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Retry Button
// ─────────────────────────────────────────────────────────────────────────────

class _RetryButton extends StatelessWidget {
  final bool isRetrying;
  final VoidCallback onTap;

  const _RetryButton({required this.isRetrying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isRetrying ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isRetrying ? 56 : 200,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isRetrying ? 28 : 16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1565C0).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: isRetrying
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Background Grid
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundGrid extends StatelessWidget {
  final Animation<double> animation;
  const _BackgroundGrid({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => CustomPaint(
        painter: _GridPainter(animation.value),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 0.8;

    const spacing = 40.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Animated scan line
    final scanY = size.height * progress;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF4FC3F7).withOpacity(0.06),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, scanY - 40, size.width, 80));

    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 40, size.width, 80),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.progress != progress;
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
          colors: [color, Colors.transparent],
          stops: const [0.0, 1.0],
        ),
      ),
    );
  }
}