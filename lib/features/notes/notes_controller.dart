import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_store.dart';
import 'notes_repo.dart';
import 'note.dart';

final storeProvider = FutureProvider<LocalStore>((ref) async => LocalStore.create());
final notesRepoProvider = Provider<NotesRepo>((ref)=> NotesRepo(ref.watch(storeProvider).requireValue));

class NotesState {
  final List<Note> items; final bool loading; final String query;
  NotesState({required this.items, this.loading=false, this.query=''});
  NotesState copyWith({List<Note>? items, bool? loading, String? query}) => NotesState(items: items??this.items, loading: loading??this.loading, query: query??this.query);
  Iterable<Note> filtered() {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((n)=> n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q));
  }
}

class NotesController extends StateNotifier<NotesState> {
  NotesController(this.ref): super(NotesState(items: const [], loading: true)){ load(); }
  final Ref ref;
  Future<void> load() async { state = state.copyWith(loading: true); final r = ref.read(notesRepoProvider); state = state.copyWith(items: await r.all(), loading: false); }
  Future<void> save(Note n) async { await ref.read(notesRepoProvider).save(n); await load(); }
  Future<void> remove(String id) async { await ref.read(notesRepoProvider).delete(id); await load(); }
  void setQuery(String q) => state = state.copyWith(query: q);
}
final notesProvider = StateNotifierProvider<NotesController, NotesState>((ref)=> NotesController(ref));
