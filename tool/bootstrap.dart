import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  await _run('flutter', ['config', '--enable-windows-desktop', '--enable-web']);
  await _run('flutter', ['create', '--platforms=windows,android,web', '.']);

  // ---------- files ----------
  final files = <String, String>{
    // pubspec
    'pubspec.yaml': _t(r'''
name: focusflow
description: FocusFlow MVP — Riverpod + go_router + shared_preferences
publish_to: "none"
version: 1.0.0+1

environment:
  sdk: ">=3.3.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0
  shared_preferences: ^2.3.2
  intl: ^0.19.0
  uuid: ^4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
'''),

    // analysis
    'analysis_options.yaml': _t(r'''
include: package:flutter_lints/flutter.yaml
linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    unnecessary_lambdas: true
    prefer_final_locals: true
    always_declare_return_types: true
'''),

    // main
    'lib/main.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'ui/theme/app_theme.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: App()));
}

class App extends ConsumerWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'FocusFlow',
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: mode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
'''),

    // router + shell
    'lib/router.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ui/shell.dart';
import 'features/home/home_screen.dart';
import 'features/notes/notes_screen.dart';
import 'features/notes/note_editor_screen.dart';
import 'features/planner/planner_screen.dart';
import 'features/habits/habits_screen.dart';
import 'features/problems/problems_screen.dart';
import 'features/chat/chat_screen.dart';

final router = GoRouter(
  initialLocation: "/",
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: "/", builder: (_, __) => const HomeScreen()),
        GoRoute(path: "/notes", builder: (_, __) => const NotesScreen()),
        GoRoute(path: "/notes/edit", pageBuilder: (_, __) => const MaterialPage(fullscreenDialog: true, child: NoteEditorScreen())),
        GoRoute(path: "/planner", builder: (_, __) => const PlannerScreen()),
        GoRoute(path: "/habits", builder: (_, __) => const HabitsScreen()),
        GoRoute(path: "/problems", builder: (_, __) => const ProblemsScreen()),
        GoRoute(path: "/chat", builder: (_, __) => const ChatScreen()),
      ],
    ),
  ],
);
'''),

    'lib/ui/shell.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import 'theme/breakpoints.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final loc = GoRouterState.of(context).uri.toString();

    final tabs = const [
      ('/', Icons.today, 'Сегодня'),
      ('/notes', Icons.notes, 'Заметки'),
      ('/planner', Icons.schedule, 'План'),
      ('/habits', Icons.flag, 'Привычки'),
      ('/problems', Icons.report_problem, 'Проблемы'),
      ('/chat', Icons.smart_toy, 'Чат'),
    ];

    int currentIndex = tabs.indexWhere((t) => loc == '/' ? t.$1 == '/' : loc.startsWith(t.$1));
    if (currentIndex < 0) currentIndex = 0;

    if (w < FFBp.xs) {
      return Scaffold(
        body: SafeArea(child: AnimatedSwitcher(duration: FFDurations.normal, child: KeyedSubtree(key: ValueKey(loc), child: child))),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => context.go(tabs[i].$1),
          destinations: [for (final t in tabs) NavigationDestination(icon: Icon(t.$2), label: t.$3)],
        ),
      );
    } else if (w < FFBp.md) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: (i) => context.go(tabs[i].$1),
            destinations: [for (final t in tabs) NavigationRailDestination(icon: Icon(t.$2), label: Text(t.$3))],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(child: AnimatedSwitcher(duration: FFDurations.normal, child: KeyedSubtree(key: ValueKey(loc), child: child)))),
        ]),
      );
    } else {
      final drawer = NavigationDrawer(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(tabs[i].$1),
        children: [
          const Padding(padding: EdgeInsets.fromLTRB(16,24,16,8), child: Text('FocusFlow', style: TextStyle(fontWeight: FontWeight.w700))),
          const Divider(height: 1),
          for (final t in tabs) NavigationDrawerDestination(icon: Icon(t.$2), label: Text(t.$3)),
        ],
      );
      return Scaffold(
        body: Row(children: [
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 300), child: drawer),
          const VerticalDivider(width: 1),
          Expanded(child: SafeArea(child: AnimatedSwitcher(duration: FFDurations.normal, child: KeyedSubtree(key: ValueKey(loc), child: child)))),
        ]),
      );
    }
  }
}
'''),

    // theme
    'lib/ui/theme/breakpoints.dart': 'class FFBp { static const xs=600.0, md=1024.0, lg=1280.0; }\n',
    'lib/ui/theme/typography.dart': _t(r'''
