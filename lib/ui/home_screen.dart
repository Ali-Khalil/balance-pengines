import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_storage.dart';
import '../models/level.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.levels});

  final List<Level> levels;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.cyan.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.toys_rounded, size: 30, color: Color(0xFF113858)),
                          const SizedBox(width: 8),
                          Text(
                            'Penguin Balance',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF113858),
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Deterministic puzzle strategy. Place wisely!'),
                      const SizedBox(height: 14),
                      FutureBuilder<GameStatsSnapshot>(
                        future: AppStorage.instance.loadStats(),
                        builder: (context, snapshot) {
                          final stats = snapshot.data;
                          final levelsPlayed = stats?.levelsPlayed.length ?? 0;
                          final wins = stats?.wins ?? 0;
                          final losses = stats?.losses ?? 0;
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.insights_rounded, color: Color(0xFF1C6EA4)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Played: $levelsPlayed  • Wins: $wins  • Losses: $losses',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      _HomeButton(
                        label: 'Solo Levels',
                        icon: Icons.grid_view_rounded,
                        onTap: () => context.push('/levels'),
                      ),
                      const SizedBox(height: 10),
                      _HomeButton(
                        label: 'VS AI',
                        icon: Icons.smart_toy_rounded,
                        onTap: () => context.push('/vs-ai'),
                      ),
                      const SizedBox(height: 10),
                      _HomeButton(
                        label: 'Settings',
                        icon: Icons.settings_rounded,
                        onTap: () => context.push('/settings'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE6F4FF),
                            child: Icon(Icons.extension_rounded),
                          ),
                          tileColor: Colors.white.withValues(alpha: 0.9),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          title: Text('Level ${level.id}: ${level.name}'),
                          trailing: const Icon(Icons.play_circle_fill_rounded, size: 24),
                          onTap: () => context.push('/solo/${level.id}'),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: levels.length,
                    ),
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

class _HomeButton extends StatelessWidget {
  const _HomeButton({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1C6EA4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}
