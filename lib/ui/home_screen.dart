import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🐧 Penguin Balance',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF113858),
                      ),
                ),
                const SizedBox(height: 10),
                const Text('Deterministic puzzle strategy. Place wisely!'),
                const SizedBox(height: 24),
                _HomeButton(
                  label: 'Solo Levels',
                  onTap: () => context.push('/levels'),
                ),
                const SizedBox(height: 12),
                _HomeButton(
                  label: 'VS AI',
                  onTap: () => context.push('/vs-ai'),
                ),
                const SizedBox(height: 12),
                _HomeButton(
                  label: 'Settings',
                  onTap: () => context.push('/settings'),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.separated(
                    itemBuilder: (context, index) {
                      final level = levels[index];
                      return ListTile(
                        tileColor: Colors.white.withValues(alpha: 0.8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        title: Text('Level ${level.id}: ${level.name}'),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => context.push('/solo/${level.id}'),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: levels.length,
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
  const _HomeButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1C6EA4),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
