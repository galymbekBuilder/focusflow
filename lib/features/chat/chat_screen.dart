import 'package:flutter/material.dart';
import '../../ui/theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with AutomaticKeepAliveClientMixin {
  final _c = TextEditingController(); final _messages = <Map<String,String>>[];
  @override bool get wantKeepAlive => true;
  @override Widget build(BuildContext context) {
    super.build(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Чат ИИ (заглушка)')),
      body: Column(children: [
        Expanded(child: ListView.builder(
          padding: const EdgeInsets.all(FFGap.md),
          itemCount: _messages.length,
          itemBuilder: (_, i){
            final m = _messages[i]; final isUser = m["role"]=="user";
            final color = isUser ? cs.primaryContainer : cs.surfaceContainerHighest;
            return Align(alignment: isUser?Alignment.centerRight:Alignment.centerLeft, child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4), padding: const EdgeInsets.all(12), constraints: const BoxConstraints(maxWidth: 560),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)), child: Text(m["text"]??""),
            ));
          },
        )),
        SafeArea(top:false, child: Padding(
          padding: const EdgeInsets.fromLTRB(FFGap.md, FFGap.sm, FFGap.md, FFGap.md),
          child: Row(children: [
            Expanded(child: TextField(controller: _c, decoration: const InputDecoration(hintText: 'Спроси про план, привычки…'))),
            const SizedBox(width: FFGap.sm),
            FilledButton.icon(onPressed: (){
              final t = _c.text.trim(); if (t.isEmpty) return;
              setState(()=> _messages.add({"role":"user","text":t}));
              setState(()=> _messages.add({"role":"assistant","text":"Заглушка ответа. Будет LLM."}));
              _c.clear();
            }, icon: const Icon(Icons.send), label: const Text('Отправить')),
          ]),
        )),
      ]),
    );
  }
}
