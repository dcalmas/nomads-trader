import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter_app/app/helper/router.dart';
import 'package:flutter_app/app/controller/home_controller.dart';
import 'package:flutter_app/app/controller/my_courses_controller.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  // Loop animation (liquid motion)
  late final AnimationController _loop;
  // Exit animation (morph + fade out)
  late final AnimationController _exit;

  // Progress (real)
  double _progress = 0.0;
  String _status = 'Preparing…';
  bool _readyToExit = false;

  // Noise points (static film grain)
  late final List<Offset> _grainPoints;
  late final List<double> _grainRadius;

  @override
  void initState() {
    super.initState();

    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );

    // Build static grain
    final r = math.Random(42);
    _grainPoints = List.generate(900, (_) => Offset(r.nextDouble(), r.nextDouble()));
    _grainRadius = List.generate(900, (_) => 0.35 + r.nextDouble() * 0.85);

    // Variant 1: тек Welcome тұрады, preload біткенше күтеді
    _preloadAllThenExit();
  }

  @override
  void dispose() {
    _loop.dispose();
    _exit.dispose();
    super.dispose();
  }

  Future<void> _preloadAllThenExit() async {
    final started = DateTime.now();

    try {
      // Controllers тіркелмеген болса тіркейміз (қатесіз preload үшін)
      if (!Get.isRegistered<HomeController>()) {
        Get.put<HomeController>(
          HomeController(parser: Get.find()),
          permanent: true,
        );
      }
      if (!Get.isRegistered<MyCoursesController>()) {
        Get.put<MyCoursesController>(
          MyCoursesController(parser: Get.find()),
          permanent: true,
        );
      }

      final home = Get.find<HomeController>();
      final myCourses = Get.find<MyCoursesController>();

      // Step 1: Overview
      _setStep(0.10, 'Loading overview…');
      await home.getOverview();
      _setStep(0.55, 'Loading your courses…');

      // Step 2: MyCourses
      await myCourses.refreshData();
      _setStep(0.90, 'Finalizing…');

      // (Optional) tiny settle
      await Future.delayed(const Duration(milliseconds: 150));
      _setStep(1.00, 'Ready');
    } catch (_) {
      // preload құласа да ішке жібереміз
      _setStep(1.00, 'Ready');
    }

    // Минимум 900ms көрсетілсін (cinematic)
    final elapsed = DateTime.now().difference(started);
    final minShow = const Duration(milliseconds: 900);
    if (elapsed < minShow) {
      await Future.delayed(minShow - elapsed);
    }

    if (!mounted) return;
    setState(() => _readyToExit = true);

    await _exit.forward(); // orb shrink + fade

    if (!mounted) return;
    // Fade transition to Tabs
    Get.offAllNamed(AppRouter.tabsBarRoutes);
  }

  void _setStep(double p, String s) {
    if (!mounted) return;
    setState(() {
      _progress = p.clamp(0.0, 1.0);
      _status = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Adaptive blur (Android-та аздау)
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;
    final orbBlur = isAndroid ? 14.0 : 18.0;
    final blobBlur1 = isAndroid ? 70.0 : 85.0;
    final blobBlur2 = isAndroid ? 60.0 : 75.0;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([_loop, _exit]),
        builder: (_, __) {
          final t = _loop.value; // 0..1 loop
          final exitT = Curves.easeInOutCubic.transform(_exit.value);

          // Parallax offsets (әр blob әртүрлі жылдамдықпен)
          final p1 = _sin(t * 2.0) * 18;
          final p2 = _cos(t * 1.6) * 14;
          final p3 = _sin(t * 1.1 + 0.6) * 22;

          // Orb transform on exit
          final orbScale = 1.0 - exitT * 0.18; // shrink a bit
          final orbOpacity = 1.0 - exitT * 1.0;

          // Overall fade
          final overallOpacity = 1.0 - exitT * 1.0;

          return Opacity(
            opacity: overallOpacity.clamp(0.0, 1.0),
            child: Stack(
              children: [
                // ✅ Background (dark teal/blue, not слишком яркий)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF061827), // deep navy
                        Color(0xFF08314A), // teal-blue
                        Color(0xFF0A4A63), // dark cyan
                      ],
                    ),
                  ),
                ),

                // ✅ Parallax blobs (glass depth)
                _Blob(
                  x: 0.18,
                  y: 0.20,
                  size: size.width * 1.05,
                  blur: blobBlur1,
                  opacity: 0.08 + 0.10 * (0.5 + 0.5 * _sin(t)),
                  dx: p1,
                  dy: -p2,
                  color: const Color(0xFF7EE6FF),
                ),
                _Blob(
                  x: 0.88,
                  y: 0.28,
                  size: size.width * 0.85,
                  blur: blobBlur2,
                  opacity: 0.06 + 0.08 * (0.5 + 0.5 * _cos(t)),
                  dx: -p3,
                  dy: p1 * 0.6,
                  color: Colors.white,
                ),
                _Blob(
                  x: 0.55,
                  y: 0.96,
                  size: size.width * 1.15,
                  blur: blobBlur1 + 10,
                  opacity: 0.05 + 0.07 * (0.5 + 0.5 * _sin(t + 0.4)),
                  dx: p2,
                  dy: -p3 * 0.7,
                  color: const Color(0xFF2AA9FF),
                ),

                // ✅ Film grain overlay (very subtle)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _GrainPainter(
                        points01: _grainPoints,
                        radius: _grainRadius,
                        opacity: 0.045, // subtle pro look
                      ),
                    ),
                  ),
                ),

                // ✅ Content
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        const Spacer(),

                        // Orb + logo + liquid effect
                        Transform.translate(
                          offset: Offset(0, _sin(t) * 6),
                          child: Opacity(
                            opacity: orbOpacity.clamp(0.0, 1.0),
                            child: Transform.scale(
                              scale: orbScale,
                              child: _LiquidGlassOrb(
                                t: t,
                                blurSigma: orbBlur,
                                logo: _buildLogo(t),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Welcome',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _status,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.72),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ✅ Real progress bar (glass)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 42),
                          child: _GlassProgressBar(
                            value: _progress,
                            t: t,
                          ),
                        ),

                        const Spacer(),

                        // Tiny bottom indicator (breathing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Opacity(
                            opacity: 0.18 + 0.20 * (0.5 + 0.5 * _sin(t)),
                            child: Container(
                              width: 56,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Optional: "Ready" sparkle on exit
                if (_readyToExit)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: (0.12 * (1.0 - exitT)).clamp(0.0, 0.12),
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(double t) {
    // Slight pulse
    final scale = 0.98 + 0.04 * (0.5 + 0.5 * _sin(t * 1.2));
    return Transform.scale(
      scale: scale,
      child: Image.asset(
        'assets/images/logo_white.png',
        width: 74,
        height: 74,
        fit: BoxFit.contain,
        // ✅ Қызыл X шықпасын: fallback
        errorBuilder: (_, __, ___) => const Icon(
          Icons.school_rounded,
          size: 62,
          color: Colors.white,
        ),
      ),
    );
  }

  double _sin(double t) => math.sin(t * math.pi * 2);
  double _cos(double t) => math.cos(t * math.pi * 2);
}

/// ✅ Liquid Glass Orb (multi-layer, refraction, rotating highlights)
class _LiquidGlassOrb extends StatelessWidget {
  final double t; // 0..1
  final double blurSigma;
  final Widget logo;

  const _LiquidGlassOrb({
    required this.t,
    required this.blurSigma,
    required this.logo,
  });

  @override
  Widget build(BuildContext context) {
    final glow = 0.10 + 0.12 * (0.5 + 0.5 * math.sin(t * math.pi * 2));
    final rot1 = t * math.pi * 2;
    final rot2 = -t * math.pi * 2 * 0.75;

    return Container(
      width: 178,
      height: 178,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.10 + glow),
            blurRadius: 60,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.32),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Base glass fill
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10 + glow),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.22),
                    width: 1,
                  ),
                ),
              ),

              // Inner refraction layer (gives depth)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withOpacity(0.00),
                            Colors.white.withOpacity(0.06 + glow),
                            Colors.white.withOpacity(0.00),
                          ],
                          stops: const [0.25, 0.62, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Rotating highlight ring (specular)
              Transform.rotate(
                angle: rot1,
                child: Container(
                  width: 156,
                  height: 156,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.white.withOpacity(0.00),
                        Colors.white.withOpacity(0.18 + glow),
                        Colors.white.withOpacity(0.00),
                      ],
                      stops: const [0.20, 0.50, 0.80],
                    ),
                  ),
                ),
              ),

              // Secondary ring
              Transform.rotate(
                angle: rot2,
                child: Container(
                  width: 142,
                  height: 142,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        Colors.white.withOpacity(0.00),
                        const Color(0xFF7EE6FF).withOpacity(0.16 + glow),
                        Colors.white.withOpacity(0.00),
                      ],
                      stops: const [0.10, 0.52, 0.92],
                    ),
                  ),
                ),
              ),

              // Liquid highlights (moving spots)
              Positioned(
                top: 30,
                left: 34,
                child: _shine(54, 24, 0.18 + glow),
              ),
              Positioned(
                bottom: 34,
                right: 28,
                child: _shine(64, 26, 0.12 + glow),
              ),

              // Logo
              logo,
            ],
          ),
        ),
      ),
    );
  }

  static Widget _shine(double w, double h, double opacity) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white.withOpacity(opacity.clamp(0.0, 1.0)),
        ),
      ),
    );
  }
}

