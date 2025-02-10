

import 'package:expense_tracker/common_widgets/bottom_nav_bar.dart';
import 'package:expense_tracker/features/home/view/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return const BottomNavBar(); // No need to pass child here
      },
      routes: <RouteBase>[
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/stats', builder: (context, state) => const Center()),
        GoRoute(path: '/expenses', builder: (context, state) => const Center()),
        GoRoute(path: '/notifications', builder: (context, state) => const Center()),
      ],
    ),
  ],
);