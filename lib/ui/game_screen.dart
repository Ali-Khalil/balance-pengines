import 'dart:ui';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/ai_engine.dart';
import '../core/balance_logic.dart';
import '../core/game_state.dart';
import '../models/level.dart';
import '../models/piece.dart';
import 'arctic_background.dart';
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
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 1400));

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

  void _resetGame() {
    if (widget.vsAi) {
      gameState.startVsAi();
    } else {
      gameState.startSoloLevel(widget.level!);
    }
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
          body: ArcticBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      // Main landscape layout
                      Row(
                        children: [
                          // Left: board zone (60%)
                          Expanded(
                            flex: 6,
                            child: Stack(
                              children: [
                                // Board centered vertically
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: BoardWidget(
                                      slots: gameState.slots,
                                      tiltDegrees: gameState.tiltDegrees,
                                      onSlotTap: _handleSlotTap,
                                    ),
                                  ),
                                ),
                                // HUD: top-left icon buttons
                                Positioned(
                                  top: 8,
                                  left: 10,
                                  child: Row(
                                    children: [
                                      _HudButton(
                                        icon: Icons.home_rounded,
                                        onTap: () => context.go('/'),
                                        tooltip: 'Home',
                                      ),
                                      const SizedBox(width: 8),
                                      _HudButton(
                                        icon: Icons.restart_alt_rounded,
                                        onTap: _resetGame,
                                        tooltip: 'Restart',
                                      ),
                                    ],
                                  ),
                                ),
                                // HUD: top-center — level/mode name
                                Positioned(
                                  top: 12,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: _ModeChip(
                                      vsAi: widget.vsAi,
                                      levelName: widget.level?.name,
                                    ),
                                  ),
                                ),
                                // HUD: top-right — VS AI turn indicator
                                if (widget.vsAi)
                                  Positioned(
                                    top: 8,
                                    right: 10,
                                    child: _TurnIndicator(turn: gameState.turn),
                                  ),
                              ],
                            ),
                          ),
                          // Right: piece tray (40%)
                          _PieceTray(
                            pieces: gameState.availablePieces,
                            selectedPiece: gameState.selectedPiece,
                            onTapPiece: gameState.selectPiece,
                            isAiTurn: widget.vsAi && gameState.turn == Turn.ai,
                          ),
                        ],
                      ),
                      // Confetti overlay
                      Align(
                        alignment: Alignment.topCenter,
                        child: IgnorePointer(
                          child: ConfettiWidget(
                            confettiController: _confettiController,
                            blastDirectionality: BlastDirectionality.explosive,
                            shouldLoop: false,
                            numberOfParticles: 30,
                            gravity: 0.22,
                            colors: const [
                              Color(0xFFFF6B35),
                              Color(0xFF4CAF50),
                              Color(0xFF2196F3),
                              Color(0xFFFFC107),
                              Color(0xFFE91E63),
                            ],
                          ),
                        ),
                      ),
                      // Result overlay (win/lose)
                      if (gameState.status != GameStatus.playing)
                        _ResultOverlay(
                          status: gameState.status,
                          onPlayAgain: _resetGame,
                        ),
                      // Piece placement animation
                      if (_animatingPiece != null && _targetSlotId != null)
                        Builder(
                          builder: (context) {
                            final targetSlot = gameState.slots.firstWhere((s) => s.id == _targetSlotId);
                            return _PlacementAnimationOverlay(
                              piece: _animatingPiece!,
                              slotDx: targetSlot.position.dx,
                              slotDy: targetSlot.position.dy,
                              progress: Curves.easeInOut.transform(_placementController.value),
                              screenWidth: constraints.maxWidth,
                              screenHeight: constraints.maxHeight,
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Small circular HUD icon button.
class _HudButton extends StatelessWidget {
  const _HudButton({required this.icon, required this.onTap, required this.tooltip});

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.92),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 20, color: const Color(0xFFFF6B35)),
        ),
      ),
    );
  }
}

