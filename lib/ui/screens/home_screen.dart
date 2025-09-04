import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сегодня')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Заметки'),
            onTap: () => context.go('/notes'),
          ),
          ListTile(
            title: const Text('Планировщик'),
            onTap: () => context.go('/planner'),
          ),
          ListTile(
            title: const Text('Привычки'),
            onTap: () => context.go('/habits'),
          ),
          ListTile(
            title: const Text('Проблемы'),
            onTap: () => context.go('/problems'),
          ),
          ListTile(
            title: const Text('Чат ИИ'),
            onTap: () => context.go('/chat'),
          ),
        ],
      ),
    );
  }
}
