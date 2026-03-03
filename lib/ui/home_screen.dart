import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_storage.dart';
import 'arctic_background.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ArcticBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Left column: title, buttons, stats
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo + title
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Text('🐧', style: TextStyle(fontSize: 56)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'PENGUIN',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0D3349),
                                    height: 1.1,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  'BALANCE',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFF6B35),
                                    height: 1.1,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Balance your flock!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5B7FA6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Game buttons
                      _GameButton(
                        emoji: '🎯',
                        label: 'SOLO LEVELS',
                        filled: true,
                        onTap: () => context.push('/levels'),
                      ),
                      const SizedBox(height: 10),
                      _GameButton(
                        emoji: '🤖',
                        label: 'VS AI',
                        filled: false,
                        onTap: () => context.push('/vs-ai'),
                      ),
                      const SizedBox(height: 10),
                      _GameButton(
                        emoji: '⚙️',
                        label: 'SETTINGS',
                        filled: false,
                        subtle: true,
                        onTap: () => context.push('/settings'),
                      ),
                      const SizedBox(height: 16),
                      // Stats chip
                      FutureBuilder<GameStatsSnapshot>(
                        future: AppStorage.instance.loadStats(),
                        builder: (context, snapshot) {
                          final stats = snapshot.data;
                          final played = stats?.levelsPlayed.length ?? 0;
                          final wins = stats?.wins ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.80),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFC107)),
                                const SizedBox(width: 6),
                                Text(
                                  'Played $played  •  Wins $wins',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0D3349),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Right column: decorative penguin scene
                Expanded(
                  flex: 5,
                  child: _PenguinScene(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.emoji,
    required this.label,
    required this.filled,
    required this.onTap,
    this.subtle = false,
  });

  final String emoji;
  final String label;
  final bool filled;
  final bool subtle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          decoration: BoxDecoration(
            color: filled
                ? const Color(0xFFFF6B35)
                : subtle
                    ? Colors.white.withValues(alpha: 0.60)
                    : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: filled
                  ? const Color(0xFFE55520)
                  : subtle
                      ? Colors.white.withValues(alpha: 0.50)
                      : const Color(0xFFFF6B35).withValues(alpha: 0.60),
              width: filled ? 0 : 1.5,
            ),
            boxShadow: filled
                ? [
                    const BoxShadow(
                      color: Color(0x55FF6B35),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: filled
                      ? Colors.white
                      : subtle
                          ? const Color(0xFF5B7FA6)
                          : const Color(0xFF0D3349),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative right panel with a penguin balance scene.
class _PenguinScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Stacked penguin group
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text('🐧', style: TextStyle(fontSize: 28)),
              SizedBox(width: 4),
              Text('🐧', style: TextStyle(fontSize: 44)),
              SizedBox(width: 4),
              Text('🐧', style: TextStyle(fontSize: 36)),
              SizedBox(width: 4),
              Text('🐧', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 10),
          // Mini seesaw illustration
          Container(
            width: 160,
            height: 10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: const LinearGradient(
                colors: [Color(0xFF6D4C26), Color(0xFFC49A50), Color(0xFF6D4C26)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          // Fulcrum stand (mini)
          Container(
            width: 14,
            height: 20,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF607D8B), Color(0xFF37474F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Place penguins — keep it balanced!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0D3349),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
