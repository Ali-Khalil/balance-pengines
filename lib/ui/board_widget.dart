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

  /// Called when a piece is drag-dropped onto a slot.
  final void Function(String slotId, Piece piece)? onPieceDrop;

  /// Returns true if a piece can be dropped on [slot] (checks occupied + side).
  final bool Function(BoardSlot slot)? canDropOnSlot;

  static const double _maxTilt = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final plankWidth = (availableWidth * 0.92).clamp(280.0, 600.0);
        const plankHeight = 154.0;
        const fulcrumHeight = 72.0;
        const bubbleMeterHeight = 30.0;
        const groundHeight = 28.0;
        const totalHeight = plankHeight + fulcrumHeight + bubbleMeterHeight + groundHeight + 16;

        return SizedBox(
          width: availableWidth,
          height: totalHeight,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Ground shadow ellipse
              Positioned(
                bottom: groundHeight + 4,
                child: Container(
                  width: plankWidth * 0.28,
                  height: 14,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black.withValues(alpha: 0.20),
                  ),
                ),
              ),
              // Fulcrum support (doesn't tilt)
              Positioned(
                top: plankHeight - 10,
                child: SizedBox(
                  width: 100,
                  height: fulcrumHeight + 10,
                  child: CustomPaint(painter: _FulcrumPainter()),
                ),
              ),
              // Balance bubble meter
              Positioned(
                top: plankHeight + fulcrumHeight + 4,
                child: _BalanceBubbleMeter(
                  tiltDegrees: tiltDegrees,
                  maxTilt: _maxTilt,
                  width: plankWidth * 0.42,
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

/// The wooden seesaw plank with slot zones.
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
          // Plank body
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6D4C26), Color(0xFFC49A50), Color(0xFF8B6130), Color(0xFF6D4C26)],
                  stops: [0.0, 0.35, 0.65, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
          ),
          // Top-edge highlight
          Positioned(
            top: 4,
            left: 20,
            right: 20,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: const Color(0xFFE8B87A).withValues(alpha: 0.55),
              ),
            ),
          ),
          // Mid grain line 1
          Positioned(
            top: height * 0.42,
            left: 20,
            right: 20,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: Colors.black.withValues(alpha: 0.10),
              ),
            ),
          ),
          // Mid grain line 2
          Positioned(
            top: height * 0.62,
            left: 20,
            right: 20,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          // Bottom-edge shadow line
          Positioned(
            bottom: 5,
            left: 20,
            right: 20,
            child: Container(
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: const Color(0xFF3E2010).withValues(alpha: 0.35),
              ),
            ),
          ),
          // Left zone tint (blue)
          Positioned(
            left: 6,
            top: 10,
            bottom: 10,
            width: width * 0.38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                color: const Color(0xFF4FC3F7).withValues(alpha: 0.08),
              ),
            ),
          ),
          // Right zone tint (orange)
          Positioned(
            right: 6,
            top: 10,
            bottom: 10,
            width: width * 0.38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                color: const Color(0xFFFF6B35).withValues(alpha: 0.07),
              ),
            ),
          ),
          // Slot overlays
          ...slots.map((slot) => _SlotView(
                slot: slot,
                onTap: onSlotTap,
                onPieceDrop: onPieceDrop,
                canDropOnSlot: canDropOnSlot,
                plankWidth: width,
                plankHeight: height,
              )),
        ],
      ),
    );
  }
}

