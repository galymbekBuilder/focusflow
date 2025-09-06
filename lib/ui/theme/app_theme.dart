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
