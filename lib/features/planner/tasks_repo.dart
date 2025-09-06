import 'package:uuid/uuid.dart';
import '../../core/local_store.dart';
import 'task.dart';

const _kTasks = "tasks_v1";
final _uuid = Uuid();

class TasksRepo {
  TasksRepo(this.store); final LocalStore store;
  TaskItem newTask(String title, DateTime day) => TaskItem(id:_uuid.v4(), title:title, due: DateTime(day.year,day.month,day.day));
  Future<List<TaskItem>> all() async {
    final l = await store.getList(_kTasks);
    return [for (final m in l.cast<Map>()) TaskItem.fromMap(Map<String,dynamic>.from(m))];
  }
  Future<void> save(TaskItem t) async {
    final list = await all(); final map = {for (final x in list) x.id: x}; map[t.id]=t;
    await store.setList(_kTasks, map.values.map((e)=>e.toMap()).toList());
  }
  Future<void> delete(String id) async {
    final list = await all();
    await store.setList(_kTasks, [for (final x in list) if (x.id != id) x.toMap()]);
  }
}
