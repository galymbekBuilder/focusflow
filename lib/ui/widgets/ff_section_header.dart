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
