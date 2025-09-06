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
