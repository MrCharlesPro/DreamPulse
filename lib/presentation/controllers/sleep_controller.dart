import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/registro_sueno.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../../domain/entities/etiqueta_sueno.dart';

class SleepController extends ChangeNotifier {
  SleepController(this._repository, [this._ajustes]);
  final SleepRepository _repository;
  final Box<Map<dynamic, dynamic>>? _ajustes;
  List<RegistroSueno> _registros = [];
  bool _cargando = true;
  String? _error;

  List<RegistroSueno> get registros => List.unmodifiable(_registros);
  bool get cargando => _cargando;
  String? get error => _error;
  DateTime? get inicioEnCurso {
    final inicio = _ajustes?.get('suenoEnCurso')?['inicio'];
    return inicio is String ? DateTime.tryParse(inicio) : null;
  }

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

  Future<void> iniciarSueno() async {
    if (inicioEnCurso != null) {
      throw StateError('Ya hay un registro de sueño en curso.');
    }
    await _ajustes?.put('suenoEnCurso', {
      'id': const Uuid().v4(),
      'inicio': DateTime.now().toIso8601String(),
    });
    notifyListeners();
  }

  Future<RegistroSueno> terminarSueno() async {
    final datos = _ajustes?.get('suenoEnCurso');
    final textoInicio = datos?['inicio'];
    if (textoInicio is! String) {
      throw StateError('No hay una noche en curso para cerrar.');
    }
    final inicio = DateTime.parse(textoInicio);
    final fin = DateTime.now();
    final duracion = fin.difference(inicio);
    if (duracion <= Duration.zero || duracion > const Duration(hours: 18)) {
      throw StateError('La duración del registro rápido no es válida.');
    }
    final registro = RegistroSueno(
      id: datos?['id'] as String? ?? const Uuid().v4(),
      inicio: inicio,
      fin: fin,
      calidad: 4,
      origen: OrigenRegistro.manual,
      etiquetas: const <EtiquetaSueno>[],
    );
    await guardar(registro);
    await _ajustes?.delete('suenoEnCurso');
    notifyListeners();
    return registro;
  }
}
