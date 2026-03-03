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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                // LEFT column: title + penguin scene
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
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  'BALANCE',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFFFE082),
                                    height: 1.1,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Balance your flock!',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFFB3E5FC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Decorative penguin scene
                      _PenguinScene(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // RIGHT column: buttons + stats
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFE082)),
                                const SizedBox(width: 6),
                                Text(
                                  'Played $played  •  Wins $wins',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
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
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: filled
                ? const Color(0xFFFF6B35)
                : subtle
                    ? Colors.white.withValues(alpha: 0.18)
                    : Colors.white.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(30),
            border: filled
                ? null
                : Border.all(
                    color: subtle
                        ? Colors.white.withValues(alpha: 0.30)
                        : Colors.white.withValues(alpha: 0.50),
                    width: 1.5,
                  ),
            boxShadow: filled
                ? [
                    const BoxShadow(
                      color: Color(0x55FF6B35),
                      blurRadius: 14,
                      offset: Offset(0, 5),
                    ),
                  ]
                : null,
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
                  color: filled ? Colors.white : Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Decorative penguin group with mini seesaw.
class _PenguinScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          // Mini seesaw
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
          Container(
            width: 14,
            height: 20,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF607D8B), Color(0xFF37474F)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }
}
