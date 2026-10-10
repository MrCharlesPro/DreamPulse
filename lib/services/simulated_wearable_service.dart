import '../domain/entities/dispositivo.dart';
import 'wearable_service.dart';

class SimulatedWearableService implements WearableService {
  bool _conectado = false;

  @override
  Stream<List<Dispositivo>> buscar() async* {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    yield const [
      Dispositivo(
        id: 'sim-watch',
        nombre: 'DreamBand Simulada',
        simulado: true,
      ),
      Dispositivo(
        id: 'sim-ring',
        nombre: 'SleepRing de prueba',
        simulado: true,
      ),
    ];
  }

  @override
  Future<void> conectar(Dispositivo dispositivo) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _conectado = true;
  }

  @override
  Future<void> desconectar() async {
    _conectado = false;
  }

  @override
  Future<List<NocheDispositivo>> leerSueno() async {
    if (!_conectado) {
      throw StateError('Conecta un dispositivo antes de sincronizar.');
    }
    final ahora = DateTime.now();
    return List.generate(3, (indice) {
      final fecha = DateTime(
        ahora.year,
        ahora.month,
        ahora.day,
      ).subtract(Duration(days: indice + 1));
      final horas = [22, 23, 22][indice];
      final minutos = [10, 35, 50][indice];
      final inicio = DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        horas,
        minutos,
      );
      return NocheDispositivo(
        inicio: inicio,
        fin: inicio.add(Duration(hours: [7, 8, 7][indice])),
        calidad: [4, 3, 5][indice],
      );
    });
  }
}
