import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'screens/assign/assign_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/people/people_screen.dart';
import 'screens/review_items/review_items_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/summary/summary_screen.dart';

/// Centralised route names for type-safe navigation.
class Routes {
  const Routes._();

  static const String home = '/';
  static const String scan = '/scan';
  static const String review = '/review';
  static const String people = '/people';
  static const String assign = '/assign';
  static const String summary = '/summary';
  static const String settings = '/settings';
}

final GoRouter _router = GoRouter(
  initialLocation: Routes.home,
  routes: <RouteBase>[
    GoRoute(
      path: Routes.home,
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: Routes.scan,
      builder: (BuildContext context, GoRouterState state) =>
          const ScanScreen(),
    ),
    GoRoute(
      path: Routes.review,
      builder: (BuildContext context, GoRouterState state) =>
          const ReviewItemsScreen(),
    ),
    GoRoute(
      path: Routes.people,
      builder: (BuildContext context, GoRouterState state) =>
          const PeopleScreen(),
    ),
    GoRoute(
      path: Routes.assign,
      builder: (BuildContext context, GoRouterState state) =>
          const AssignScreen(),
    ),
    GoRoute(
      path: Routes.summary,
      builder: (BuildContext context, GoRouterState state) =>
          const SummaryScreen(),
    ),
    GoRoute(
      path: Routes.settings,
      builder: (BuildContext context, GoRouterState state) =>
          const SettingsScreen(),
    ),
  ],
);

/// Root widget: configures Material 3 theming and the [GoRouter].
class SplitHappensApp extends StatelessWidget {
  /// Creates the root app widget.
  const SplitHappensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Split Happens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      routerConfig: _router,
    );
  }
}