/// ✅ Glass progress bar (real progress)
class _GlassProgressBar extends StatelessWidget {
  final double value;
  final double t;

  const _GlassProgressBar({
    required this.value,
    required this.t,
  });

  @override
  Widget build(BuildContext context) {
    final shimmer = 0.18 + 0.18 * (0.5 + 0.5 * math.sin(t * math.pi * 2));

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: (MediaQuery.of(context).size.width - 84) * value,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF7EE6FF).withOpacity(0.65),
                        const Color(0xFF2AA9FF).withOpacity(0.75),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7EE6FF).withOpacity(0.25),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                ),
              ),

              // Shimmer sweep
              Positioned.fill(
                child: Opacity(
                  opacity: shimmer.clamp(0.0, 0.35),
                  child: Transform.translate(
                    offset: Offset(120 * math.sin(t * math.pi * 2), 0),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.0),
                            Colors.white.withOpacity(0.30),
                            Colors.white.withOpacity(0.0),
                          ],
                          stops: const [0.2, 0.5, 0.8],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ✅ Background blobs
class _Blob extends StatelessWidget {
  final double x;
  final double y;
  final double size;
  final double blur;
  final double opacity;
  final double dx;
  final double dy;
  final Color color;

  const _Blob({
    required this.x,
    required this.y,
    required this.size,
    required this.blur,
    required this.opacity,
    required this.dx,
    required this.dy,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final left = (s.width * x) - size / 2 + dx;
    final top = (s.height * y) - size / 2 + dy;

    return Positioned(
      left: left,
      top: top,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(opacity.clamp(0.0, 1.0)),
          ),
        ),
      ),
    );
  }
}

/// ✅ Film grain painter (static points)
class _GrainPainter extends CustomPainter {
  final List<Offset> points01;
  final List<double> radius;
  final double opacity;

  _GrainPainter({
    required this.points01,
    required this.radius,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..isAntiAlias = true;

    for (int i = 0; i < points01.length; i++) {
      final o = points01[i];
      final r = radius[i];
      canvas.drawCircle(
        Offset(o.dx * size.width, o.dy * size.height),
        r,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) => false;
}
