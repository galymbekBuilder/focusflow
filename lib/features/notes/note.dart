class Note {
  final String id; final String title; final String content; final DateTime updatedAt;
  const Note({required this.id, required this.title, required this.content, required this.updatedAt});
  Note copyWith({String? title, String? content, DateTime? updatedAt}) =>
    Note(id: id, title: title??this.title, content: content??this.content, updatedAt: updatedAt??this.updatedAt);
  Map<String, dynamic> toMap()=> {'id':id,'title':title,'content':content,'updatedAt':updatedAt.toIso8601String()};
  static Note fromMap(Map<String,dynamic> m)=> Note(id:m['id'],title:m['title']??'',content:m['content']??'',updatedAt:DateTime.tryParse(m['updatedAt']??'')??DateTime.now());
}
