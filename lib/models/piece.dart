enum PieceType {
  single(1, '🐧'),
  double(2, '🐧🐧'),
  triple(3, '🐧🐧🐧');

  const PieceType(this.weight, this.label);
  final int weight;
  final String label;

  static PieceType fromWeight(int weight) {
    return PieceType.values.firstWhere(
      (type) => type.weight == weight,
      orElse: () => throw ArgumentError('Unsupported piece weight: $weight'),
    );
  }
}

class Piece {
  const Piece({required this.id, required this.type, this.owner = PieceOwner.shared});

  final String id;
  final PieceType type;
  final PieceOwner owner;

  int get weight => type.weight;

  Piece copyWith({String? id, PieceType? type, PieceOwner? owner}) {
    return Piece(
      id: id ?? this.id,
      type: type ?? this.type,
      owner: owner ?? this.owner,
    );
  }
}

enum PieceOwner { player, ai, shared, level }
