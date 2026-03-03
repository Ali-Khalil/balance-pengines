class LevelPiecePlacement {
  const LevelPiecePlacement({required this.weight, required this.slotDistance});

  final int weight;
  final int slotDistance;

  factory LevelPiecePlacement.fromJson(Map<String, dynamic> json) {
    return LevelPiecePlacement(
      weight: json['weight'] as int,
      slotDistance: json['slot'] as int,
    );
  }
}

class Level {
  const Level({
    required this.id,
    required this.name,
    required this.initialPieces,
    required this.availablePieces,
  });

  final String id;
  final String name;
  final List<LevelPiecePlacement> initialPieces;
  final List<int> availablePieces;

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'] as String,
      name: json['name'] as String,
      initialPieces: (json['initialPieces'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(LevelPiecePlacement.fromJson)
          .toList(),
      availablePieces: (json['availablePieces'] as List<dynamic>).cast<int>(),
    );
  }
}

const List<Map<String, dynamic>> kLevelData = [
  {
    'id': '1',
    'name': 'Warmup',
    'initialPieces': [
      {'weight': 2, 'slot': -2}
    ],
    'availablePieces': [1, 3]
  },
  {
    'id': '2',
    'name': 'Counter Swing',
    'initialPieces': [
      {'weight': 3, 'slot': 3}
    ],
    'availablePieces': [1, 2]
  },
  {
    'id': '3',
    'name': 'Tight Tolerance',
    'initialPieces': [
      {'weight': 1, 'slot': -3},
      {'weight': 2, 'slot': 2}
    ],
    'availablePieces': [1, 2, 3]
  }
];

List<Level> loadBuiltInLevels() {
  return kLevelData.map(Level.fromJson).toList(growable: false);
}
