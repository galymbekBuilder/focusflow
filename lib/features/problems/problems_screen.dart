import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'problems_controller.dart';
import '../../ui/theme/app_theme.dart';

class ProblemsScreen extends ConsumerWidget {
  const ProblemsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(problemsProvider);
    final c = TextEditingController(); int priority = 3;
    return Scaffold(
      appBar: AppBar(title: const Text('Проблемы')),
      body: ListView(
        padding: const EdgeInsets.all(FFGap.md),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(FFGap.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Добавить'), const SizedBox(height: FFGap.sm),
              TextField(controller: c, decoration: const InputDecoration(hintText: 'Например: залипаю в соцсетях')),
              Row(children: [
                const Text('Приоритет'),
                Expanded(child: StatefulBuilder(builder: (ctx, set)=> Slider(min:1,max:5,divisions:4,label:'$priority',value: priority.toDouble(), onChanged:(v)=>set(()=>priority=v.toInt())))),
                FilledButton(onPressed: () async { final t = c.text.trim(); if (t.isNotEmpty){ await ref.read(problemsProvider.notifier).add(t,priority); c.clear(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Добавлено')));} }, child: const Text('Добавить'))
              ]),
            ]),
          )),
          const SizedBox(height: FFGap.lg),
          for (final p in items)
            Card(color: Theme.of(context).colorScheme.secondaryContainer, child: ListTile(
              leading: const Icon(Icons.lightbulb),
              title: Text(p.text),
              subtitle: Text('Приоритет: ${p.priority} • Статус: ${p.status}'),
              trailing: PopupMenuButton<String>(onSelected: (v)=> ref.read(problemsProvider.notifier).update(p.copyWith(status: v)), itemBuilder: (_)=>const [
                PopupMenuItem(value:'open', child: Text('open')),
                PopupMenuItem(value:'doing', child: Text('doing')),
                PopupMenuItem(value:'done', child: Text('done')),
              ]),
            )),
        ],
      ),
    );
  }
}
