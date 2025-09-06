import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui/shell.dart';
import 'features/home/home_screen.dart';
import 'features/notes/notes_screen.dart';
import 'features/notes/note_editor_screen.dart';
import 'features/planner/planner_screen.dart';
import 'features/habits/habits_screen.dart';
import 'features/problems/problems_screen.dart';
import 'features/chat/chat_screen.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: "/", builder: (_, __) => const HomeScreen()),
        GoRoute(path: "/notes", builder: (_, __) => const NotesScreen()),
        GoRoute(path: "/notes/edit", pageBuilder: (_, __) => const MaterialPage(fullscreenDialog: true, child: NoteEditorScreen())),
        GoRoute(path: "/planner", builder: (_, __) => const PlannerScreen()),
        GoRoute(path: "/habits", builder: (_, __) => const HabitsScreen()),
        GoRoute(path: "/problems", builder: (_, __) => const ProblemsScreen()),
        GoRoute(path: "/chat", builder: (_, __) => const ChatScreen()),
      ],
    ),
  ],
);
