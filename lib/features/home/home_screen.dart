import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/ff_card.dart';
import '../../ui/widgets/ff_section_header.dart';
import '../../ui/widgets/ff_buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Сегодня')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(FFGap.md),
            child: Wrap(spacing: FFGap.md, runSpacing: FFGap.md, children: [
              FFPrimaryButton('Создать задачу', icon: Icons.add_task, onPressed: () => context.go('/planner')),
              FFTonalButton('Новая заметка', icon: Icons.note_add, onPressed: () => context.go('/notes/edit')),
            ]),
          ),
        ),
        SliverToBoxAdapter(child: FFSectionHeader('Разделы')),
        SliverPadding(
          padding: const EdgeInsets.all(FFGap.md),
          sliver: SliverGrid.count(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 3 : 2,
            mainAxisSpacing: FFGap.md, crossAxisSpacing: FFGap.md,
            children: [
              FFCard(title: 'Заметки', subtitle: 'Создавай и редактируй', leading: const Icon(Icons.notes), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/notes')),
              FFCard(title: 'Планировщик', subtitle: 'День/Неделя', leading: const Icon(Icons.schedule), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/planner')),
              FFCard(title: 'Привычки', subtitle: 'Стрики и чек-ин', leading: const Icon(Icons.flag), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/habits')),
              FFCard(title: 'Проблемы', subtitle: 'Приоритеты и статус', leading: const Icon(Icons.report_problem), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/problems')),
              FFCard(title: 'Чат ИИ', subtitle: 'Заглушка, готов к интеграции', leading: const Icon(Icons.smart_toy), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/chat')),
            ],
          ),
        ),
      ],
    );
  }
}
