import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_controller.dart';
import '../../ui/theme/app_theme.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final c = TextEditingController();
    final cross = MediaQuery.sizeOf(context).width >= 900 ? 3 : 2;
    return Scaffold(
      appBar: AppBar(title: const Text('Привычки')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(FFGap.md),
          child: Row(children: [
            Expanded(child: TextField(controller: c, decoration: const InputDecoration(hintText: 'Новая привычка'))),
            const SizedBox(width: FFGap.sm),
            FilledButton.icon(onPressed: () async { final t = c.text.trim(); if (t.isNotEmpty){ await ref.read(habitsProvider.notifier).add(t); c.clear(); } }, icon: const Icon(Icons.add), label: const Text('Добавить')),
          ]),
        ),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(FFGap.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, crossAxisSpacing: FFGap.md, mainAxisSpacing: FFGap.md, childAspectRatio: 1.4),
          itemCount: habits.length,
          itemBuilder: (_, i) {
            final h = habits[i];
            return Card(child: Padding(
              padding: const EdgeInsets.all(FFGap.md),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(h.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: FFGap.sm),
                Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i){
                  final filled = (h.streak > i) ? 1 : 0; final barH = 12 + (filled*36);
                  return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: AnimatedContainer(duration: FFDurations.normal, height: barH.toDouble(), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)))));
                }))),
                const SizedBox(height: FFGap.sm),
                Row(children: [
                  IconButton(tooltip: 'Чек-ин', onPressed: () async => ref.read(habitsProvider.notifier).bump(h.id), icon: const Icon(Icons.check_circle_outline)),
                  IconButton(tooltip: h.active ? 'Пауза' : 'Возобновить', onPressed: () async => ref.read(habitsProvider.notifier).toggle(h.id), icon: Icon(h.active ? Icons.pause_circle : Icons.play_circle)),
                  const Spacer(),
                  IconButton(tooltip: 'Удалить', onPressed: () async => ref.read(habitsProvider.notifier).remove(h.id), icon: const Icon(Icons.delete_outline)),
                ]),
              ]),
            ));
          },
        )),
      ]),
    );
  }
}