import 'package:flutter/material.dart';
TextTheme ffTextTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final primary = dark ? const Color(0xFFE2E8F0) : const Color(0xFF0F172A);
  final secondary = dark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  return TextTheme(
    displayLarge: TextStyle(fontSize: 44, fontWeight: FontWeight.w700, color: primary),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: primary),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
    bodyLarge: TextStyle(fontSize: 16, color: secondary, height: 1.4),
    bodyMedium: TextStyle(fontSize: 14, color: secondary, height: 1.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondary),
  );
}
'''),
    'lib/ui/theme/app_theme.dart': _t(r'''
import 'package:flutter/material.dart';
import 'typography.dart';

class FFGap { static const xxs=4.0,xs=8.0,sm=12.0,md=16.0,lg=20.0,xl=24.0,xxl=32.0; }
class FFRadii { static const sm=12.0, md=16.0; }
class FFDurations { static const fast=Duration(milliseconds:150), normal=Duration(milliseconds:250), slow=Duration(milliseconds:400); }

ThemeData lightTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4A6CF7), brightness: Brightness.light);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    textTheme: ffTextTheme(Brightness.light),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface, elevation: 0, surfaceTintColor: scheme.surfaceTint, centerTitle: false,
      titleTextStyle: ffTextTheme(Brightness.light).titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 1, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FFRadii.md)),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FFRadii.md))),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, elevation: 1, contentTextStyle: ffTextTheme(Brightness.light).bodyMedium),
  );
}

ThemeData darkTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4A6CF7), brightness: Brightness.dark);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: ffTextTheme(Brightness.dark),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface, elevation: 0, surfaceTintColor: scheme.surfaceTint, centerTitle: false,
      titleTextStyle: ffTextTheme(Brightness.dark).titleLarge,
    ),
    cardTheme: CardThemeData(
      elevation: 1, margin: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FFRadii.md)),
    ),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(FFRadii.md))),
    snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating, elevation: 1, contentTextStyle: ffTextTheme(Brightness.dark).bodyMedium),
  );
}
'''),

    // widgets
    'lib/ui/widgets/ff_buttons.dart': _t(r'''
