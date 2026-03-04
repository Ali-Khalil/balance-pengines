import 'package:flutter/material.dart';

import '../models/piece.dart';

/// Piece token used in tray and on board.
/// Set [compact] to true for the smaller on-board variant.
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
        child: compact
            ? _CompactToken(piece: piece)
            : _TrayToken(piece: piece, selected: selected),
      ),
    );
  }
}

/// Draggable wrapper for tray pieces. Use in the bottom piece tray.
class DraggablePieceWidget extends StatelessWidget {
  const DraggablePieceWidget({
    super.key,
    required this.piece,
    this.selected = false,
    this.onTap,
  });

  final Piece piece;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Draggable<Piece>(
      data: piece,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.88,
          child: _TrayToken(piece: piece, selected: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.30,
        child: _TrayToken(piece: piece, selected: false),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: _TrayToken(piece: piece, selected: selected),
      ),
    );
  }
}

/// Large circular token shown in the piece tray (56×56).
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
      width: 56,
      height: 56,
      clipBehavior: Clip.hardEdge,
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
                  blurRadius: 14,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐧', style: TextStyle(fontSize: 22)),
          Text(
            '×${piece.weight}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: _orange,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

/// Small circular token shown on the board slots (36×36).
class _CompactToken extends StatelessWidget {
  const _CompactToken({required this.piece});

  final Piece piece;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      clipBehavior: Clip.hardEdge,
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🐧', style: TextStyle(fontSize: 14, height: 1.0)),
          Text(
            '${piece.weight}',
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: Color(0xFFFF6B35),
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
