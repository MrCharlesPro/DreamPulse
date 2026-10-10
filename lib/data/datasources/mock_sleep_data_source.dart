import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/registro_sueno.dart';

class MockSleepDataSource {
  Future<List<RegistroSueno>> cargar() async {
    final texto = await rootBundle.loadString('assets/mock_sleep.json');
    final elementos = jsonDecode(texto) as List<dynamic>;
    return elementos
        .map(
          (elemento) => RegistroSueno.fromMap(
            Map<dynamic, dynamic>.from(elemento as Map),
          ),
        )
        .toList();
  }
}