import 'package:flutter/material.dart';
class FFPrimaryButton extends StatelessWidget {
  final String text; final VoidCallback? onPressed; final IconData? icon;
  const FFPrimaryButton(this.text, {super.key, this.onPressed, this.icon});
  @override Widget build(BuildContext context) {
    final child = Text(text);
    return icon == null ? FilledButton(onPressed: onPressed, child: child)
                        : FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: child);
  }
}
class FFTonalButton extends StatelessWidget {
  final String text; final VoidCallback? onPressed; final IconData? icon;
  const FFTonalButton(this.text, {super.key, this.onPressed, this.icon});
  @override Widget build(BuildContext context) {
    final child = Text(text);
    return icon == null ? FilledButton.tonal(onPressed: onPressed, child: child)
                        : FilledButton.tonalIcon(onPressed: onPressed, icon: Icon(icon), label: child);
  }
}
'''),
    'lib/ui/widgets/ff_card.dart': _t(r'''
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class FFCard extends StatelessWidget {
  final Widget? leading; final String title; final String? subtitle; final Widget? trailing; final VoidCallback? onTap;
  const FFCard({super.key, this.leading, required this.title, this.subtitle, this.trailing, this.onTap});
  @override Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(FFGap.md),
          child: Row(children: [
            if (leading != null) Padding(padding: const EdgeInsets.only(right: FFGap.md), child: leading),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: t.titleMedium),
              if (subtitle != null) ...[const SizedBox(height: FFGap.xs), Text(subtitle!, style: t.bodyMedium)],
            ])),
            if (trailing != null) Padding(padding: const EdgeInsets.only(left: FFGap.md), child: trailing),
          ]),
        ),
      ),
    );
  }
}
'''),
    'lib/ui/widgets/ff_empty.dart': _t(r'''
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class FFEmpty extends StatelessWidget {
  final IconData icon; final String title; final String? message; final Widget? action;
  const FFEmpty({super.key, required this.icon, required this.title, this.message, this.action});
  @override Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme; final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(FFGap.xl),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 48, color: cs.primary), const SizedBox(height: FFGap.md),
        Text(title, style: t.titleLarge),
        if (message != null) ...[const SizedBox(height: FFGap.xs), Text(message!, style: t.bodyMedium, textAlign: TextAlign.center)],
        if (action != null) ...[const SizedBox(height: FFGap.md), action!],
      ])),
    );
  }
}
'''),
    'lib/ui/widgets/ff_section_header.dart': _t(r'''
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
class FFSectionHeader extends StatelessWidget {
  final String title; final Widget? action;
  const FFSectionHeader(this.title, {super.key, this.action});
  @override Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(FFGap.md, FFGap.lg, FFGap.md, FFGap.sm),
      child: Row(children: [Expanded(child: Text(title, style: t.titleLarge)), if (action != null) action!]),
    );
  }
}
'''),

    // home
    'lib/features/home/home_screen.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/ff_card.dart';
import '../../ui/widgets/ff_section_header.dart';
import '../../ui/widgets/ff_buttons.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar.large(title: Text('Сегодня')),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(FFGap.md),
            child: Wrap(spacing: FFGap.md, runSpacing: FFGap.md, children: [
              FFPrimaryButton('Создать задачу', icon: Icons.add_task, onPressed: () => context.go('/planner')),
              FFTonalButton('Новая заметка', icon: Icons.note_add, onPressed: () => context.go('/notes/edit')),
            ]),
          ),
        ),
        SliverToBoxAdapter(child: FFSectionHeader('Разделы')),
        SliverPadding(
          padding: const EdgeInsets.all(FFGap.md),
          sliver: SliverGrid.count(
            crossAxisCount: MediaQuery.sizeOf(context).width >= 900 ? 3 : 2,
            mainAxisSpacing: FFGap.md, crossAxisSpacing: FFGap.md,
            children: [
              FFCard(title: 'Заметки', subtitle: 'Создавай и редактируй', leading: const Icon(Icons.notes), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/notes')),
              FFCard(title: 'Планировщик', subtitle: 'День/Неделя', leading: const Icon(Icons.schedule), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/planner')),
              FFCard(title: 'Привычки', subtitle: 'Стрики и чек-ин', leading: const Icon(Icons.flag), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/habits')),
              FFCard(title: 'Проблемы', subtitle: 'Приоритеты и статус', leading: const Icon(Icons.report_problem), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/problems')),
              FFCard(title: 'Чат ИИ', subtitle: 'Заглушка, готов к интеграции', leading: const Icon(Icons.smart_toy), trailing: const Icon(Icons.chevron_right), onTap: () => context.go('/chat')),
            ],
          ),
        ),
      ],
    );
  }
}
'''),

    // notes
    'lib/features/notes/note.dart': _t(r'''
class Note {
  final String id; final String title; final String content; final DateTime updatedAt;
  const Note({required this.id, required this.title, required this.content, required this.updatedAt});
  Note copyWith({String? title, String? content, DateTime? updatedAt}) =>
    Note(id: id, title: title??this.title, content: content??this.content, updatedAt: updatedAt??this.updatedAt);
  Map<String, dynamic> toMap()=> {'id':id,'title':title,'content':content,'updatedAt':updatedAt.toIso8601String()};
  static Note fromMap(Map<String,dynamic> m)=> Note(id:m['id'],title:m['title']??'',content:m['content']??'',updatedAt:DateTime.tryParse(m['updatedAt']??'')??DateTime.now());
}
'''),
    'lib/features/notes/notes_repo.dart': _t(r'''
import 'package:uuid/uuid.dart';
import '../../core/local_store.dart';
import 'note.dart';

const _kNotes = "notes_v1";
final _uuid = Uuid();

class NotesRepo {
  NotesRepo(this.store);
  final LocalStore store;

  Note newNote() => Note(id: _uuid.v4(), title: "", content: "", updatedAt: DateTime.now());

  Future<List<Note>> all() async {
    final l = await store.getList(_kNotes);
    return [for (final m in l.cast<Map>()) Note.fromMap(Map<String,dynamic>.from(m))]..sort((a,b)=>b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> save(Note n) async {
    final list = await all();
    final map = {for (final x in list) x.id: x};
    map[n.id] = n.copyWith(updatedAt: DateTime.now());
    await store.setList(_kNotes, map.values.map((e)=>e.toMap()).toList());
  }

  Future<void> delete(String id) async {
    final list = await all();
    await store.setList(_kNotes, [for (final x in list) if (x.id != id) x.toMap()]);
  }
}
'''),
    'lib/features/notes/notes_controller.dart': _t(r'''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_store.dart';
import 'notes_repo.dart';
import 'note.dart';

final storeProvider = FutureProvider<LocalStore>((ref) async => LocalStore.create());
final notesRepoProvider = Provider<NotesRepo>((ref)=> NotesRepo(ref.watch(storeProvider).requireValue));

class NotesState {
  final List<Note> items; final bool loading; final String query;
  NotesState({required this.items, this.loading=false, this.query=''});
  NotesState copyWith({List<Note>? items, bool? loading, String? query}) => NotesState(items: items??this.items, loading: loading??this.loading, query: query??this.query);
  Iterable<Note> filtered() {
    if (query.isEmpty) return items;
    final q = query.toLowerCase();
    return items.where((n)=> n.title.toLowerCase().contains(q) || n.content.toLowerCase().contains(q));
  }
}

class NotesController extends StateNotifier<NotesState> {
  NotesController(this.ref): super(NotesState(items: const [], loading: true)){ load(); }
  final Ref ref;
  Future<void> load() async { state = state.copyWith(loading: true); final r = ref.read(notesRepoProvider); state = state.copyWith(items: await r.all(), loading: false); }
  Future<void> save(Note n) async { await ref.read(notesRepoProvider).save(n); await load(); }
  Future<void> remove(String id) async { await ref.read(notesRepoProvider).delete(id); await load(); }
  void setQuery(String q) => state = state.copyWith(query: q);
}
final notesProvider = StateNotifierProvider<NotesController, NotesState>((ref)=> NotesController(ref));
'''),
    'lib/features/notes/notes_screen.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'note_editor_screen.dart';
