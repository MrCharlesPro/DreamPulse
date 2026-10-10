import 'package:flutter/foundation.dart';

import '../../domain/entities/registro_sueno.dart';
import '../../domain/repositories/sleep_repository.dart';

class SleepController extends ChangeNotifier {
  SleepController(this._repository);
  final SleepRepository _repository;
  List<RegistroSueno> _registros = [];
  bool _cargando = true;
  String? _error;

  List<RegistroSueno> get registros => List.unmodifiable(_registros);
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> cargar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      _registros = await _repository.obtenerTodos();
    } catch (error) {
      _error = 'No se pudieron cargar los registros: $error';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> guardar(RegistroSueno registro) async {
    _error = null;
    try {
      await _repository.guardar(registro);
      await cargar();
    } catch (error) {
      _error = 'No se pudo guardar el registro: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> eliminar(String id) async {
    await _repository.eliminar(id);
    await cargar();
  }
}
