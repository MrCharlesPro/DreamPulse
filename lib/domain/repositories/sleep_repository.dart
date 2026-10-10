import '../entities/registro_sueno.dart';

abstract interface class SleepRepository {
  Future<List<RegistroSueno>> obtenerTodos();
  Future<void> guardar(RegistroSueno registro);
  Future<void> eliminar(String id);
}
