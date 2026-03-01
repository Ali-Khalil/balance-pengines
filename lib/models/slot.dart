import 'package:flutter/material.dart';

import 'piece.dart';

class BoardSlot {
  const BoardSlot({
    required this.id,
    required this.distance,
    required this.position,
    this.occupiedPiece,
  });

  final String id;
  final int distance;
  final Offset position;
  final Piece? occupiedPiece;

  bool get isOccupied => occupiedPiece != null;

  BoardSlot copyWith({
    String? id,
    int? distance,
    Offset? position,
    Piece? occupiedPiece,
    bool clearPiece = false,
  }) {
    return BoardSlot(
      id: id ?? this.id,
      distance: distance ?? this.distance,
      position: position ?? this.position,
      occupiedPiece: clearPiece ? null : (occupiedPiece ?? this.occupiedPiece),
    );
  }
}

List<BoardSlot> buildDefaultSlots() {
  const y = 0.0;
  return const [
    BoardSlot(id: 'L3', distance: -3, position: Offset(0.10, y)),
    BoardSlot(id: 'L2', distance: -2, position: Offset(0.24, y)),
    BoardSlot(id: 'L1', distance: -1, position: Offset(0.38, y)),
    BoardSlot(id: 'R1', distance: 1, position: Offset(0.62, y)),
    BoardSlot(id: 'R2', distance: 2, position: Offset(0.76, y)),
    BoardSlot(id: 'R3', distance: 3, position: Offset(0.90, y)),
  ];
}
