import 'package:hive/hive.dart';

import '../../domain/entities/registro_sueno.dart';
import '../../domain/repositories/sleep_repository.dart';
import '../datasources/hive_sleep_data_source.dart';
import '../datasources/mock_sleep_data_source.dart';

class HiveSleepRepository implements SleepRepository {
  HiveSleepRepository(this._source, this._mockSource, this._settings);

  final HiveSleepDataSource _source;
  final MockSleepDataSource _mockSource;
  final Box<Map<dynamic, dynamic>> _settings;
  bool _inicializado = false;

  Future<void> inicializar() async {
    if (_inicializado) return;
    if (_settings.get('datosInicialesCargados')?['valor'] != true &&
        _source.obtenerTodos().isEmpty) {
      for (final registro in await _mockSource.cargar()) {
        await _source.guardar(registro);
      }
    }
    await _settings.put('datosInicialesCargados', {'valor': true});
    _inicializado = true;
  }

  @override
  Future<List<RegistroSueno>> obtenerTodos() async {
    await inicializar();
    return _source.obtenerTodos();
  }

  @override
  Future<void> guardar(RegistroSueno registro) async {
    await inicializar();
    await _source.guardar(registro);
  }

  @override
  Future<void> eliminar(String id) => _source.eliminar(id);
}
