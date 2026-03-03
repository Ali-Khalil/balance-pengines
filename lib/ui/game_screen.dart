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

class _GameScreenState extends State<GameScreen> {
  late final GameState gameState;
  late final ConfettiController _confettiController;

  GameStatus _lastStatus = GameStatus.playing;

  @override
  void initState() {
    super.initState();
    gameState = GameState(
      balanceLogic: const BalanceLogic(tolerance: 1, maxTiltDegrees: 12),
      aiEngine: AiEngine(const BalanceLogic(tolerance: 1, maxTiltDegrees: 12)),
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

  /// Handle tap-to-place flow (tap piece in tray, then tap slot on board).
  void _handleSlotTap(String slotId) {
    if (gameState.selectedPiece == null) return;
    if (gameState.status != GameStatus.playing) return;

    final slot = gameState.slots.firstWhere((s) => s.id == slotId, orElse: () => gameState.slots.first);
    if (slot.isOccupied) return;
    if (!_canPlayerDropOnSlot(slot.distance)) return;

    gameState.placeSelectedPiece(slotId);
  }

  /// Handle drag-and-drop placement.
  void _handlePieceDrop(String slotId, Piece piece) {
    if (gameState.status != GameStatus.playing) return;
    gameState.selectPiece(piece);
    gameState.placeSelectedPiece(slotId);
  }

  /// Whether the player can drop on this slot (side restriction for VS AI).
  bool _canPlayerDropOnSlot(int slotDistance) {
    if (!widget.vsAi) return true; // solo mode: any slot
    return slotDistance < 0; // VS AI: player uses left side only
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: gameState,
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
              child: Stack(
                children: [
                  // Main layout: board fills screen, tray at bottom
                  Column(
                    children: [
                      // Board zone — fills remaining space
                      Expanded(
                        child: Stack(
                          children: [
                            // Board centered
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                child: BoardWidget(
                                  slots: gameState.slots,
                                  tiltDegrees: gameState.tiltDegrees,
                                  onSlotTap: _handleSlotTap,
                                  onPieceDrop: _handlePieceDrop,
                                  canDropOnSlot: (slot) =>
                                      !slot.isOccupied && _canPlayerDropOnSlot(slot.distance),
                                ),
                              ),
                            ),
                            // HUD: top-left icon buttons
                            Positioned(
                              top: 8,
                              left: 12,
                              child: Row(
                                children: [
                                  _HudButton(
                                    icon: Icons.arrow_back_ios_new_rounded,
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
                            // HUD: top-center mode chip
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
                            // HUD: top-right turn indicator (VS AI)
                            if (widget.vsAi)
                              Positioned(
                                top: 8,
                                right: 12,
                                child: _TurnIndicator(turn: gameState.turn),
                              ),
                          ],
                        ),
                      ),
                      // Bottom piece tray — horizontal scroller
                      _BottomPieceTray(
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
                ],
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
          child: Icon(icon, size: 20, color: const Color(0xFF0D3349)),
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

/// VS AI turn indicator chip.
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

/// Bottom horizontal piece tray (80px tall strip).
class _BottomPieceTray extends StatelessWidget {
  const _BottomPieceTray({
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
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isAiTurn ? 0.45 : 1.0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: isAiTurn
            ? const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🤖', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 10),
                    Text(
                      'AI THINKING...',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5B7FA6),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  // Label
                  const Padding(
                    padding: EdgeInsets.only(left: 16, right: 8),
                    child: Text(
                      '🐧',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  // Pieces — horizontal scroll
                  Expanded(
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      itemCount: pieces.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final piece = pieces[index];
                        return DraggablePieceWidget(
                          piece: piece,
                          selected: selectedPiece?.id == piece.id,
                          onTap: () => onTapPiece(piece),
                        );
                      },
                    ),
                  ),
                ],
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
