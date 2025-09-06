class Habit {
  final String id; final String title; final bool active; final int streak; final DateTime? lastCheck;
  const Habit({required this.id, required this.title, this.active=true, this.streak=0, this.lastCheck});
  Habit copyWith({String? title, bool? active, int? streak, DateTime? lastCheck}) =>
    Habit(id:id,title:title??this.title,active:active??this.active,streak:streak??this.streak,lastCheck:lastCheck??this.lastCheck);
  Map<String,dynamic> toMap()=>{'id':id,'title':title,'active':active,'streak':streak,'lastCheck':lastCheck?.toIso8601String()};
  static Habit fromMap(Map<String,dynamic> m)=> Habit(id:m['id'],title:m['title']??'',active:m['active']??true,streak:(m['streak']??0) as int,lastCheck: m['lastCheck']!=null?DateTime.tryParse(m['lastCheck']):null);
}
