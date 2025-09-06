import 'package:uuid/uuid.dart';
import '../../core/local_store.dart';
import 'problem.dart';

const _kProblems = "problems_v1";
final _uuid = Uuid();

class ProblemsRepo {
  ProblemsRepo(this.store); final LocalStore store;
  Problem newProblem(String text) => Problem(id:_uuid.v4(), text:text);
  Future<List<Problem>> all() async {
    final l = await store.getList(_kProblems);
    return [for (final m in l.cast<Map>()) Problem.fromMap(Map<String,dynamic>.from(m))];
  }
  Future<void> save(Problem p) async {
    final list = await all(); final map = {for (final x in list) x.id: x}; map[p.id]=p;
    await store.setList(_kProblems, map.values.map((e)=>e.toMap()).toList());
  }
  Future<void> delete(String id) async {
    final list = await all();
    await store.setList(_kProblems, [for (final x in list) if (x.id != id) x.toMap()]);
  }
}
