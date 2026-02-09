import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Importiere deine Screens
import 'package:gym_tracker/core/routing/scaffold_with_nav.dart';
import 'package:gym_tracker/features/exercises/exercises_screen.dart';
import 'package:gym_tracker/features/history/history_screen.dart';
import 'package:gym_tracker/features/home/home_screen.dart';
import 'package:gym_tracker/features/stats/stats_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Wir erstellen den Router als normale Variable, da er sich nicht oft ändert.
// Falls du später Login-Status brauchst, machen wir daraus einen Provider.
final goRouter = GoRouter(
  initialLocation: '/',
  navigatorKey: _rootNavigatorKey,
  routes: [
    // Die ShellRoute umhüllt die Tabs mit der BottomBar
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ScaffoldWithNav(navigationShell: navigationShell);
      },
      branches: [
        // Tab 1: Home / Routinen
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          ],
        ),
        // Tab 2: Übungen
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/exercises',
              builder: (context, state) => const ExercisesScreen(),
            ),
          ],
        ),
        // Tab 3: Historie
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
        // Tab 4: Statistik
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
