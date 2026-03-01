import '../models/slot.dart';

class BalanceLogic {
  const BalanceLogic({this.tolerance = 1, this.maxTiltDegrees = 12.0});

  final int tolerance;
  final double maxTiltDegrees;

  int computeTorque(Iterable<BoardSlot> slots) {
    var torque = 0;
    for (final slot in slots) {
      final piece = slot.occupiedPiece;
      if (piece != null) {
        torque += piece.weight * slot.distance;
      }
    }
    return torque;
  }

  bool isBalanced(int torque) => torque.abs() <= tolerance;

  double torqueToAngleDegrees(int torque) {
    final raw = torque * 2.0;
    if (raw > maxTiltDegrees) return maxTiltDegrees;
    if (raw < -maxTiltDegrees) return -maxTiltDegrees;
    return raw;
  }
}
