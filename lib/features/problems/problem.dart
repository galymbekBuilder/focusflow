class Problem {
  final String id; final String text; final int priority; final String status; // open/doing/done
  const Problem({required this.id, required this.text, this.priority=3, this.status='open'});
  Problem copyWith({String? text, int? priority, String? status}) => Problem(id:id, text:text??this.text, priority:priority??this.priority, status:status??this.status);
  Map<String,dynamic> toMap()=>{'id':id,'text':text,'priority':priority,'status':status};
  static Problem fromMap(Map<String,dynamic> m)=> Problem(id:m['id'],text:m['text']??'',priority:(m['priority']??3) as int,status:m['status']??'open');
}
