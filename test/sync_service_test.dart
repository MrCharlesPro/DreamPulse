import 'package:dreampulse/domain/entities/dispositivo.dart';
import 'package:dreampulse/domain/entities/registro_sueno.dart';
import 'package:dreampulse/domain/repositories/sleep_repository.dart';
import 'package:dreampulse/services/simulated_wearable_service.dart';
import 'package:dreampulse/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';

class RepositorioMemoria implements SleepRepository {
  final List<RegistroSueno> registros = [];

  @override
  Future<List<RegistroSueno>> obtenerTodos() async => registros.toList();

  @override
  Future<void> guardar(RegistroSueno registro) async => registros.add(registro);

  @override
  Future<void> eliminar(String id) async =>
      registros.removeWhere((item) => item.id == id);
}

void main() {
  test('sincroniza noches simuladas y evita duplicados por fecha', () async {
    final servicio = SimulatedWearableService();
    final dispositivo = const Dispositivo(
      id: 'prueba',
      nombre: 'Demo',
      simulado: true,
    );
    await servicio.conectar(dispositivo);
    final repositorio = RepositorioMemoria();
    final sincronizacion = SyncService(servicio, repositorio);

    expect(await sincronizacion.sincronizar(), 3);
    expect(repositorio.registros, hasLength(3));
    expect(repositorio.registros.first.origen, OrigenRegistro.simulado);
    expect(await sincronizacion.sincronizar(), 0);
  });
}
