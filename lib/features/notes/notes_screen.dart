import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'note_editor_screen.dart';
import 'notes_controller.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/ff_empty.dart';
import 'package:go_router/go_router.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final items = state.filtered().toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки'),
        actions: [IconButton(onPressed: () => context.go('/notes/edit'), icon: const Icon(Icons.add))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(FFGap.md),
          child: SearchBar(leading: const Icon(Icons.search), hintText: 'Поиск', onChanged: (v)=> ref.read(notesProvider.notifier).setQuery(v)),
        ),
        Expanded(
          child: state.loading ? const Center(child: CircularProgressIndicator())
            : items.isEmpty ? FFEmpty(icon: Icons.note_alt, title: 'Нет заметок', message: 'Создай первую',
                action: FilledButton(onPressed: ()=> context.go('/notes/edit'), child: const Text('Создать')))
            : ListView.separated(
                padding: const EdgeInsets.all(FFGap.md),
                separatorBuilder: (_, __) => const SizedBox(height: FFGap.sm),
                itemCount: items.length,
                itemBuilder: (_, i){
                  final n = items[i];
                  return Card(child: ListTile(
                    title: Text(n.title.isEmpty ? 'Без заголовка' : n.title),
                    subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      final edited = await showDialog<bool>(context: context, builder: (_)=> NoteEditorDialog(noteId: n.id));
                      if (edited == true) ref.read(notesProvider.notifier).load();
                    },
                    trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                      final removed = n; await ref.read(notesProvider.notifier).remove(n.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Удалено'), action: SnackBarAction(label:'Отменить', onPressed: () async {
                        await ref.read(notesProvider.notifier).save(removed);
                      })));
                    }),
                  ));
                },
              ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: ()=> context.go('/notes/edit'), child: const Icon(Icons.add)),
    );
  }
}
