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
