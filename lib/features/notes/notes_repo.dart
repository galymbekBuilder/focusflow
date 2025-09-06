import 'package:uuid/uuid.dart';
import '../../core/local_store.dart';
import 'note.dart';

const _kNotes = "notes_v1";
final _uuid = Uuid();

class NotesRepo {
  NotesRepo(this.store);
  final LocalStore store;

  Note newNote() => Note(id: _uuid.v4(), title: "", content: "", updatedAt: DateTime.now());

  Future<List<Note>> all() async {
    final l = await store.getList(_kNotes);
    return [for (final m in l.cast<Map>()) Note.fromMap(Map<String,dynamic>.from(m))]..sort((a,b)=>b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> save(Note n) async {
    final list = await all();
    final map = {for (final x in list) x.id: x};
    map[n.id] = n.copyWith(updatedAt: DateTime.now());
    await store.setList(_kNotes, map.values.map((e)=>e.toMap()).toList());
  }

  Future<void> delete(String id) async {
    final list = await all();
    await store.setList(_kNotes, [for (final x in list) if (x.id != id) x.toMap()]);
  }
}
