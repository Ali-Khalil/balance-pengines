import 'package:flutter/material.dart';

/// Shared arctic background used on Home, Levels, and Game screens.
/// Renders a bright sky gradient, decorative clouds, and a snow ground strip.
class ArcticBackground extends StatelessWidget {
  const ArcticBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Sky gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0277BD), Color(0xFF81D4FA)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Cloud 1 — top-left area
        Positioned(
          top: 14,
          left: 60,
          child: _Cloud(width: 110, height: 38),
        ),
        // Cloud 2 — top-center-right
        Positioned(
          top: 8,
          right: 90,
          child: _Cloud(width: 140, height: 44),
        ),
        // Cloud 3 — mid-right (smaller)
        Positioned(
          top: 30,
          right: 20,
          child: _Cloud(width: 80, height: 28),
        ),
        // Snow ground strip at bottom
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE1F5FE),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
          ),
        ),
        // Actual screen content on top
        child,
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
