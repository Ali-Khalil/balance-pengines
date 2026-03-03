import '../models/piece.dart';
import '../models/slot.dart';
import 'balance_logic.dart';

class AiMove {
  const AiMove({required this.slotId, required this.slotDistance, required this.score});

  final String slotId;
  final int slotDistance;
  final int score;
}

class AiEngine {
  const AiEngine(this.balanceLogic);

  final BalanceLogic balanceLogic;

  AiMove? chooseMove({
    required List<BoardSlot> slots,
    required Piece piece,
  }) {
    AiMove? bestMove;
    for (final slot in slots.where((slot) => !slot.isOccupied)) {
      final simulated = slots
          .map(
            (s) => s.id == slot.id ? s.copyWith(occupiedPiece: piece) : s,
          )
          .toList(growable: false);
      final torque = balanceLogic.computeTorque(simulated);
      final score = torque.abs();

      if (bestMove == null || _isBetter(score, slot.distance, bestMove)) {
        bestMove = AiMove(slotId: slot.id, slotDistance: slot.distance, score: score);
      }
    }

    if (bestMove == null) return null;

    final simulatedTorque = slots.fold<int>(0, (sum, slot) {
      if (slot.id == bestMove!.slotId) {
        return sum + piece.weight * slot.distance;
      }
      final occupied = slot.occupiedPiece;
      if (occupied == null) return sum;
      return sum + occupied.weight * slot.distance;
    });

    if (!balanceLogic.isBalanced(simulatedTorque)) {
      return null;
    }

    return bestMove;
  }

  bool _isBetter(int score, int distance, AiMove current) {
    if (score < current.score) return true;
    if (score > current.score) return false;
    return distance.abs() < current.slotDistance.abs();
  }
}
