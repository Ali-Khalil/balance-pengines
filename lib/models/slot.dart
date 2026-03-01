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

/// Toy-like board layout with 3 rows x 3 columns on each side.
///
/// Left distances are negative and right are positive.
List<BoardSlot> buildDefaultSlots() {
  const rowYs = [-0.28, 0.0, 0.28];
  const leftXs = [0.08, 0.18, 0.28];
  const rightXs = [0.72, 0.82, 0.92];
  const leftDistances = [-3, -2, -1];
  const rightDistances = [1, 2, 3];

  final slots = <BoardSlot>[];

  for (var row = 0; row < rowYs.length; row++) {
    for (var col = 0; col < 3; col++) {
      slots.add(
        BoardSlot(
          id: 'L${row + 1}${col + 1}',
          distance: leftDistances[col],
          position: Offset(leftXs[col], rowYs[row]),
        ),
      );
    }
  }

  for (var row = 0; row < rowYs.length; row++) {
    for (var col = 0; col < 3; col++) {
      slots.add(
        BoardSlot(
          id: 'R${row + 1}${col + 1}',
          distance: rightDistances[col],
          position: Offset(rightXs[col], rowYs[row]),
        ),
      );
    }
  }

  return slots;
}