/// Small chip showing game mode name.
class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.vsAi, required this.levelName});

  final bool vsAi;
  final String? levelName;

  @override
  Widget build(BuildContext context) {
    final label = vsAi ? '🤖  VS AI' : '🎯  ${levelName ?? "Solo"}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0D3349),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// VS AI turn indicator chip (top-right).
class _TurnIndicator extends StatelessWidget {
  const _TurnIndicator({required this.turn});

  final Turn turn;

  @override
  Widget build(BuildContext context) {
    final isPlayer = turn == Turn.player;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPlayer
            ? const Color(0xFFFF6B35).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPlayer ? Icons.person_rounded : Icons.smart_toy_rounded,
            size: 16,
            color: isPlayer ? Colors.white : const Color(0xFF0D3349),
          ),
          const SizedBox(width: 6),
          Text(
            isPlayer ? 'YOUR TURN' : 'AI...',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: isPlayer ? Colors.white : const Color(0xFF0D3349),
            ),
          ),
        ],
      ),
    );
  }
}

/// Right panel: piece tray with large circular tokens.
class _PieceTray extends StatelessWidget {
  const _PieceTray({
    required this.pieces,
    required this.selectedPiece,
    required this.onTapPiece,
    required this.isAiTurn,
  });

  final List<Piece> pieces;
  final Piece? selectedPiece;
  final ValueChanged<Piece> onTapPiece;
  final bool isAiTurn;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.36,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: isAiTurn ? 0.45 : 1.0,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.88),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(-2, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Panel header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    '🐧  YOUR PIECES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(height: 1, indent: 16, endIndent: 16, color: Color(0xFFFFDDCC)),
              const SizedBox(height: 8),
              // Piece tokens
              Expanded(
                child: isAiTurn
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🤖', style: TextStyle(fontSize: 32)),
                            const SizedBox(height: 8),
                            Text(
                              'AI THINKING...',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey.shade600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          children: pieces
                              .map(
                                (piece) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: PieceWidget(
                                    piece: piece,
                                    selected: selectedPiece?.id == piece.id,
                                    onTap: () => onTapPiece(piece),
                                  ),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen win/lose overlay with blur.
class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({required this.status, required this.onPlayAgain});

  final GameStatus status;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final won = status == GameStatus.won;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: ColoredBox(
          color: (won ? const Color(0xFF4CAF50) : const Color(0xFFE53935)).withValues(alpha: 0.35),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    won ? '🏆' : '😬',
                    style: const TextStyle(fontSize: 64),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    won ? 'BALANCED!' : 'TIPPED OVER!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: won ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    won ? 'Penguins are safe! 🐧' : 'Try again!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5B7FA6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: onPlayAgain,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text(
                      'PLAY AGAIN',
                      style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flying piece animation overlay from tray to board slot.
class _PlacementAnimationOverlay extends StatelessWidget {
  const _PlacementAnimationOverlay({
    required this.piece,
    required this.slotDx,
    required this.slotDy,
    required this.progress,
    required this.screenWidth,
    required this.screenHeight,
  });

  final Piece piece;
  final double slotDx;
  final double slotDy;
  final double progress;
  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    // Tray is on the right ~36% of screen width — piece starts from tray center
    final trayStartX = screenWidth * 0.68;
    final trayStartY = screenHeight * 0.5;

    // Board occupies left ~64% of screen — scale slot position to board area
    final boardAreaWidth = screenWidth * 0.60;
    final boardLeft = boardAreaWidth * slotDx - 34;
    final boardTop = screenHeight * 0.5 + (slotDy * screenHeight * 0.28);

    final start = Offset(trayStartX, trayStartY);
    final end = Offset(boardLeft, boardTop);
    final offset = Offset.lerp(start, end, progress) ?? end;
    final scale = 1 + (0.15 * (1 - (progress - 0.5).abs() * 2));

    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: (1 - (progress - 1).abs()).clamp(0.2, 1.0),
          child: PieceWidget(piece: piece),
        ),
      ),
    );
  }
}
