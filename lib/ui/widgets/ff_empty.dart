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
