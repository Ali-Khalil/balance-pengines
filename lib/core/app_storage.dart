import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage._();

  static final AppStorage instance = AppStorage._();

  static const String _kLevelsPlayed = 'levels_played';
  static const String _kWins = 'wins';
  static const String _kLosses = 'losses';
  static const String _kAnimationsEnabled = 'animations_enabled';
  static const String _kSoundEnabled = 'sound_enabled';
  static const String _kHighContrast = 'high_contrast';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<void> saveStats({
    required List<String> levelsPlayed,
    required int wins,
    required int losses,
  }) async {
    final prefs = await _prefs;
    await prefs.setStringList(_kLevelsPlayed, levelsPlayed);
    await prefs.setInt(_kWins, wins);
    await prefs.setInt(_kLosses, losses);
  }

  Future<GameStatsSnapshot> loadStats() async {
    final prefs = await _prefs;
    return GameStatsSnapshot(
      levelsPlayed: prefs.getStringList(_kLevelsPlayed) ?? const <String>[],
      wins: prefs.getInt(_kWins) ?? 0,
      losses: prefs.getInt(_kLosses) ?? 0,
    );
  }

  Future<void> saveSettings({
    required bool animationsEnabled,
    required bool soundEnabled,
    required bool highContrast,
  }) async {
    final prefs = await _prefs;
    await prefs.setBool(_kAnimationsEnabled, animationsEnabled);
    await prefs.setBool(_kSoundEnabled, soundEnabled);
    await prefs.setBool(_kHighContrast, highContrast);
  }

  Future<GameSettingsSnapshot> loadSettings() async {
    final prefs = await _prefs;
    return GameSettingsSnapshot(
      animationsEnabled: prefs.getBool(_kAnimationsEnabled) ?? true,
      soundEnabled: prefs.getBool(_kSoundEnabled) ?? true,
      highContrast: prefs.getBool(_kHighContrast) ?? false,
    );
  }
}

class GameStatsSnapshot {
  const GameStatsSnapshot({
    required this.levelsPlayed,
    required this.wins,
    required this.losses,
  });

  final List<String> levelsPlayed;
  final int wins;
  final int losses;
}

class GameSettingsSnapshot {
  const GameSettingsSnapshot({
    required this.animationsEnabled,
    required this.soundEnabled,
    required this.highContrast,
  });

  final bool animationsEnabled;
  final bool soundEnabled;
  final bool highContrast;
}
