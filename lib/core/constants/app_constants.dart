import 'package:flutter/material.dart';

abstract final class AppConstants {
  static const appName = 'DreamPulse';
  static const fondo = Color(0xFF150E14);
  static const superficie = Color(0xFF221823);
  static const superficieAlta = Color(0xFF2E2030);
  static const coral = Color(0xFFFF8A5B);
  static const ambar = Color(0xFFFFC15E);
  static const rosa = Color(0xFFFF6F91);
  static const texto = Color(0xFFFFF4EC);
  static const textoSecundario = Color(0xFFCDB8B0);
  static const degradado = LinearGradient(
    colors: [coral, rosa],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
