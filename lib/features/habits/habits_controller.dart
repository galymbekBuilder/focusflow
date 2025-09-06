import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_store.dart';
import 'habits_repo.dart';
import 'habit.dart';

final storeProvider = FutureProvider<LocalStore>((ref) async => LocalStore.create());
final habitsRepoProvider = Provider<HabitsRepo>((ref)=> HabitsRepo(ref.watch(storeProvider).requireValue));

class HabitsController extends StateNotifier<List<Habit>> {
  HabitsController(this.ref): super(const []){ load(); }
  final Ref ref;
  Future<void> load() async { state = await ref.read(habitsRepoProvider).all(); }
  Future<void> add(String title) async { final repo = ref.read(habitsRepoProvider); await repo.save(repo.newHabit(title)); await load(); }
  Future<void> toggle(String id) async { final h = state.firstWhere((e)=>e.id==id); await ref.read(habitsRepoProvider).save(h.copyWith(active: !h.active)); await load(); }
  Future<void> bump(String id) async {
    final h = state.firstWhere((e)=>e.id==id);
    final today = DateTime.now();
    final last = h.lastCheck==null ? null : DateTime(h.lastCheck!.year,h.lastCheck!.month,h.lastCheck!.day);
    final nowDay = DateTime(today.year,today.month,today.day);
    if (last == nowDay) return;
    final next = h.copyWith(streak: h.streak+1, lastCheck: today);
    await ref.read(habitsRepoProvider).save(next);
    await load();
  }
  Future<void> remove(String id) async { await ref.read(habitsRepoProvider).delete(id); await load(); }
}
final habitsProvider = StateNotifierProvider<HabitsController, List<Habit>>((ref)=> HabitsController(ref));
