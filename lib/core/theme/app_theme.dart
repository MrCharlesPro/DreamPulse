import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

abstract final class AppTheme {
  static ThemeData oscuro() {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppConstants.violeta,
      brightness: Brightness.dark,
      surface: AppConstants.superficie,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema.copyWith(
        primary: AppConstants.lavanda,
        secondary: AppConstants.violeta,
        surface: AppConstants.superficie,
      ),
      scaffoldBackgroundColor: AppConstants.fondo,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      cardTheme: CardThemeData(
        color: AppConstants.superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.superficie,
        indicatorColor: AppConstants.violeta.withValues(alpha: .25),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.superficie,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
