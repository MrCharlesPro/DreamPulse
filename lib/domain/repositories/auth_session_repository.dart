abstract interface class AuthSessionRepository {
  Future<bool> tieneSesion();
  Future<void> guardarSesion();
  Future<void> cerrarSesion();
}
