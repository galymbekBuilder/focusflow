import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_store.dart';
import 'problems_repo.dart';
import 'problem.dart';

final storeProvider = FutureProvider<LocalStore>((ref) async => LocalStore.create());
final problemsRepoProvider = Provider<ProblemsRepo>((ref)=> ProblemsRepo(ref.watch(storeProvider).requireValue));

class ProblemsController extends StateNotifier<List<Problem>> {
  ProblemsController(this.ref): super(const []){ load(); }
  final Ref ref;
  Future<void> load() async { state = await ref.read(problemsRepoProvider).all(); }
  Future<void> add(String text, int pr) async { final repo = ref.read(problemsRepoProvider); await repo.save(repo.newProblem(text).copyWith(priority: pr)); await load(); }
  Future<void> update(Problem p) async { await ref.read(problemsRepoProvider).save(p); await load(); }
  Future<void> remove(String id) async { await ref.read(problemsRepoProvider).delete(id); await load(); }
}
final problemsProvider = StateNotifierProvider<ProblemsController, List<Problem>>((ref)=> ProblemsController(ref));