import 'notes_controller.dart';
import '../../ui/theme/app_theme.dart';
import '../../ui/widgets/ff_empty.dart';
import 'package:go_router/go_router.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notesProvider);
    final items = state.filtered().toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Заметки'),
        actions: [IconButton(onPressed: () => context.go('/notes/edit'), icon: const Icon(Icons.add))],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(FFGap.md),
          child: SearchBar(leading: const Icon(Icons.search), hintText: 'Поиск', onChanged: (v)=> ref.read(notesProvider.notifier).setQuery(v)),
        ),
        Expanded(
          child: state.loading ? const Center(child: CircularProgressIndicator())
            : items.isEmpty ? FFEmpty(icon: Icons.note_alt, title: 'Нет заметок', message: 'Создай первую',
                action: FilledButton(onPressed: ()=> context.go('/notes/edit'), child: const Text('Создать')))
            : ListView.separated(
                padding: const EdgeInsets.all(FFGap.md),
                separatorBuilder: (_, __) => const SizedBox(height: FFGap.sm),
                itemCount: items.length,
                itemBuilder: (_, i){
                  final n = items[i];
                  return Card(child: ListTile(
                    title: Text(n.title.isEmpty ? 'Без заголовка' : n.title),
                    subtitle: Text(n.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      final edited = await showDialog<bool>(context: context, builder: (_)=> NoteEditorDialog(noteId: n.id));
                      if (edited == true) ref.read(notesProvider.notifier).load();
                    },
                    trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () async {
                      final removed = n; await ref.read(notesProvider.notifier).remove(n.id);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Удалено'), action: SnackBarAction(label:'Отменить', onPressed: () async {
                        await ref.read(notesProvider.notifier).save(removed);
                      })));
                    }),
                  ));
                },
              ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: ()=> context.go('/notes/edit'), child: const Icon(Icons.add)),
    );
  }
}
'''),
    'lib/features/notes/note_editor_screen.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'notes_controller.dart';
import 'note.dart';

class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({super.key});
  @override
  Widget build(BuildContext context) => const NoteEditorDialog();
}

class NoteEditorDialog extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorDialog({super.key, this.noteId});
  @override ConsumerState<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

class _NoteEditorDialogState extends ConsumerState<NoteEditorDialog> {
  late final TextEditingController _t;
  late final TextEditingController _c;
  Note? _original;
  bool _dirty = false;
  final _uuid = const Uuid();
  @override
  void initState() {
    super.initState();
    final items = ref.read(notesProvider).items;
    _original = items.firstWhere((e)=> e.id == widget.noteId, orElse: ()=> Note(id: _uuid.v4(), title: "", content: "", updatedAt: DateTime.now()));
    _t = TextEditingController(text: _original?.title ?? "");
    _c = TextEditingController(text: _original?.content ?? "");
    _t.addListener(()=> setState(()=> _dirty = true));
    _c.addListener(()=> setState(()=> _dirty = true));
  }
  Future<void> _save() async {
    final n = (_original ?? Note(id: _uuid.v4(), title: "", content: "", updatedAt: DateTime.now()))
      .copyWith(title: _t.text.trim(), content: _c.text.trim(), updatedAt: DateTime.now());
    await ref.read(notesProvider.notifier).save(n);
    setState(()=> _dirty = false);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Сохранено")));
  }
  Future<bool> _confirmExit() async {
    if (!_dirty) return true;
    final res = await showDialog<bool>(context: context, builder: (_)=> AlertDialog(
      title: const Text("Есть несохранённые изменения"),
      content: const Text("Сохранить перед выходом?"),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context, true), child: const Text("Не сохранять")),
        FilledButton(onPressed: () async { await _save(); if (mounted) Navigator.pop(context, true); }, child: const Text("Сохранить")),
      ],
    ));
    return res ?? false;
  }
  @override
  Widget build(BuildContext context) {
    final dialog = LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth >= 720 && c.maxHeight >= 560;
      final child = ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 720, minHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            TextField(controller: _t, decoration: const InputDecoration(hintText: "Заголовок"), textInputAction: TextInputAction.next),
            const SizedBox(height: 12),
            Expanded(child: TextField(controller: _c, decoration: const InputDecoration(hintText: "Текст"), maxLines: null, expands: true, keyboardType: TextInputType.multiline)),
            const SizedBox(height: 12),
            Row(children: [
              FilledButton(onPressed: _save, child: const Text("Сохранить")),
              const SizedBox(width: 8),
              TextButton(onPressed: () async { final ok = await _confirmExit(); if (ok && mounted) Navigator.pop(context, true); }, child: const Text("Закрыть")),
            ]),
          ]),
        ),
      );
      return Center(child: Material(elevation: 2, clipBehavior: Clip.antiAlias, borderRadius: BorderRadius.circular(16), child: SizedBox(width: wide ? 820 : double.infinity, height: wide ? 620 : double.infinity, child: child)));
    });
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async { if (!didPop) { final ok = await _confirmExit(); if (ok && mounted) Navigator.pop(context, true); } },
      child: Scaffold(body: dialog),
    );
  }
}
'''),

    // planner
    'lib/features/planner/task.dart': _t(r'''
class TaskItem {
  final String id; final String title; final bool done; final DateTime due;
  final int estMin;
  const TaskItem({required this.id, required this.title, this.done=false, required this.due, this.estMin=30});
  TaskItem copyWith({String? title, bool? done, DateTime? due, int? estMin}) =>
    TaskItem(id:id,title:title??this.title,done:done??this.done,due:due??this.due,estMin:estMin??this.estMin);
  Map<String,dynamic> toMap()=>{'id':id,'title':title,'done':done,'due':due.toIso8601String(),'estMin':estMin};
  static TaskItem fromMap(Map<String,dynamic> m)=> TaskItem(id:m['id'],title:m['title']??'',done:m['done']??false,due:DateTime.tryParse(m['due']??'')??DateTime.now(),estMin:(m['estMin']??30) as int);
}
'''),
    'lib/core/local_store.dart': _t(r'''
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
class LocalStore {
  LocalStore(this._prefs);
  final SharedPreferences _prefs;
  static Future<LocalStore> create() async => LocalStore(await SharedPreferences.getInstance());
  Future<List<dynamic>> getList(String key) async { final s = _prefs.getString(key); if (s == null) return []; try { return jsonDecode(s) as List<dynamic>; } catch (_) { return []; } }
  Future<void> setList(String key, List<Object> value) async => _prefs.setString(key, jsonEncode(value));
}
'''),
    'lib/features/planner/tasks_repo.dart': _t(r'''
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
'''),
    'lib/features/planner/planner_controller.dart': _t(r'''
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
'''),
    'lib/features/planner/planner_screen.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'planner_controller.dart';
