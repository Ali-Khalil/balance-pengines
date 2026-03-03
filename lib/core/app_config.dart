class AppConfig {
  const AppConfig._();

  /// Runtime permissions currently required by the app.
  ///
  /// Empty by design: gameplay and persistence are fully local.
  static const List<String> requiredRuntimePermissions = <String>[];

  /// Storage backend used for settings and progress.
  static const String persistenceBackend = 'shared_preferences';
}
