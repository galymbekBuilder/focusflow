import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'ui/screens/home_screen.dart';
import 'ui/screens/notes_screen.dart';
import 'ui/screens/planner_screen.dart';
import 'ui/screens/habits_screen.dart';
import 'ui/screens/problems_screen.dart';
import 'ui/screens/chat_screen.dart';

final router = GoRouter(
  debugLogDiagnostics: true,
  routes: [
    GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/notes', name: 'notes', builder: (_, __) => const NotesScreen()),
    GoRoute(path: '/planner', name: 'planner', builder: (_, __) => const PlannerScreen()),
    GoRoute(path: '/habits', name: 'habits', builder: (_, __) => const HabitsScreen()),
    GoRoute(path: '/problems', name: 'problems', builder: (_, __) => const ProblemsScreen()),
    GoRoute(path: '/chat', name: 'chat', builder: (_, __) => const ChatScreen()),
  ],
);
