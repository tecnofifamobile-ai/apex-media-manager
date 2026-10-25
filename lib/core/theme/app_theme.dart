import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Outfit',
    scaffoldBackgroundColor: const Color(0xFF0C0E19),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFFE0DDFF),
      onPrimary: Color(0xFF14131E),
      surface: Color(0xFF1B1C2D),
      onSurface: Colors.white,
      secondary: Color(0xFFB8B2DD),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0x0FFFFFFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0x20FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0x20FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white70),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xEEF5F3FF),
        foregroundColor: const Color(0xFF171720),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white70,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: const Color(0xF0232436),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
      iconColor: Colors.white70,
      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
    ),
    dividerColor: const Color(0x16FFFFFF),
    splashFactory: NoSplash.splashFactory,
  );
}
