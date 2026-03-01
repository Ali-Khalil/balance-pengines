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
  });

  final List<BoardSlot> slots;
  final double tiltDegrees;
  final ValueChanged<String> onSlotTap;

  static const double boardWidth = 360;
  static const double boardHeight = 120;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: tiltDegrees),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return SizedBox(
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 42,
                child: Container(
                  width: 300,
                  height: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.black.withValues(alpha: 0.18),
                  ),
                ),
              ),
              Positioned(
                bottom: 62,
                child: Container(
                  width: 58,
                  height: 68,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF44607D), Color(0xFF28384A)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateZ(value * math.pi / 180),
                child: Container(
                  width: boardWidth,
                  height: boardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC9ECFF), Color(0xFF6FB8E7)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: slots
                        .map((slot) => _SlotView(slot: slot, onTap: onSlotTap))
                        .toList(growable: false),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SlotView extends StatelessWidget {
  const _SlotView({required this.slot, required this.onTap});

  final BoardSlot slot;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final left = slot.position.dx * BoardWidget.boardWidth - 18;
    final top = (slot.position.dy + 0.36) * 80 + 8;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => onTap(slot.id),
        child: SizedBox(
          width: 36,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: slot.isOccupied ? const Color(0xFFDEEFFE) : Colors.white,
                  border: Border.all(color: const Color(0xFF4B85B7), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              if (slot.occupiedPiece != null)
                PieceWidget(
                  piece: slot.occupiedPiece ??
                      const Piece(id: 'fallback', type: PieceType.single),
                  compact: true,
                )
              else
                Text(
                  '${slot.distance}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.blueGrey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
