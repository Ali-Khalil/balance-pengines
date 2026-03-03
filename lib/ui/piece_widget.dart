import 'package:flutter/material.dart';

import '../models/piece.dart';

class PieceWidget extends StatelessWidget {
  const PieceWidget({
    super.key,
    required this.piece,
    this.selected = false,
    this.onTap,
    this.compact = false,
  });

  final Piece piece;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      scale: selected ? 1.14 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: compact ? _CompactToken(piece: piece) : _TrayToken(piece: piece, selected: selected),
      ),
    );
  }
}

/// Large circular token shown in the piece tray (68×68).
class _TrayToken extends StatelessWidget {
  const _TrayToken({required this.piece, required this.selected});

  final Piece piece;
  final bool selected;

  static const _orange = Color(0xFFFF6B35);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: selected ? _orange : Colors.grey.shade300,
          width: selected ? 3 : 1.5,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: _orange.withValues(alpha: 0.55),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            piece.type.label,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 2),
          _WeightDots(weight: piece.weight),
        ],
      ),
    );
  }
}

/// Small circular token shown on the board slots (40×40).
class _CompactToken extends StatelessWidget {
  const _CompactToken({required this.piece});

  final Piece piece;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: const Color(0xFFFF6B35), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          piece.type.label,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

/// Row of 1–3 filled orange dots representing piece weight.
class _WeightDots extends StatelessWidget {
  const _WeightDots({required this.weight});

  final int weight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(weight, (_) {
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFF6B35),
          ),
        );
      }),
    );
  }
}
