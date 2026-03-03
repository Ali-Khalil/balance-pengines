import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/level.dart';
import '../models/piece.dart';
import '../models/slot.dart';
import 'ai_engine.dart';
import 'app_storage.dart';
import 'balance_logic.dart';

enum GameMode { solo, vsAi }
enum Turn { player, ai }
enum GameStatus { playing, won, lost }

class GameState extends ChangeNotifier {
  GameState({
    required this.balanceLogic,
    required this.aiEngine,
  }) : _slots = buildDefaultSlots();

  final BalanceLogic balanceLogic;
  final AiEngine aiEngine;

  List<BoardSlot> _slots;
  List<Piece> _availablePieces = [];
  Piece? _selectedPiece;
  GameMode _mode = GameMode.solo;
  Turn _turn = Turn.player;
  GameStatus _status = GameStatus.playing;
  int _torque = 0;
  int _pieceCounter = 0;
  final Set<String> _levelsPlayed = <String>{};
  int _wins = 0;
  int _losses = 0;
  String? _activeLevelId;
  bool _completionRecorded = false;

  List<BoardSlot> get slots => List.unmodifiable(_slots);
  List<Piece> get availablePieces => List.unmodifiable(_availablePieces);
  Piece? get selectedPiece => _selectedPiece;
  GameMode get mode => _mode;
  Turn get turn => _turn;
  GameStatus get status => _status;
  int get torque => _torque;
  double get tiltDegrees => balanceLogic.torqueToAngleDegrees(_torque);
  int get wins => _wins;
  int get losses => _losses;
  List<String> get levelsPlayed => List.unmodifiable(_levelsPlayed);

  Future<void> loadPersistedState() async {
    final snapshot = await AppStorage.instance.loadStats();
    _levelsPlayed
      ..clear()
      ..addAll(snapshot.levelsPlayed);
    _wins = snapshot.wins;
    _losses = snapshot.losses;
    notifyListeners();
  }

  void startSoloLevel(Level level) {
    _mode = GameMode.solo;
    _completionRecorded = false;
    _activeLevelId = level.id;
    _turn = Turn.player;
    _status = GameStatus.playing;
    _slots = buildDefaultSlots();
    _availablePieces = [];
    _selectedPiece = null;

    for (final placement in level.initialPieces) {
      _placeInitialPiece(placement.weight, placement.slotDistance);
    }

    for (final weight in level.availablePieces) {
      _availablePieces.add(_createPiece(weight, owner: PieceOwner.player));
    }

    _refreshTorque();
    notifyListeners();
  }

  void startVsAi() {
    _mode = GameMode.vsAi;
    _completionRecorded = false;
    _activeLevelId = null;
    _turn = Turn.player;
    _status = GameStatus.playing;
    _slots = buildDefaultSlots();
    _selectedPiece = null;
    _availablePieces = [
      _createPiece(1, owner: PieceOwner.shared),
      _createPiece(2, owner: PieceOwner.shared),
      _createPiece(3, owner: PieceOwner.shared),
      _createPiece(1, owner: PieceOwner.shared),
      _createPiece(2, owner: PieceOwner.shared),
      _createPiece(3, owner: PieceOwner.shared),
    ];
    _refreshTorque();
    notifyListeners();
  }

  void selectPiece(Piece piece) {
    if (_status != GameStatus.playing) return;
    if (!_availablePieces.contains(piece)) return;
    if (_mode == GameMode.vsAi && _turn != Turn.player) return;
    _selectedPiece = piece;
    notifyListeners();
  }

  void placeSelectedPiece(String slotId) {
    if (_selectedPiece == null || _status != GameStatus.playing) return;
    if (_mode == GameMode.vsAi && _turn != Turn.player) return;

    final slotIndex = _slots.indexWhere((slot) => slot.id == slotId);
    if (slotIndex < 0) return;
    if (_slots[slotIndex].isOccupied) return;

    _slots = _slots.map((slot) {
      if (slot.id == slotId) return slot.copyWith(occupiedPiece: _selectedPiece);
      return slot;
    }).toList(growable: false);

    _availablePieces.remove(_selectedPiece);
    _selectedPiece = null;

    _refreshTorque();
    _resolveAfterMove(actor: Turn.player);

    if (_mode == GameMode.vsAi && _status == GameStatus.playing) {
      _turn = Turn.ai;
      notifyListeners();
      Future<void>.delayed(const Duration(milliseconds: 450), _takeAiTurn);
    } else {
      notifyListeners();
    }
  }

  void _takeAiTurn() {
    if (_mode != GameMode.vsAi || _status != GameStatus.playing) return;

    final aiPiece = _selectAiPiece();
    if (aiPiece == null) {
      _status = GameStatus.won;
      notifyListeners();
      return;
    }

    final move = aiEngine.chooseMove(slots: _slots, piece: aiPiece);
    if (move == null) {
      _status = GameStatus.won;
      notifyListeners();
      return;
    }

    _slots = _slots.map((slot) {
      if (slot.id == move.slotId) {
        return slot.copyWith(occupiedPiece: aiPiece.copyWith(owner: PieceOwner.ai));
      }
      return slot;
    }).toList(growable: false);

    _availablePieces.remove(aiPiece);
    _refreshTorque();
    _resolveAfterMove(actor: Turn.ai);

    if (_status == GameStatus.playing) {
      _turn = Turn.player;
    }
    notifyListeners();
  }

  Piece? _selectAiPiece() {
    if (_availablePieces.isEmpty) return null;
    final sorted = [..._availablePieces]..sort((a, b) => b.weight.compareTo(a.weight));

    for (final piece in sorted) {
      final move = aiEngine.chooseMove(slots: _slots, piece: piece);
      if (move != null) return piece;
    }
    return null;
  }

  void _resolveAfterMove({required Turn actor}) {
    if (!balanceLogic.isBalanced(_torque)) {
      _status = actor == Turn.player ? GameStatus.lost : GameStatus.won;
      _recordCompletionIfNeeded();
      return;
    }

    if (_availablePieces.isEmpty) {
      _status = GameStatus.won;
      _recordCompletionIfNeeded();
      return;
    }

    _status = GameStatus.playing;
  }

  void _placeInitialPiece(int weight, int distance) {
    final piece = _createPiece(weight, owner: PieceOwner.level);
    _slots = _slots.map((slot) {
      if (slot.distance == distance) {
        return slot.copyWith(occupiedPiece: piece);
      }
      return slot;
    }).toList(growable: false);
  }

  Piece _createPiece(int weight, {required PieceOwner owner}) {
    _pieceCounter += 1;
    return Piece(
      id: 'p$_pieceCounter',
      type: PieceType.fromWeight(weight),
      owner: owner,
    );
  }

  void _refreshTorque() {
    _torque = balanceLogic.computeTorque(_slots);
  }

  void _recordCompletionIfNeeded() {
    if (_completionRecorded || _status == GameStatus.playing) return;
    _completionRecorded = true;

    if (_status == GameStatus.won) {
      _wins += 1;
    } else if (_status == GameStatus.lost) {
      _losses += 1;
    }

    if (_activeLevelId != null) {
      _levelsPlayed.add(_activeLevelId!);
    }

    unawaited(
      AppStorage.instance.saveStats(
        levelsPlayed: _levelsPlayed.toList(growable: false),
        wins: _wins,
        losses: _losses,
      ),
    );
  }

}
