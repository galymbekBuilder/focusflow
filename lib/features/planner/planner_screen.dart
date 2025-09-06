import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'planner_controller.dart';
import '../../ui/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(plannerProvider);
    final ctrl = ref.read(plannerProvider.notifier);
    final titleC = TextEditingController(); final estC = TextEditingController(text: '30');

    return Scaffold(
      appBar: AppBar(
        title: Text('План • ${DateFormat('d MMM', 'ru').format(ctrl.day)}'),
        actions: [
          IconButton(onPressed: () async { await ctrl.setDay(ctrl.day.add(const Duration(days: -1))); }, icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: () async { await ctrl.setDay(ctrl.day.add(const Duration(days: 1)));  }, icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(FFGap.md),
        children: [
          Row(children: [
            Expanded(child: TextField(controller: titleC, decoration: const InputDecoration(hintText: 'Новая задача'))),
            const SizedBox(width: FFGap.sm),
            SizedBox(width: 90, child: TextField(controller: estC, decoration: const InputDecoration(labelText: 'мин'), keyboardType: TextInputType.number)),
            const SizedBox(width: FFGap.sm),
            FilledButton.icon(onPressed: () async {
              final title = titleC.text.trim(); final est = int.tryParse(estC.text.trim()) ?? 30;
              if (title.isNotEmpty) { await ctrl.add(title, est); titleC.clear(); }
            }, icon: const Icon(Icons.add), label: const Text('Добавить')),
          ]),
          const SizedBox(height: FFGap.md),
          for (final t in tasks)
            Card(child: CheckboxListTile(
              value: t.done,
              onChanged: (_) async { await ctrl.toggleDone(t.id); },
              title: Text('${t.title} • ${t.estMin} мин'),
              secondary: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: 'Завтра',  onPressed: () async { await ctrl.moveToTomorrow(t.id); }, icon: const Icon(Icons.calendar_today_outlined)),
                IconButton(tooltip: 'Удалить', onPressed: () async {
                  final removed = t; await ctrl.remove(t.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Удалено'), action: SnackBarAction(label: 'Отменить', onPressed: () async { await ctrl.save(removed); })),
                  );
                }, icon: const Icon(Icons.delete_outline)),
              ]),
            )),
        ],
      ),
    );
  }
}
