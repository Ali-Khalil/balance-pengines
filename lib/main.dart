import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/level.dart';
import 'ui/game_screen.dart';
import 'ui/home_screen.dart';
import 'ui/settings_screen.dart';

void main() {
  runApp(const PenguinBalanceApp());
}

class PenguinBalanceApp extends StatelessWidget {
  const PenguinBalanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final levels = loadBuiltInLevels();

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => _fadePage(state, HomeScreen(levels: levels)),
        ),
        GoRoute(
          path: '/levels',
          pageBuilder: (context, state) => _fadePage(state, HomeScreen(levels: levels)),
        ),
        GoRoute(
          path: '/solo/:id',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id'];
            final level = levels.firstWhere((l) => l.id == id, orElse: () => levels.first);
            return _fadePage(state, GameScreen.solo(level: level));
          },
        ),
        GoRoute(
          path: '/vs-ai',
          pageBuilder: (context, state) => _fadePage(state, const GameScreen.vsAi()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => _fadePage(state, const SettingsScreen()),
        ),
      ],
    );

    final baseTextTheme = GoogleFonts.nunitoTextTheme();

    return MaterialApp.router(
      title: 'Penguin Balance',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF33A1D9)),
        useMaterial3: true,
        textTheme: baseTextTheme,
      ),
    );
  }
}

CustomTransitionPage<void> _fadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}
