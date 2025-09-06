import 'package:uuid/uuid.dart';
import '../../core/local_store.dart';
import 'habit.dart';

const _kHabits = "habits_v1";
final _uuid = Uuid();

class HabitsRepo {
  HabitsRepo(this.store); final LocalStore store;
  Habit newHabit(String title) => Habit(id:_uuid.v4(), title:title);
  Future<List<Habit>> all() async {
    final l = await store.getList(_kHabits);
    return [for (final m in l.cast<Map>()) Habit.fromMap(Map<String,dynamic>.from(m))];
  }
  Future<void> save(Habit h) async {
    final list = await all(); final map = {for (final x in list) x.id: x}; map[h.id]=h;
    await store.setList(_kHabits, map.values.map((e)=>e.toMap()).toList());
  }
  Future<void> delete(String id) async {
    final list = await all();
    await store.setList(_kHabits, [for (final x in list) if (x.id != id) x.toMap()]);
  }
}
