import '../entities/usuario.dart';

abstract interface class ProfileRepository {
  Future<Usuario> obtener();
  Future<void> guardar(Usuario usuario);
}