/// Individual slot view on the plank — also a DragTarget<Piece>.
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
          if (canDropOnSlot != null) {
            return canDropOnSlot!(slot);
          }
          return !slot.isOccupied;
        },
        onAcceptWithDetails: (details) {
          onPieceDrop?.call(slot.id, details.data);
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          final isRejected = rejectedData.isNotEmpty;

          return GestureDetector(
            onTap: () => onTap(slot.id),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: slot.isOccupied
                    ? PieceWidget(piece: slot.occupiedPiece!, compact: true)
                    : _EmptySlot(isHovering: isHovering, isRejected: isRejected),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({this.isHovering = false, this.isRejected = false});

  final bool isHovering;
  final bool isRejected;

  @override
  Widget build(BuildContext context) {
    final borderColor = isRejected
        ? const Color(0xFFE53935).withValues(alpha: 0.80)
        : isHovering
            ? const Color(0xFF4CAF50).withValues(alpha: 0.90)
            : const Color(0xFFFF6B35).withValues(alpha: 0.70);

    final bgColor = isRejected
        ? const Color(0xFFE53935).withValues(alpha: 0.25)
        : isHovering
            ? const Color(0xFF4CAF50).withValues(alpha: 0.30)
            : const Color(0xFF5C3317).withValues(alpha: 0.55);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: isHovering ? 38 : 34,
      height: isHovering ? 38 : 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: isHovering
            ? [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.40),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: const Color(0xFFFF6B35).withValues(alpha: 0.20),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Icon(
        isRejected ? Icons.close : Icons.add,
        size: 14,
        color: isRejected
            ? const Color(0xFFE53935)
            : isHovering
                ? Colors.white
                : const Color(0xFFFFCC99),
      ),
    );
  }
}

/// Triangle + base fulcrum support.
class _FulcrumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final triangleHeight = size.height * 0.72;
    final baseW = size.width * 0.78;
    final baseH = size.height * 0.22;

    // Shadow under base
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - baseW / 2, triangleHeight + baseH - 4, baseW, 8),
        const Radius.circular(4),
      ),
      shadowPaint,
    );

    // Triangle
    final trianglePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF78909C), Color(0xFF37474F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - baseW / 2, 0, baseW, triangleHeight));

    final trianglePath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx + baseW / 2, triangleHeight)
      ..lineTo(cx - baseW / 2, triangleHeight)
      ..close();
    canvas.drawPath(trianglePath, trianglePaint);

    // Triangle outline
    final outlinePaint = Paint()
      ..color = const Color(0xFF263238)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(trianglePath, outlinePaint);

    // Base rectangle
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF607D8B), Color(0xFF37474F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(cx - baseW / 2, triangleHeight, baseW, baseH));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - baseW / 2, triangleHeight, baseW, baseH),
        const Radius.circular(4),
      ),
      basePaint,
    );

    // Pivot pin
    final pinPaint = Paint()..color = const Color(0xFFB0BEC5);
    canvas.drawCircle(Offset(cx, 2), 5, pinPaint);

    final pinHighlight = Paint()..color = Colors.white.withValues(alpha: 0.7);
    canvas.drawCircle(Offset(cx - 1.5, 0.5), 2, pinHighlight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Horizontal bubble level meter.
class _BalanceBubbleMeter extends StatelessWidget {
  const _BalanceBubbleMeter({
    required this.tiltDegrees,
    required this.maxTilt,
    required this.width,
  });

  final double tiltDegrees;
  final double maxTilt;
  final double width;

  @override
  Widget build(BuildContext context) {
    final normalised = ((tiltDegrees / maxTilt) * 0.5 + 0.5).clamp(0.0, 1.0);
    final isBalanced = tiltDegrees.abs() <= 1;
    final isDanger = tiltDegrees.abs() >= maxTilt * 0.75;

    final bubbleColor = isBalanced
        ? const Color(0xFF4CAF50)
        : isDanger
            ? const Color(0xFFE53935)
            : const Color(0xFFFF9800);

    return Column(
      children: [
        Text(
          'BALANCE',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: Colors.white.withValues(alpha: 0.80),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: width,
          height: 22,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Track bar
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
              ),
              // Green safe zone
              Positioned(
                left: width * 0.35,
                width: width * 0.30,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
                  ),
                ),
              ),
              // Left danger zone
              Positioned(
                left: 0,
                width: width * 0.18,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(11)),
                    color: const Color(0xFFE53935).withValues(alpha: 0.30),
                  ),
                ),
              ),
              // Right danger zone
              Positioned(
                right: 0,
                width: width * 0.18,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(11)),
                    color: const Color(0xFFE53935).withValues(alpha: 0.30),
                  ),
                ),
              ),
              // Bubble
              TweenAnimationBuilder<double>(
                tween: Tween<double>(end: normalised),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  final bubbleX = value * (width - 22);
                  return Positioned(
                    left: bubbleX,
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bubbleColor,
                        boxShadow: [
                          BoxShadow(
                            color: bubbleColor.withValues(alpha: 0.55),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
