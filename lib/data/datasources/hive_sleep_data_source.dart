import 'package:hive/hive.dart';

import '../../domain/entities/registro_sueno.dart';

class HiveSleepDataSource {
  HiveSleepDataSource(this._box);
  final Box<Map<dynamic, dynamic>> _box;

  List<RegistroSueno> obtenerTodos() =>
      _box.values.map(RegistroSueno.fromMap).toList()
        ..sort((a, b) => b.inicio.compareTo(a.inicio));

  Future<void> guardar(RegistroSueno registro) =>
      _box.put(registro.id, registro.toMap());

  Future<void> eliminar(String id) => _box.delete(id);
}
