import 'package:uuid/uuid.dart';

import '../domain/entities/registro_sueno.dart';
import '../domain/repositories/sleep_repository.dart';
import 'simulated_wearable_service.dart';
import 'wearable_service.dart';

class SyncService {
  SyncService(this._wearable, this._sleepRepository);

  final WearableService _wearable;
  final SleepRepository _sleepRepository;

  Future<int> sincronizar() async {
    final noches = await _wearable.leerSueno();
    final existentes = await _sleepRepository.obtenerTodos();
    final fechas = existentes
        .map((registro) => _claveFecha(registro.inicio))
        .toSet();
    var sincronizados = 0;
    for (final noche in noches) {
      if (!fechas.add(_claveFecha(noche.inicio))) continue;
      await _sleepRepository.guardar(
        RegistroSueno(
          id: const Uuid().v4(),
          inicio: noche.inicio,
          fin: noche.fin,
          calidad: noche.calidad.clamp(1, 5).toInt(),
          origen: _origen,
        ),
      );
      sincronizados++;
    }
    return sincronizados;
  }

  String _claveFecha(DateTime fecha) =>
      '${fecha.year}-${fecha.month}-${fecha.day}';

  OrigenRegistro get _origen => _wearable is SimulatedWearableService
      ? OrigenRegistro.simulado
      : OrigenRegistro.automatico;
}