import '../../ui/theme/app_theme.dart';
import 'package:intl/intl.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(plannerProvider);
    final ctrl = ref.read(plannerProvider.notifier);
    final titleC = TextEditingController(); final estC = TextEditingController(text: '30');

    return Scaffold(
      appBar: AppBar(
        title: Text('План • ${DateFormat('d MMM', 'ru').format(ctrl.day)}'),
        actions: [
          IconButton(onPressed: () async { await ctrl.setDay(ctrl.day.add(const Duration(days: -1))); }, icon: const Icon(Icons.chevron_left)),
          IconButton(onPressed: () async { await ctrl.setDay(ctrl.day.add(const Duration(days: 1)));  }, icon: const Icon(Icons.chevron_right)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(FFGap.md),
        children: [
          Row(children: [
            Expanded(child: TextField(controller: titleC, decoration: const InputDecoration(hintText: 'Новая задача'))),
            const SizedBox(width: FFGap.sm),
            SizedBox(width: 90, child: TextField(controller: estC, decoration: const InputDecoration(labelText: 'мин'), keyboardType: TextInputType.number)),
            const SizedBox(width: FFGap.sm),
            FilledButton.icon(onPressed: () async {
              final title = titleC.text.trim(); final est = int.tryParse(estC.text.trim()) ?? 30;
              if (title.isNotEmpty) { await ctrl.add(title, est); titleC.clear(); }
            }, icon: const Icon(Icons.add), label: const Text('Добавить')),
          ]),
          const SizedBox(height: FFGap.md),
          for (final t in tasks)
            Card(child: CheckboxListTile(
              value: t.done,
              onChanged: (_) async { await ctrl.toggleDone(t.id); },
              title: Text('${t.title} • ${t.estMin} мин'),
              secondary: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: 'Завтра',  onPressed: () async { await ctrl.moveToTomorrow(t.id); }, icon: const Icon(Icons.calendar_today_outlined)),
                IconButton(tooltip: 'Удалить', onPressed: () async {
                  final removed = t; await ctrl.remove(t.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: const Text('Удалено'), action: SnackBarAction(label: 'Отменить', onPressed: () async { await ctrl.save(removed); })),
                  );
                }, icon: const Icon(Icons.delete_outline)),
              ]),
            )),
        ],
      ),
    );
  }
}
'''),

    // habits
    'lib/features/habits/habit.dart': _t(r'''
