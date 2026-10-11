import 'package:flutter/material.dart';

/// Central place for the app's look. See README → "Customising the app".
///
/// Material 3 derives the whole colour palette (buttons, app bar, cards,
/// progress indicators, light and dark variants) from this one seed colour.
/// Try e.g. `Colors.indigo`, `Colors.deepOrange` or `Color(0xFF2E7D32)`.
const Color appSeedColor = Colors.teal;

/// Light theme, used when the system is in light mode.
final ThemeData lightTheme = _buildTheme(Brightness.light);

/// Dark theme, used when the system is in dark mode.
final ThemeData darkTheme = _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: appSeedColor,
      brightness: brightness,
    ),
    // Further global styling goes here, for example:
    //   fontFamily: 'Roboto',
    //   appBarTheme: const AppBarTheme(centerTitle: true),
    //   filledButtonTheme: FilledButtonThemeData(style: FilledButton.styleFrom(
    //     minimumSize: const Size.fromHeight(52),
    //   )),
  );
}
