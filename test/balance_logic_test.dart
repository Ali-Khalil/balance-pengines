import 'package:flutter_test/flutter_test.dart';
import 'package:penguin_balance/core/ai_engine.dart';
import 'package:penguin_balance/core/balance_logic.dart';
import 'package:penguin_balance/models/piece.dart';
import 'package:penguin_balance/models/slot.dart';

void main() {
  group('BalanceLogic', () {
    test('computes integer torque and balance state', () {
      const logic = BalanceLogic(tolerance: 1);
      final slots = buildDefaultSlots().map((slot) {
        if (slot.distance == -2) {
          return slot.copyWith(occupiedPiece: const Piece(id: 'a', type: PieceType.double));
        }
        if (slot.distance == 1) {
          return slot.copyWith(occupiedPiece: const Piece(id: 'b', type: PieceType.triple));
        }
        return slot;
      }).toList();

      final torque = logic.computeTorque(slots);
      expect(torque, -1);
      expect(logic.isBalanced(torque), isTrue);
    });
  });

  group('AiEngine', () {
    test('picks slot minimizing absolute torque', () {
      const logic = BalanceLogic(tolerance: 1);
      const ai = AiEngine(logic);

      final slots = buildDefaultSlots().map((slot) {
        if (slot.distance == -3) {
          return slot.copyWith(occupiedPiece: const Piece(id: 'a', type: PieceType.double));
        }
        return slot;
      }).toList();

      const candidate = Piece(id: 'c', type: PieceType.triple);
      final move = ai.chooseMove(slots: slots, piece: candidate);

      expect(move, isNotNull);
      expect(move!.slotDistance, 2);
    });
  });
}
