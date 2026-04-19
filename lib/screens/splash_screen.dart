import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoCtrl, _textCtrl, _dotCtrl;
  late Animation<double> _logoScale, _logoOpacity, _textOpacity, _dotAnim;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _dotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

    _logoScale = Tween(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.4)));
    _textOpacity = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _dotAnim = Tween(begin: 0.0, end: 1.0).animate(_dotCtrl);

    Future.delayed(const Duration(milliseconds: 300), () => _logoCtrl.forward());
    Future.delayed(const Duration(milliseconds: 900), () => _textCtrl.forward());
    Future.delayed(const Duration(milliseconds: 3000), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose(); _textCtrl.dispose(); _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    body: Stack(children: [
      // Grid background
      CustomPaint(painter: _GridPainter(), child: const SizedBox.expand()),
      // Glow orb
      Positioned(top: -100, left: -100, child: Container(
        width: 400, height: 400,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [AppTheme.accent.withOpacity(0.08), Colors.transparent]),
        ),
      )),
      // Center content
      Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedBuilder(
          animation: _logoCtrl,
          builder: (_, __) => Opacity(
            opacity: _logoOpacity.value,
            child: Transform.scale(
              scale: _logoScale.value,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppTheme.accent.withOpacity(0.4), width: 1.5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppTheme.accent.withOpacity(0.15), AppTheme.accentBlue.withOpacity(0.08)],
                  ),
                  boxShadow: [BoxShadow(color: AppTheme.accent.withOpacity(0.3), blurRadius: 40)],
                ),
                child: const Center(child: Text('🚌', style: TextStyle(fontSize: 48))),
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        FadeTransition(
          opacity: _textOpacity,
          child: Column(children: [
            Text('CAMBUS', style: AppText.mono(size: 32, color: AppTheme.textPrimary, weight: FontWeight.w700).copyWith(letterSpacing: 8)),
            const SizedBox(height: 8),
            Text('College Bus Tracking', style: AppText.mono(size: 13, color: AppTheme.textMuted).copyWith(letterSpacing: 3)),
          ]),
        ),
        const SizedBox(height: 60),
        FadeTransition(
          opacity: _textOpacity,
          child: AnimatedBuilder(
            animation: _dotAnim,
            builder: (_, __) => Row(mainAxisSize: MainAxisSize.min, children: List.generate(3, (i) {
              final delay = i / 3;
              final val = (((_dotAnim.value - delay) % 1 + 1) % 1);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accent.withOpacity(val < 0.5 ? val * 2 : (1 - val) * 2),
                ),
              );
            })),
          ),
        ),
      ])),
    ]),
  );
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F5A0).withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 60.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}
