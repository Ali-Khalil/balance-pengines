import 'package:flutter/material.dart';

/// Shared snowy-mountain background used on all screens.
class ArcticBackground extends StatelessWidget {
  const ArcticBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Snow-white sky gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD6E8F5), Color(0xFFF5F9FC)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Mountain silhouettes in the background
        Positioned.fill(
          child: CustomPaint(painter: _MountainPainter()),
        ),
        // Snow ground strip at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFEDF4FA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Back mountains (lighter, further away)
    final backPaint = Paint()..color = const Color(0xFFCFDFEC);
    _drawMountain(canvas, backPaint, Offset(w * 0.12, h * 0.78), w * 0.28, h * 0.36);
    _drawMountain(canvas, backPaint, Offset(w * 0.55, h * 0.80), w * 0.22, h * 0.28);
    _drawMountain(canvas, backPaint, Offset(w * 0.85, h * 0.82), w * 0.20, h * 0.26);

    // Front mountains (darker, closer)
    final frontPaint = Paint()..color = const Color(0xFFB8CEDF);
    _drawMountain(canvas, frontPaint, Offset(w * 0.32, h * 0.82), w * 0.32, h * 0.32);
    _drawMountain(canvas, frontPaint, Offset(w * 0.72, h * 0.84), w * 0.26, h * 0.28);

    // Snow caps (white peaks on each mountain)
    final snowPaint = Paint()..color = Colors.white.withValues(alpha: 0.88);
    _drawSnowCap(canvas, snowPaint, Offset(w * 0.12, h * 0.78), w * 0.28, h * 0.36, capFraction: 0.26);
    _drawSnowCap(canvas, snowPaint, Offset(w * 0.55, h * 0.80), w * 0.22, h * 0.28, capFraction: 0.26);
    _drawSnowCap(canvas, snowPaint, Offset(w * 0.85, h * 0.82), w * 0.20, h * 0.26, capFraction: 0.26);
    _drawSnowCap(canvas, snowPaint, Offset(w * 0.32, h * 0.82), w * 0.32, h * 0.32, capFraction: 0.22);
    _drawSnowCap(canvas, snowPaint, Offset(w * 0.72, h * 0.84), w * 0.26, h * 0.28, capFraction: 0.22);
  }

  void _drawMountain(Canvas canvas, Paint paint, Offset base, double width, double height) {
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..lineTo(base.dx - width / 2, base.dy)
      ..lineTo(base.dx, base.dy - height)
      ..lineTo(base.dx + width / 2, base.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawSnowCap(Canvas canvas, Paint paint, Offset base, double width, double height,
      {required double capFraction}) {
    final capHeight = height * capFraction;
    final capWidth = width * capFraction;
    final peakY = base.dy - height;
    final path = Path()
      ..moveTo(base.dx, peakY)
      ..lineTo(base.dx - capWidth / 2, peakY + capHeight)
      ..lineTo(base.dx + capWidth / 2, peakY + capHeight)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
