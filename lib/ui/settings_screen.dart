import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool animationsEnabled = true;
  bool soundEnabled = true;
  bool highContrast = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final snapshot = await AppStorage.instance.loadSettings();
    if (!mounted) return;
    setState(() {
      animationsEnabled = snapshot.animationsEnabled;
      soundEnabled = snapshot.soundEnabled;
      highContrast = snapshot.highContrast;
    });
  }

  void _persistSettings() {
    AppStorage.instance.saveSettings(
      animationsEnabled: animationsEnabled,
      soundEnabled: soundEnabled,
      highContrast: highContrast,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _settingCard(
              child: SwitchListTile.adaptive(
                value: animationsEnabled,
                title: const Text('Animations'),
                subtitle: const Text('Enable board wobble and placement motion.'),
                onChanged: (value) => setState(() { animationsEnabled = value; _persistSettings(); }),
              ),
            )
                .animate()
                .fadeIn(duration: 250.ms)
                .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 10),
            _settingCard(
              child: SwitchListTile.adaptive(
                value: soundEnabled,
                title: const Text('Sound Effects'),
                subtitle: const Text('Reserved for future SFX integration.'),
                onChanged: (value) => setState(() { soundEnabled = value; _persistSettings(); }),
              ),
            )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 10),
            _settingCard(
              child: SwitchListTile.adaptive(
                value: highContrast,
                title: const Text('High Contrast UI'),
                subtitle: const Text('Improves readability in bright environments.'),
                onChanged: (value) => setState(() { highContrast = value; _persistSettings(); }),
              ),
            )
                .animate()
                .fadeIn(duration: 350.ms)
                .slideY(begin: 0.06, end: 0, curve: Curves.easeOut),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Continue'),
              ),
            ).animate().fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _settingCard({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
