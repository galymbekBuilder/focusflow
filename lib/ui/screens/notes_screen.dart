import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleScaffold(title: 'Заметки');
  }
}

class _SimpleScaffold extends StatelessWidget {
  final String title;
  const _SimpleScaffold({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(title)), body: const Center(child: Text('Заглушка')));
  }
}
