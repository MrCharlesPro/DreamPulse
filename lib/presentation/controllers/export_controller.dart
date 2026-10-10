import 'package:flutter/foundation.dart';

import '../../domain/entities/registro_sueno.dart';
import '../../services/export_service.dart';

class ExportController extends ChangeNotifier {
  ExportController(this._servicio);
  final ExportService _servicio;
  bool _cargando = false;
  String? _error;
  bool _sinRegistros = false;

  bool get cargando => _cargando;
  String? get error => _error;
  bool get sinRegistros => _sinRegistros;

  Future<void> _ejecutar(Future<void> Function() accion) async {
    _cargando = true;
    _error = null;
    _sinRegistros = false;
    notifyListeners();
    try {
      await accion();
    } catch (error) {
      _error = 'No se pudo completar la operación: $error';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> csv(List<RegistroSueno> registros) async {
    if (registros.isEmpty) {
      _sinRegistros = true;
      notifyListeners();
      return;
    }
    await _ejecutar(() => _servicio.compartirCsv(registros));
  }

  Future<void> pdf(List<RegistroSueno> registros) async {
    if (registros.isEmpty) {
      _sinRegistros = true;
      notifyListeners();
      return;
    }
    await _ejecutar(() => _servicio.compartirPdf(registros));
  }

  Future<void> respaldo(List<RegistroSueno> registros) =>
      _ejecutar(() => _servicio.compartirRespaldo(registros));

  Future<List<RegistroSueno>?> restaurar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      return await _servicio.seleccionarRespaldo();
    } catch (error) {
      _error = 'No se pudo restaurar el respaldo: $error';
      rethrow;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }
}
