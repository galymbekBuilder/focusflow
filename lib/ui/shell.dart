import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'theme/breakpoints.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final loc = GoRouterState.of(context).uri.toString();

    final tabs = const [
      ('/', Icons.today, 'Сегодня'),
      ('/notes', Icons.notes, 'Заметки'),
      ('/planner', Icons.schedule, 'План'),
      ('/habits', Icons.flag, 'Привычки'),
      ('/problems', Icons.report_problem, 'Проблемы'),
      ('/chat', Icons.smart_toy, 'Чат'),
    ];

    int currentIndex = tabs.indexWhere((t) => loc == '/' ? t.$1 == '/' : loc.startsWith(t.$1));
    if (currentIndex < 0) currentIndex = 0;

    if (w < FFBp.xs) {
      return Scaffold(
        body: SafeArea(child: AnimatedSwitcher(duration: FFDurations.normal, child: KeyedSubtree(key: ValueKey(loc), child: child))),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => context.go(tabs[i].$1),
          destinations: [for (final t in tabs) NavigationDestination(icon: Icon(t.$2), label: t.$3)],
        ),
      );
    } else if (w < FFBp.md) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => context.go(tabs[i].$1),
            destinations: [for (final t in tabs) NavigationRailDestination(icon: Icon(t.$2), label: Text(t.$3))],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(child: AnimatedSwitcher(duration: FFDurations.normal, child: KeyedSubtree(key: ValueKey(loc), child: child)))),
        ]),
      );
    } else {
      final drawer = NavigationDrawer(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(tabs[i].$1),
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(16,24,16,8), child: Text('FocusFlow', style: TextStyle(fontWeight: FontWeight.w700))),
          const Divider(height: 1),
          for (final t in tabs) NavigationDrawerDestination(icon: Icon(t.$2), label: Text(t.$3)),
        ],
      );
      return Scaffold(
        body: Row(children: [
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 300), child: drawer),
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(child: AnimatedSwitcher(duration: FFDurations.normal, child: KeyedSubtree(key: ValueKey(loc), child: child)))),
        ]),
      );
    }
  }
}