class Habit {
  final String id; final String title; final bool active; final int streak; final DateTime? lastCheck;
  const Habit({required this.id, required this.title, this.active=true, this.streak=0, this.lastCheck});
  Habit copyWith({String? title, bool? active, int? streak, DateTime? lastCheck}) =>
    Habit(id:id,title:title??this.title,active:active??this.active,streak:streak??this.streak,lastCheck:lastCheck??this.lastCheck);
  Map<String,dynamic> toMap()=>{'id':id,'title':title,'active':active,'streak':streak,'lastCheck':lastCheck?.toIso8601String()};
  static Habit fromMap(Map<String,dynamic> m)=> Habit(id:m['id'],title:m['title']??'',active:m['active']??true,streak:(m['streak']??0) as int,lastCheck: m['lastCheck']!=null?DateTime.tryParse(m['lastCheck']):null);
}
'''),
    'lib/features/habits/habits_repo.dart': _t(r'''
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
'''),
    'lib/features/habits/habits_controller.dart': _t(r'''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/local_store.dart';
import 'habits_repo.dart';
import 'habit.dart';

final storeProvider = FutureProvider<LocalStore>((ref) async => LocalStore.create());
final habitsRepoProvider = Provider<HabitsRepo>((ref)=> HabitsRepo(ref.watch(storeProvider).requireValue));

