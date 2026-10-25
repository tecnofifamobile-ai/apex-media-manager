import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F111A), // Color oscuro de fondo de las imgenes
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5A67D8), // Acento purpura/azulado
        surface: Color(0xFF1E2132), // Color de las tarjetas
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyMedium: GoogleFonts.outfit(color: Colors.white70),
        titleMedium: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }
}
