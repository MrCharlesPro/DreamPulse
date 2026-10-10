import '../domain/entities/dispositivo.dart';

abstract interface class WearableService {
  Stream<List<Dispositivo>> buscar();
  Future<void> conectar(Dispositivo dispositivo);
  Future<void> desconectar();
  Future<List<NocheDispositivo>> leerSueno();
}
