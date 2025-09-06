class TaskItem {
  final String id; final String title; final bool done; final DateTime due;
  final int estMin;
  const TaskItem({required this.id, required this.title, this.done=false, required this.due, this.estMin=30});
  TaskItem copyWith({String? title, bool? done, DateTime? due, int? estMin}) =>
    TaskItem(id:id,title:title??this.title,done:done??this.done,due:due??this.due,estMin:estMin??this.estMin);
  Map<String,dynamic> toMap()=>{'id':id,'title':title,'done':done,'due':due.toIso8601String(),'estMin':estMin};
  static TaskItem fromMap(Map<String,dynamic> m)=> TaskItem(id:m['id'],title:m['title']??'',done:m['done']??false,due:DateTime.tryParse(m['due']??'')??DateTime.now(),estMin:(m['estMin']??30) as int);
}
