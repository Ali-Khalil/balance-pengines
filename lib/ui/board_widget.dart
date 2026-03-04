import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/piece.dart';
import '../models/slot.dart';
import 'piece_widget.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.slots,
    required this.tiltDegrees,
    required this.onSlotTap,
    this.onPieceDrop,
    this.canDropOnSlot,
  });

  final List<BoardSlot> slots;
  final double tiltDegrees;
  final ValueChanged<String> onSlotTap;
  final void Function(String slotId, Piece piece)? onPieceDrop;
  final bool Function(BoardSlot slot)? canDropOnSlot;

  static const double _maxTilt = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final plankWidth = (availableWidth * 0.96).clamp(300.0, 640.0);
        const plankHeight = 170.0;
        const fulcrumHeight = 68.0;
        const groundHeight = 30.0;
        const totalHeight = plankHeight + fulcrumHeight + groundHeight + 8;

        return SizedBox(
          width: availableWidth,
          height: totalHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Ground shadow ellipse below base
              Positioned(
                bottom: groundHeight + 2,
                child: Container(
                  width: plankWidth * 0.22,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Circular pedestal fulcrum (doesn't tilt)
              Positioned(
                top: plankHeight - 8,
                child: SizedBox(
                  width: 110,
                  height: fulcrumHeight + 8,
                  child: CustomPaint(painter: _FulcrumPainter()),
                ),
              ),
              // The rotating seesaw plank
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: tiltDegrees),
                duration: const Duration(milliseconds: 430),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(value * math.pi / 180),
                    child: child,
                  );
                },
                child: _Plank(
                  width: plankWidth,
                  height: plankHeight,
                  slots: slots,
                  onSlotTap: onSlotTap,
                  onPieceDrop: onPieceDrop,
                  canDropOnSlot: canDropOnSlot,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Plank ───────────────────────────────────────────────────────────────────

class _Plank extends StatelessWidget {
  const _Plank({
    required this.width,
    required this.height,
    required this.slots,
    required this.onSlotTap,
    this.onPieceDrop,
    this.canDropOnSlot,
  });

  final double width;
  final double height;
  final List<BoardSlot> slots;
  final ValueChanged<String> onSlotTap;
  final void Function(String slotId, Piece piece)? onPieceDrop;
  final bool Function(BoardSlot slot)? canDropOnSlot;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Plank body — sky-blue gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF01579B),
                    Color(0xFF0288D1),
                    Color(0xFF0277BD),
                    Color(0xFF01579B),
                  ],
                  stops: [0.0, 0.30, 0.65, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0277BD).withValues(alpha: 0.50),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),
          ),
          // Top-edge highlight
          Positioned(
            top: 5,
            left: 22,
            right: 22,
            child: Container(
              height: 2.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xFF4FC3F7).withValues(alpha: 0.60),
              ),
            ),
          ),
          // Subtle mid-line
          Positioned(
            top: height * 0.50,
            left: 22,
            right: 22,
            child: Container(
              height: 1,
              color: const Color(0xFF01579B).withValues(alpha: 0.30),
            ),
          ),
          // Bottom-edge shadow
          Positioned(
            bottom: 6,
            left: 22,
            right: 22,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: const Color(0xFF003D6B).withValues(alpha: 0.35),
              ),
            ),
          ),
          // Slot overlays
          ...slots.map(
            (slot) => _SlotView(
              slot: slot,
              onTap: onSlotTap,
              onPieceDrop: onPieceDrop,
              canDropOnSlot: canDropOnSlot,
              plankWidth: width,
              plankHeight: height,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Slot ────────────────────────────────────────────────────────────────────

class _SlotView extends StatelessWidget {
  const _SlotView({
    required this.slot,
    required this.onTap,
    this.onPieceDrop,
    this.canDropOnSlot,
    required this.plankWidth,
    required this.plankHeight,
  });

  final BoardSlot slot;
  final ValueChanged<String> onTap;
  final void Function(String slotId, Piece piece)? onPieceDrop;
  final bool Function(BoardSlot slot)? canDropOnSlot;
  final double plankWidth;
  final double plankHeight;

  @override
  Widget build(BuildContext context) {
    final left = slot.position.dx * plankWidth - 22;
    final top = (slot.position.dy + 0.5) * plankHeight - 22;

    return Positioned(
      left: left,
      top: top,
      child: DragTarget<Piece>(
        onWillAcceptWithDetails: (details) {
          if (canDropOnSlot != null) return canDropOnSlot!(slot);
          return !slot.isOccupied;
        },
        onAcceptWithDetails: (details) => onPieceDrop?.call(slot.id, details.data),
        builder: (context, candidates, rejected) {
          return GestureDetector(
            onTap: () => onTap(slot.id),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: slot.isOccupied
                    ? PieceWidget(piece: slot.occupiedPiece!, compact: true)
                    : _EmptyHole(
                        isHovering: candidates.isNotEmpty,
                        isRejected: rejected.isNotEmpty,
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A plain circular hole in the plank surface.
class _EmptyHole extends StatelessWidget {
  const _EmptyHole({this.isHovering = false, this.isRejected = false});

  final bool isHovering;
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    final borderColor = isRejected
        ? const Color(0xFFEF5350)
        : isHovering
            ? Colors.white
            : const Color(0xFF90CAF9).withValues(alpha: 0.80);

    final holeColor = isRejected
        ? const Color(0xFFB71C1C).withValues(alpha: 0.50)
        : isHovering
            ? const Color(0xFF4CAF50).withValues(alpha: 0.40)
            : const Color(0xFF003D6B).withValues(alpha: 0.65);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: isHovering ? 40 : 36,
      height: isHovering ? 40 : 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: holeColor,
        border: Border.all(color: borderColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: isHovering ? 8 : 4,
            spreadRadius: isHovering ? 1 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// ─── Fulcrum painter ─────────────────────────────────────────────────────────

/// Cylindrical pedestal: a narrow post topped with a cradle groove, sitting on
/// a wide elliptical base — like the physical toy's balance stand.
class _FulcrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;

    const postW = 18.0;
    const postH = 40.0;
    const baseW = 88.0;
    const baseH = 18.0;
    const cradleR = 10.0; // notch at top of post

    final postTop = 2.0;
    final postLeft = cx - postW / 2;
    final baseTop = postTop + postH;

    // ── Drop shadow under base ──
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, baseTop + baseH + 6),
        width: baseW * 0.85,
        height: 10,
      ),
      shadowPaint,
    );

    // ── Post (upright column) ──
    final postPaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF90A4AE), Color(0xFF607D8B), Color(0xFF455A64)],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(postLeft, postTop, postW, postH));

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(postLeft, postTop, postW, postH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ),
      postPaint,
    );

    // ── Cradle groove at top of post (where plank rests) ──
    final cradlePaint = Paint()..color = const Color(0xFF37474F);
    canvas.drawCircle(Offset(cx, postTop), cradleR, cradlePaint);
    // Highlight on cradle
    final cradleHighlight = Paint()..color = const Color(0xFFB0BEC5).withValues(alpha: 0.70);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx - 1.5, postTop - 1), radius: cradleR * 0.55),
      math.pi,
      math.pi,
      false,
      cradleHighlight..style = PaintingStyle.stroke..strokeWidth = 2,
    );

    // ── Elliptical base ──
    final basePaint = Paint()
      ..shader = LinearGradient(
        colors: const [Color(0xFF78909C), Color(0xFF546E7A), Color(0xFF37474F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - baseW / 2, baseTop, baseW, baseH));

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - baseW / 2, baseTop, baseW, baseH),
        const Radius.circular(9),
      ),
      basePaint,
    );

    // ── Rim highlight on base top ──
    final rimPaint = Paint()
      ..color = const Color(0xFF90A4AE).withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - baseW / 2 + 2, baseTop + 1, baseW - 4, baseH - 2),
        const Radius.circular(8),
      ),
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
