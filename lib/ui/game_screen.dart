import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../core/ai_engine.dart';
import '../core/balance_logic.dart';
import '../core/game_state.dart';
import '../models/level.dart';
import '../models/piece.dart';
import 'board_widget.dart';
import 'piece_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen.solo({super.key, required this.level}) : vsAi = false;
  const GameScreen.vsAi({super.key})
      : level = null,
        vsAi = true;

  final Level? level;
  final bool vsAi;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late final GameState gameState;
  late final AnimationController _placementController;
  late final ConfettiController _confettiController;

  GameStatus _lastStatus = GameStatus.playing;
  Piece? _animatingPiece;
  String? _targetSlotId;

  @override
  void initState() {
    super.initState();
    gameState = GameState(
      balanceLogic: const BalanceLogic(tolerance: 1, maxTiltDegrees: 12),
      aiEngine: AiEngine(const BalanceLogic(tolerance: 1, maxTiltDegrees: 12)),
    );
    _placementController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 900));

    if (widget.vsAi) {
      gameState.startVsAi();
    } else {
      gameState.startSoloLevel(widget.level!);
    }
  }

  @override
  void dispose() {
    _placementController.dispose();
    _confettiController.dispose();
    gameState.dispose();
    super.dispose();
  }

  Future<void> _handleSlotTap(String slotId) async {
    final selected = gameState.selectedPiece;
    if (selected == null || _animatingPiece != null) return;
    if (gameState.status != GameStatus.playing) return;

    final slotIndex = gameState.slots.indexWhere((s) => s.id == slotId);
    if (slotIndex < 0 || gameState.slots[slotIndex].isOccupied) return;

    setState(() {
      _animatingPiece = selected;
      _targetSlotId = slotId;
    });

    _placementController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    gameState.placeSelectedPiece(slotId);

    setState(() {
      _animatingPiece = null;
      _targetSlotId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([gameState, _placementController]),
      builder: (context, _) {
        if (gameState.status != _lastStatus) {
          if (gameState.status == GameStatus.won) {
            _confettiController.play();
          }
          _lastStatus = gameState.status;
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.vsAi ? 'VS Deterministic AI' : 'Solo: ${widget.level!.name}'),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.lightBlue.shade100, Colors.white],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 1.2, sigmaY: 1.2),
                      child: const SizedBox.expand(),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _StatusHeader(gameState: gameState),
                          const SizedBox(height: 14),
                          BoardWidget(
                            slots: gameState.slots,
                            tiltDegrees: gameState.tiltDegrees,
                            onSlotTap: _handleSlotTap,
                          ),
                          const SizedBox(height: 12),
                          _Tray(
                            pieces: gameState.availablePieces,
                            selectedPiece: gameState.selectedPiece,
                            onTapPiece: gameState.selectPiece,
                          ),
                          const Spacer(),
                          if (gameState.status != GameStatus.playing)
                            _ResultBanner(
                              status: gameState.status,
                              onPlayAgain: () {
                                if (widget.vsAi) {
                                  gameState.startVsAi();
                                } else {
                                  gameState.startSoloLevel(widget.level!);
                                }
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: IgnorePointer(
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        numberOfParticles: 22,
                        gravity: 0.25,
                      ),
                    ),
                  ),
                  if (_animatingPiece != null && _targetSlotId != null)
                    Builder(
                      builder: (context) {
                        final targetSlot =
                            gameState.slots.firstWhere((s) => s.id == _targetSlotId);
                        return _PlacementAnimationOverlay(
                          piece: _animatingPiece!,
                          slot: _AnimatedTargetSlot(
                            targetSlot.position.dx,
                            targetSlot.position.dy,
                          ),
                          progress: Curves.easeInOut.transform(_placementController.value),
                          boardTop: 120,
                          trayTop: constraints.maxHeight * 0.62,
                        );
                      },
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _AnimatedTargetSlot {
  const _AnimatedTargetSlot(this.dx, this.dy);
  final double dx;
  final double dy;
}

class _PlacementAnimationOverlay extends StatelessWidget {
  const _PlacementAnimationOverlay({
    required this.piece,
    required this.slot,
    required this.progress,
    required this.boardTop,
    required this.trayTop,
  });

  final Piece piece;
  final double progress;
  final double boardTop;
  final double trayTop;
  final _AnimatedTargetSlot slot;

  @override
  Widget build(BuildContext context) {
    final start = Offset(MediaQuery.sizeOf(context).width * 0.5 - 48, trayTop);
    final endY = boardTop + ((slot.dy + 0.36) * 85);
    final end = Offset(MediaQuery.sizeOf(context).width * slot.dx - 48, endY);
    final offset = Offset.lerp(start, end, progress) ?? end;
    final scale = 1 + (0.12 * (1 - (progress - 0.5).abs() * 2));

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: (1 - (progress - 1).abs()).clamp(0.25, 1),
          child: PieceWidget(piece: piece),
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.gameState});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final balanced = gameState.torque.abs() <= 1;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.92),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Torque: ${gameState.torque}', style: Theme.of(context).textTheme.titleMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: balanced ? Colors.green.shade100 : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(balanced ? 'Balanced' : 'Tilting'),
          ),
          Text(
            gameState.mode == GameMode.vsAi ? 'Turn: ${gameState.turn.name.toUpperCase()}' : 'Solo',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

class _Tray extends StatelessWidget {
  const _Tray({
    required this.pieces,
    required this.selectedPiece,
    required this.onTapPiece,
  });

  final List<Piece> pieces;
  final Piece? selectedPiece;
  final ValueChanged<Piece> onTapPiece;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: pieces
            .map(
              (piece) => PieceWidget(
                piece: piece,
                selected: selectedPiece?.id == piece.id,
                onTap: () => onTapPiece(piece),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.status, required this.onPlayAgain});

  final GameStatus status;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final won = status == GameStatus.won;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: won ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            won ? 'Great balancing! You win.' : 'Board tipped too far. You lose.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FilledButton(onPressed: onPlayAgain, child: const Text('Play Again')),
        ],
      ),
    );
  }
}
