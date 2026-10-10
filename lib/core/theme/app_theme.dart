import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_constants.dart';

@immutable
class SleepScale extends ThemeExtension<SleepScale> {
  const SleepScale({
    required this.excellent,
    required this.good,
    required this.fair,
    required this.low,
    required this.poor,
  });

  final Color excellent;
  final Color good;
  final Color fair;
  final Color low;
  final Color poor;

  List<Color> get colors => [excellent, good, fair, low, poor];

  Color forHours(double hours, double goal) {
    final ratio = goal <= 0 ? 0 : hours / goal;
    if (ratio >= 1) return excellent;
    if (ratio >= .9) return good;
    if (ratio >= .75) return fair;
    if (ratio >= .6) return low;
    return poor;
  }

  Color forQuality(int quality) => switch (quality) {
    >= 5 => excellent,
    4 => good,
    3 => fair,
    2 => low,
    _ => poor,
  };

  @override
  SleepScale copyWith({
    Color? excellent,
    Color? good,
    Color? fair,
    Color? low,
    Color? poor,
  }) => SleepScale(
    excellent: excellent ?? this.excellent,
    good: good ?? this.good,
    fair: fair ?? this.fair,
    low: low ?? this.low,
    poor: poor ?? this.poor,
  );

  @override
  SleepScale lerp(ThemeExtension<SleepScale>? other, double t) {
    if (other is! SleepScale) return this;
    return SleepScale(
      excellent: Color.lerp(excellent, other.excellent, t)!,
      good: Color.lerp(good, other.good, t)!,
      fair: Color.lerp(fair, other.fair, t)!,
      low: Color.lerp(low, other.low, t)!,
      poor: Color.lerp(poor, other.poor, t)!,
    );
  }
}

abstract final class AppTheme {
  static const sleepScale = SleepScale(
    excellent: Color(0xFF2FBF71),
    good: Color(0xFF9ACD32),
    fair: Color(0xFFFFC15E),
    low: Color(0xFFFF8A3D),
    poor: Color(0xFFE5484D),
  );

  static ThemeData oscuro() {
    const esquema = ColorScheme(
      brightness: Brightness.dark,
      primary: AppConstants.coral,
      onPrimary: AppConstants.fondo,
      secondary: AppConstants.ambar,
      onSecondary: AppConstants.fondo,
      error: AppConstants.rosa,
      onError: AppConstants.fondo,
      surface: AppConstants.superficie,
      onSurface: AppConstants.texto,
      primaryContainer: AppConstants.superficieAlta,
      onPrimaryContainer: AppConstants.texto,
      secondaryContainer: AppConstants.superficieAlta,
      onSecondaryContainer: AppConstants.texto,
      tertiary: AppConstants.rosa,
      onTertiary: AppConstants.fondo,
      tertiaryContainer: AppConstants.superficieAlta,
      onTertiaryContainer: AppConstants.texto,
      errorContainer: AppConstants.superficieAlta,
      onErrorContainer: AppConstants.texto,
      surfaceDim: AppConstants.fondo,
      surfaceBright: AppConstants.superficieAlta,
      surfaceContainerLowest: AppConstants.fondo,
      surfaceContainerLow: AppConstants.superficie,
      surfaceContainer: AppConstants.superficie,
      surfaceContainerHigh: AppConstants.superficieAlta,
      surfaceContainerHighest: AppConstants.superficieAlta,
      onSurfaceVariant: AppConstants.textoSecundario,
      outline: AppConstants.textoSecundario,
      outlineVariant: AppConstants.superficieAlta,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppConstants.texto,
      onInverseSurface: AppConstants.fondo,
      inversePrimary: AppConstants.rosa,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppConstants.fondo,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme)
          .apply(
            bodyColor: AppConstants.texto,
            displayColor: AppConstants.texto,
          )
          .copyWith(
            bodySmall: GoogleFonts.poppins(color: AppConstants.textoSecundario),
            labelSmall: GoogleFonts.poppins(
              color: AppConstants.textoSecundario,
            ),
          ),
      extensions: const [sleepScale],
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.fondo,
        foregroundColor: AppConstants.texto,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppConstants.superficie,
        elevation: 0,
        shadowColor: AppConstants.coral.withValues(alpha: .10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppConstants.superficie,
        indicatorColor: AppConstants.coral.withValues(alpha: .2),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.superficieAlta,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size(48, 52)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (_) => AppConstants.coral,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (_) => AppConstants.fondo,
          ),
          overlayColor: WidgetStatePropertyAll(
            AppConstants.rosa.withValues(alpha: .18),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppConstants.coral,
        thumbColor: AppConstants.ambar,
        inactiveTrackColor: AppConstants.superficieAlta,
        overlayColor: AppConstants.rosa.withValues(alpha: .18),
      ),
    );
    return base;
  }
}
