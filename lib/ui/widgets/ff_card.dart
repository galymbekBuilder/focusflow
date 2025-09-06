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
