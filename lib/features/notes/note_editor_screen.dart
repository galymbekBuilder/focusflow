import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'notes_controller.dart';
import 'note.dart';

class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({super.key});
  @override
  Widget build(BuildContext context) => const NoteEditorDialog();
}

class NoteEditorDialog extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorDialog({super.key, this.noteId});
  @override ConsumerState<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends ConsumerState<NoteEditorDialog> {
  late final TextEditingController _t;
  late final TextEditingController _c;
  Note? _original;
  bool _dirty = false;
  final _uuid = const Uuid();
  @override
  void initState() {
    super.initState();
    final items = ref.read(notesProvider).items;
    _original = items.firstWhere((e)=> e.id == widget.noteId, orElse: ()=> Note(id: _uuid.v4(), title: "", content: "", updatedAt: DateTime.now()));
    _t = TextEditingController(text: _original?.title ?? "");
    _c = TextEditingController(text: _original?.content ?? "");
    _t.addListener(()=> setState(()=> _dirty = true));
    _c.addListener(()=> setState(()=> _dirty = true));
  }
  Future<void> _save() async {
    final n = (_original ?? Note(id: _uuid.v4(), title: "", content: "", updatedAt: DateTime.now()))
      .copyWith(title: _t.text.trim(), content: _c.text.trim(), updatedAt: DateTime.now());
    await ref.read(notesProvider.notifier).save(n);
    setState(()=> _dirty = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Сохранено")));
  }
  Future<bool> _confirmExit() async {
    if (!_dirty) return true;
    final res = await showDialog<bool>(context: context, builder: (_)=> AlertDialog(
      title: const Text("Есть несохранённые изменения"),
      content: const Text("Сохранить перед выходом?"),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context, true), child: const Text("Не сохранять")),
        FilledButton(onPressed: () async { await _save(); if (mounted) Navigator.pop(context, true); }, child: const Text("Сохранить")),
      ],
    ));
    return res ?? false;
  }
  @override
  Widget build(BuildContext context) {
    final dialog = LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 720 && c.maxHeight >= 560;
      final child = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 720, minHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _t, decoration: const InputDecoration(hintText: "Заголовок"), textInputAction: TextInputAction.next),
            const SizedBox(height: 12),
            Expanded(child: TextField(controller: _c, decoration: const InputDecoration(hintText: "Текст"), maxLines: null, expands: true, keyboardType: TextInputType.multiline)),
            const SizedBox(height: 12),
            Row(children: [
              FilledButton(onPressed: _save, child: const Text("Сохранить")),
              const SizedBox(width: 8),
              TextButton(onPressed: () async { final ok = await _confirmExit(); if (ok && mounted) Navigator.pop(context, true); }, child: const Text("Закрыть")),
            ]),
          ]),
        ),
      );
      return Center(child: Material(elevation: 2, clipBehavior: Clip.antiAlias, borderRadius: BorderRadius.circular(16), child: SizedBox(width: wide ? 820 : double.infinity, height: wide ? 620 : double.infinity, child: child)));
    });
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async { if (!didPop) { final ok = await _confirmExit(); if (ok && mounted) Navigator.pop(context, true); } },
      child: Scaffold(body: dialog),
    );
  }
}
