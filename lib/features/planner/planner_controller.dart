import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_store.dart';
import 'tasks_repo.dart';
import 'task.dart';

final storeProvider = FutureProvider<LocalStore>((ref) async => LocalStore.create());
final tasksRepoProvider = Provider<TasksRepo>((ref)=> TasksRepo(ref.watch(storeProvider).requireValue));

class PlannerController extends StateNotifier<List<TaskItem>> {
  PlannerController(this.ref): super(const []){ load(); }
  final Ref ref;
  DateTime day = DateTime.now();
  Future<void> load() async { final all = await ref.read(tasksRepoProvider).all(); final d = DateTime(day.year,day.month,day.day); state = [for (final t in all) if (_sameDay(t.due,d)) t]; }
  bool _sameDay(DateTime a, DateTime b) => a.year==b.year && a.month==b.month && a.day==b.day;
  Future<void> setDay(DateTime d) async { day = DateTime(d.year,d.month,d.day); await load(); }
  Future<void> add(String title, int est) async { final repo = ref.read(tasksRepoProvider); await repo.save(repo.newTask(title, day).copyWith(estMin: est)); await load(); }
  Future<void> toggleDone(String id) async { final t = state.firstWhere((e)=>e.id==id); await ref.read(tasksRepoProvider).save(t.copyWith(done: !t.done)); await load(); }
  Future<void> remove(String id) async { await ref.read(tasksRepoProvider).delete(id); await load(); }
  Future<void> moveToTomorrow(String id) async { final t = state.firstWhere((e)=>e.id==id); final tomorrow = day.add(const Duration(days:1)); await ref.read(tasksRepoProvider).save(t.copyWith(due: DateTime(tomorrow.year,tomorrow.month,tomorrow.day))); await load(); }
  Future<void> save(TaskItem t) async { await ref.read(tasksRepoProvider).save(t); await load(); }
}
final plannerProvider = StateNotifierProvider<PlannerController, List<TaskItem>>((ref)=> PlannerController(ref));
