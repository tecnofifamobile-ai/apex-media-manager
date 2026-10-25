import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      fontFamily: 'Outfit',
    ).copyWith(
      scaffoldBackgroundColor: const Color(
        0xFF0F111A,
      ), // Color oscuro de fondo de las imgenes
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5A67D8), // Acento purpura/azulado
        surface: Color(0xFF1E2132), // Color de las tarjetas
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
