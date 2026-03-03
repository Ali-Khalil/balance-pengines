import 'package:flutter/material.dart';

/// Shared arctic background used on Home, Levels, and Game screens.
/// Renders a bright sky gradient and a snow ground strip.
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