class HabitsController extends StateNotifier<List<Habit>> {
  HabitsController(this.ref): super(const []){ load(); }
  final Ref ref;
  Future<void> load() async { state = await ref.read(habitsRepoProvider).all(); }
  Future<void> add(String title) async { final repo = ref.read(habitsRepoProvider); await repo.save(repo.newHabit(title)); await load(); }
  Future<void> toggle(String id) async { final h = state.firstWhere((e)=>e.id==id); await ref.read(habitsRepoProvider).save(h.copyWith(active: !h.active)); await load(); }
  Future<void> bump(String id) async {
    final h = state.firstWhere((e)=>e.id==id);
    final today = DateTime.now();
    final last = h.lastCheck==null ? null : DateTime(h.lastCheck!.year,h.lastCheck!.month,h.lastCheck!.day);
    final nowDay = DateTime(today.year,today.month,today.day);
    if (last == nowDay) return;
    final next = h.copyWith(streak: h.streak+1, lastCheck: today);
    await ref.read(habitsRepoProvider).save(next);
    await load();
  }
  Future<void> remove(String id) async { await ref.read(habitsRepoProvider).delete(id); await load(); }
}
final habitsProvider = StateNotifierProvider<HabitsController, List<Habit>>((ref)=> HabitsController(ref));
'''),
    'lib/features/habits/habits_screen.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'habits_controller.dart';
import '../../ui/theme/app_theme.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final c = TextEditingController();
    final cross = MediaQuery.sizeOf(context).width >= 900 ? 3 : 2;
    return Scaffold(
      appBar: AppBar(title: const Text('Привычки')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(FFGap.md),
          child: Row(children: [
            Expanded(child: TextField(controller: c, decoration: const InputDecoration(hintText: 'Новая привычка'))),
            const SizedBox(width: FFGap.sm),
            FilledButton.icon(onPressed: () async { final t = c.text.trim(); if (t.isNotEmpty){ await ref.read(habitsProvider.notifier).add(t); c.clear(); } }, icon: const Icon(Icons.add), label: const Text('Добавить')),
          ]),
        ),
        Expanded(child: GridView.builder(
          padding: const EdgeInsets.all(FFGap.md),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cross, crossAxisSpacing: FFGap.md, mainAxisSpacing: FFGap.md, childAspectRatio: 1.4),
          itemCount: habits.length,
          itemBuilder: (_, i) {
            final h = habits[i];
            return Card(child: Padding(
              padding: const EdgeInsets.all(FFGap.md),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(h.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: FFGap.sm),
                Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: List.generate(7, (i){
                  final filled = (h.streak > i) ? 1 : 0; final barH = 12 + (filled*36);
                  return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: AnimatedContainer(duration: FFDurations.normal, height: barH.toDouble(), decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(8)))));
                }))),
                const SizedBox(height: FFGap.sm),
                Row(children: [
                  IconButton(tooltip: 'Чек-ин', onPressed: () async => ref.read(habitsProvider.notifier).bump(h.id), icon: const Icon(Icons.check_circle_outline)),
                  IconButton(tooltip: h.active ? 'Пауза' : 'Возобновить', onPressed: () async => ref.read(habitsProvider.notifier).toggle(h.id), icon: Icon(h.active ? Icons.pause_circle : Icons.play_circle)),
                  const Spacer(),
                  IconButton(tooltip: 'Удалить', onPressed: () async => ref.read(habitsProvider.notifier).remove(h.id), icon: const Icon(Icons.delete_outline)),
                ]),
              ]),
            ));
          },
        )),
      ]),
    );
  }
}
'''),

    // problems
    'lib/features/problems/problem.dart': _t(r'''
class Problem {
  final String id; final String text; final int priority; final String status; // open/doing/done
  const Problem({required this.id, required this.text, this.priority=3, this.status='open'});
  Problem copyWith({String? text, int? priority, String? status}) => Problem(id:id, text:text??this.text, priority:priority??this.priority, status:status??this.status);
  Map<String,dynamic> toMap()=>{'id':id,'text':text,'priority':priority,'status':status};
  static Problem fromMap(Map<String,dynamic> m)=> Problem(id:m['id'],text:m['text']??'',priority:(m['priority']??3) as int,status:m['status']??'open');
}
'''),
    'lib/features/problems/problems_repo.dart': _t(r'''
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
'''),
    'lib/features/problems/problems_controller.dart': _t(r'''
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
'''),
    'lib/features/problems/problems_screen.dart': _t(r'''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'problems_controller.dart';
import '../../ui/theme/app_theme.dart';

class ProblemsScreen extends ConsumerWidget {
  const ProblemsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(problemsProvider);
    final c = TextEditingController(); int priority = 3;
    return Scaffold(
      appBar: AppBar(title: const Text('Проблемы')),
      body: ListView(
        padding: const EdgeInsets.all(FFGap.md),
        children: [
          Card(child: Padding(
            padding: const EdgeInsets.all(FFGap.md),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Добавить'), const SizedBox(height: FFGap.sm),
              TextField(controller: c, decoration: const InputDecoration(hintText: 'Например: залипаю в соцсетях')),
              Row(children: [
                const Text('Приоритет'),
                Expanded(child: StatefulBuilder(builder: (ctx, set)=> Slider(min:1,max:5,divisions:4,label:'$priority',value: priority.toDouble(), onChanged:(v)=>set(()=>priority=v.toInt())))),
                FilledButton(onPressed: () async { final t = c.text.trim(); if (t.isNotEmpty){ await ref.read(problemsProvider.notifier).add(t,priority); c.clear(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Добавлено')));} }, child: const Text('Добавить'))
              ]),
            ]),
          )),
          const SizedBox(height: FFGap.lg),
          for (final p in items)
            Card(color: Theme.of(context).colorScheme.secondaryContainer, child: ListTile(
              leading: const Icon(Icons.lightbulb),
              title: Text(p.text),
              subtitle: Text('Приоритет: ${p.priority} • Статус: ${p.status}'),
              trailing: PopupMenuButton<String>(onSelected: (v)=> ref.read(problemsProvider.notifier).update(p.copyWith(status: v)), itemBuilder: (_)=>const [
                PopupMenuItem(value:'open', child: Text('open')),
                PopupMenuItem(value:'doing', child: Text('doing')),
                PopupMenuItem(value:'done', child: Text('done')),
              ]),
            )),
        ],
      ),
    );
  }
}
'''),

    // chat
    'lib/features/chat/chat_screen.dart': _t(r'''
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
'''),
  };

  for (final e in files.entries) {
    final f = File(e.key);
    await f.parent.create(recursive: true);
    await f.writeAsString(e.value, encoding: utf8);
  }

  await _run('flutter', ['pub', 'get']);
  stdout.writeln('OK: проект готов. Запускай: flutter run -d windows');
}

String _t(String s) => s.replaceAll('\r\n', '\n').trimLeft();

Future<void> _run(String exe, List<String> args) async {
  final r = await Process.run(exe, args, runInShell: true);
  stdout.write(r.stdout);
  stderr.write(r.stderr);
  if (r.exitCode != 0) {
    throw Exception('Command failed: $exe ${args.join(' ')}');
  }
}
