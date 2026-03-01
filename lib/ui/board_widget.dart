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

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: tiltDegrees),
      duration: const Duration(milliseconds: 420),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Column(
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 34,
                    child: Container(
                      width: 280,
                      height: 16,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 56,
                    child: Container(
                      width: 36,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF44607D), Color(0xFF28384A)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateZ(value * math.pi / 180),
                    child: Container(
                      width: 320,
                      height: 24,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB2E0FF), Color(0xFF4BA0D9)],
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
                        children: slots.map((slot) => _SlotView(slot: slot, onTap: onSlotTap)).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    final left = slot.position.dx * 320 - 20;
    return Positioned(
      left: left,
      top: -32,
      child: GestureDetector(
        onTap: () => onTap(slot.id),
        child: SizedBox(
          width: 40,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 24,
                height: 24,
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
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Colors.blueGrey.shade700, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
